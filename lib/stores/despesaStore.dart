// lib/controllers/DespesaProvider.dart

import 'package:flutter/material.dart';
import 'package:travelbox/services/FirestoreService.dart';
import '../models/despesa.dart';
// Importe o modelo de transação (certifique-se de que o nome está correto: transacaoAcerto.dart)
import '../models/transacaoAcerto.dart';
import  'package:travelbox/models/acerto.dart';

class DespesaProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  
  DespesaProvider(this._firestoreService);

  // --- VARIÁVEIS DE ESTADO ---
  bool _isLoading = false;
  String? _errorMessage;
  List<Despesa> _despesas = [];

  
  // 🎯 NOVO: Lista de transações simplificadas para a UI
  List<TransacaoAcerto> _transacoesAcerto = [];
  List<TransacaoAcerto> get transacoesAcerto => _transacoesAcerto;

  List<Acerto> _acertos = []; // Lista de pagamentos registrados
  List<Acerto> get acertos => _acertos;
  
  // Mapa de Saldos: UserID -> Saldo Líquido (Positivo: recebe, Negativo: deve)
  Map<String, double> _saldosFinais = {};

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Despesa> get despesas => _despesas;
  Map<String, double> get saldosFinais => _saldosFinais;

  // ----------------------------------------------------
  // ALGORITMO DE SIMPLIFICAÇÃO DE DÍVIDAS (Splitwise)
  // ----------------------------------------------------

  /// 🎯 NOVO MÉTODO: Transforma saldos líquidos (créditos/débitos) em transações mínimas.
  void calcularTransacoesMinimas() {
    _transacoesAcerto = [];
    final Map<String, double> saldos = Map.from(saldosFinais); // Copia o saldo líquido

    // 1. Separa Credores (saldo positivo) e Devedores (saldo negativo)
    // Filtra valores próximos de zero (margem de erro de float)
    final List<MapEntry<String, double>> credores = saldos.entries
        .where((e) => e.value > 0.01) 
        .toList();

    final List<MapEntry<String, double>> devedores = saldos.entries
        .where((e) => e.value < -0.01) 
        .toList();

    // 2. Transforma o valor dos devedores em positivo (quanto precisa pagar)
    List<MapEntry<String, double>> devedoresAbs = devedores
        .map((e) => MapEntry(e.key, e.value.abs()))
        .toList();

    if (devedoresAbs.isEmpty || credores.isEmpty) return;

    // 3. Processamento (Algoritmo Guloso)
    int i = 0; // Índice do Devedor
    int j = 0; // Índice do Credor

    while (i < devedoresAbs.length && j < credores.length) {
      double valorDevido = devedoresAbs[i].value;
      double valorReceber = credores[j].value;
      
      // Encontra o menor valor (este será o valor da transação)
      double valorTransacao = [valorDevido, valorReceber].reduce((a, b) => a < b ? a : b);

      // Registra a transação: Devedor i paga Credor j
      _transacoesAcerto.add(TransacaoAcerto(
        pagadorId: devedoresAbs[i].key,
        recebedorId: credores[j].key,
        valor: valorTransacao,
      ));

      // Atualiza os saldos restantes
      devedoresAbs[i] = MapEntry(devedoresAbs[i].key, valorDevido - valorTransacao);
      credores[j] = MapEntry(credores[j].key, valorReceber - valorTransacao);

      // Move para o próximo credor/devedor se o saldo for zerado
      if (devedoresAbs[i].value.abs() < 0.01) {
        i++; // Devedor i está quitado
      }
      if (credores[j].value.abs() < 0.01) {
        j++; // Credor j está quitado
      }
    }
  }


  /// Processa todas as despesas e calcula o saldo líquido de cada usuário.
  void calcularSaldos() {
      _saldosFinais = {}; 

      for (var despesa in _despesas) {
          final pagadorId = despesa.idUsuarioPagador;
          
          for (var splitMap in despesa.divisao) {
              final String devedorId = splitMap.keys.first;
              final double valorDevido = splitMap.values.first;

              _saldosFinais.update(devedorId, (saldo) => saldo - valorDevido, ifAbsent: () => -valorDevido);
              _saldosFinais.update(pagadorId, (saldo) => saldo + valorDevido, ifAbsent: () => valorDevido);
          }
      }

      for (var acerto in _acertos) {
        final pagadorId = acerto.idUsuarioPagador;
        final recebedorId = acerto.idUsuarioRecebedor;
        final double valor = acerto.valor;
        
        // O Pagador está liquidando uma dívida, logo, seu débito diminui (o saldo aumenta)
        _saldosFinais.update(pagadorId, (saldo) => saldo + valor, ifAbsent: () => valor);

        // O Recebedor está recebendo o pagamento, logo, seu crédito diminui (o saldo cai)
        _saldosFinais.update(recebedorId, (saldo) => saldo - valor, ifAbsent: () => -valor);
    }
      
      // 🎯 NOVO: Após calcular o saldo líquido, calcule as transações mínimas.
      calcularTransacoesMinimas(); 
      notifyListeners();
  }
  
  // ----------------------------------------------------
  // OPERAÇÕES DE DADOS (CRUD)
  // ----------------------------------------------------

  /// Carrega as despesas do cofre e calcula os saldos.
  Future<void> carregarDespesas(String idCofre) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _despesas = await _firestoreService.getDespesas(idCofre);
      _acertos = await _firestoreService.getAcertos(idCofre);
      
      // 🎯 Calcula os saldos e as transações
      calcularSaldos(); 
      
    } catch (e) {
      _errorMessage = 'Erro ao carregar despesas: ${e.toString()}';
    }
    _isLoading = false;
    notifyListeners();
  }
  
  /// Registra uma nova despesa no Firestore.
  Future<bool> registrarDespesa(Despesa novaDespesa) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _firestoreService.criarDespesa(novaDespesa);
      
      // Otimização: Adiciona localmente e recalcula
      _despesas.insert(0, novaDespesa); 
      
      // 🎯 Recalcula saldos e transações
      calcularSaldos(); 
      
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = 'Falha ao registrar despesa: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrarAcerto(Acerto novoAcerto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // 1. Salva no Firestore (usando o método que criamos)
      await _firestoreService.criarAcerto(novoAcerto);
      
      // 2. Otimização: Adiciona localmente e recalcula
      _acertos.insert(0, novoAcerto); // Adiciona ao topo
      
      // 3. Recalcula saldos e transações
      calcularSaldos(); 
      
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = 'Falha ao registrar acerto: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  
}