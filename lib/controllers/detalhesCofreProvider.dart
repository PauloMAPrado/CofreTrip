import 'package:flutter/material.dart';
import '../models/cofre.dart'; 
import '../models/contribuicao.dart';
import '../models/permissao.dart';
import '../services/FirestoreService.dart';

class DetalhesCofreProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  // --- VARIÁVEIS DE ESTADO ---
  
  // 1. O objeto Cofre principal
  Cofre? _cofreAtivo; 

  // 2. Estado de carregamento e erro
  bool _isLoading = false;
  String? _errorMessage; // 🎯 CORREÇÃO: Nome padronizado

  // 3. Listas de dados
  List<Contribuicao> _contribuicoes = [];
  List<Permissao> _membros = []; 

  // --- GETTERS PÚBLICOS ---
  
  Cofre? get cofreAtivo => _cofreAtivo; 
  
  bool get isLoading => _isLoading; 
  
  // 🎯 CORREÇÃO: Getter público que a View está tentando acessar
  String? get errorMessage => _errorMessage; 
  
  List<Contribuicao> get contribuicoes => _contribuicoes;
  List<Permissao> get membros => _membros;

  double get totalArrecadado {
    return _contribuicoes.fold(0.0, (total, atual) => total + atual.valor);
  }

  DetalhesCofreProvider(this._firestoreService);

  // ----------------------------------------------------
  // MÉTODO PRINCIPAL: CARREGAR DADOS DO COFRE
  // ----------------------------------------------------
  Future<void> carregarDadosCofre(String cofreId) async {
    _isLoading = true;
    _errorMessage = null; 
    notifyListeners(); 

    try {
      // 1. Buscas concorrentes
      final results = await Future.wait([
        _firestoreService.getCofreById(cofreId),        // 0: Objeto Cofre principal
        _firestoreService.getContribuicoesDoCofre(cofreId), // 1: Contribuições
        _firestoreService.getPermissoesDoCofre(cofreId), // 2: Permissões (Membros)
      ]);

      // 2. Atribuições dos resultados (Casting seguro)
      _cofreAtivo = results[0] as Cofre?; 
      _contribuicoes = results[1] as List<Contribuicao>;
      _membros = results[2] as List<Permissao>; 

      if (_cofreAtivo == null) {
          throw Exception("Cofre não encontrado ou acesso negado.");
      }

    } catch (e) {
      _errorMessage = "Erro ao carregar detalhes: ${e.toString()}";
      _cofreAtivo = null; 
    }

    _isLoading = false;
    notifyListeners(); 
  }

  // ----------------------------------------------------
  // ADICIONAR CONTRIBUIÇÃO (Mantido o fluxo de atualização)
  // ----------------------------------------------------
  Future<bool> adicionarContribuicao({
    required String cofreId,
    required String usuarioId,
    required double valor,
    required DateTime data,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Contribuicao nova = Contribuicao(
        id: null,
        idCofre: cofreId,
        idUsuario: usuarioId,
        valor: valor,
        data: data,
      );

      await _firestoreService.addContribuicao(nova);
      await _firestoreService.atualizarSaldoCofre(cofreId, valor); // Atualização atômica
      
      _contribuicoes.insert(0, nova); // Adiciona localmente

      // ⚠️ IMPORTANTE: Chamamos o carregarDadosCofre para sincronizar o saldo total
      await carregarDadosCofre(cofreId); 

      // isLoading e notifyListeners serão chamados no final de carregarDadosCofre

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}