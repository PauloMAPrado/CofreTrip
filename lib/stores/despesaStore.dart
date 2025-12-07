// lib/controllers/DespesaProvider.dart
import '../models/despesa.dart';

import 'package:flutter/material.dart';
import 'package:travelbox/services/FirestoreService.dart';
class DespesaProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  
  DespesaProvider(this._firestoreService);

  // --- VARIÁVEIS DE ESTADO ---
  bool _isLoading = false;
  String? _errorMessage;
  List<Despesa> _despesas = [];
  
  // Mapa de Saldos: UserID -> Saldo Líquido (Positivo: recebe, Negativo: deve)
  Map<String, double> _saldosFinais = {};

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Despesa> get despesas => _despesas;
  Map<String, double> get saldosFinais => _saldosFinais;

  // ----------------------------------------------------
  // LÓGICA DE SALDOS (SPLITWISE)
  // ----------------------------------------------------
  
  /// Processa todas as despesas e calcula o saldo líquido de cada usuário.
  void calcularSaldos() {
      _saldosFinais = {}; // Zera antes de recalcular

      for (var despesa in _despesas) {
          final pagadorId = despesa.idUsuarioPagador;
          
          // Itera sobre a lista de dívidas/divisões desta despesa
          for (var splitMap in despesa.divisao) {
              
              // O mapa interno é {idUsuario: valorDevido}
              final String devedorId = splitMap.keys.first;
              final double valorDevido = splitMap.values.first;

              // 1. Atualiza o saldo do DEVEDOR (diminui)
              // O devedor deve pagar o valorDevido. O saldo dele diminui (débito).
              _saldosFinais.update(devedorId, (saldo) => saldo - valorDevido, ifAbsent: () => -valorDevido);

              // 2. Atualiza o saldo do PAGADOR (aumenta)
              // O pagador deve receber o valorDevido. O saldo dele aumenta (crédito).
              _saldosFinais.update(pagadorId, (saldo) => saldo + valorDevido, ifAbsent: () => valorDevido);
          }
      }
      
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
      
      // 🎯 Calcula os saldos imediatamente após carregar os dados.
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
}