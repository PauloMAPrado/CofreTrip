import 'package:flutter/material.dart';
import '../models/cofre.dart'; 
import '../models/contribuicao.dart';
import '../models/permissao.dart';
import '../services/FirestoreService.dart';
import 'package:travelbox/models/Usuario.dart';

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

  // 🎯 CORREÇÃO 1: Mapeia ID do Usuário (String) -> Objeto Usuario
  Map<String, Usuario> _contribuidoresMap = {}; 
  
  // 🎯 CORREÇÃO 2: Getter público que a View está tentando acessar
  Map<String, Usuario> get contribuidoresMap => _contribuidoresMap;

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
      // 1. Buscas concorrentes (Cofre, Contribuições, Permissões)
      final results = await Future.wait([
        _firestoreService.getCofreById(cofreId),        // 0
        _firestoreService.getContribuicoesDoCofre(cofreId), // 1
        _firestoreService.getPermissoesDoCofre(cofreId), // 2
      ]);

      _cofreAtivo = results[0] as Cofre?; 
      _contribuicoes = results[1] as List<Contribuicao>;
      _membros = results[2] as List<Permissao>; 

      if (_cofreAtivo == null) {
          throw Exception("Cofre não encontrado ou acesso negado.");
      }
      
      // 🎯 CORREÇÃO 3: LÓGICA DE BUSCA DE NOMES DOS CONTRIBUIDORES
      
      // 2. Extrai os UIDs ÚNICOS de todas as contribuições
      final contribuidoresIds = _contribuicoes
          .map((c) => c.idUsuario)
          .toSet() // Remove duplicatas
          .toList();

      // 3. Busca os perfis de usuário em massa (Necessita do método getUsuariosByIds no FirestoreService)
      final List<Usuario> perfis = await _firestoreService.getUsuariosByIds(contribuidoresIds);

      // 4. Converte a lista de perfis para um MAPA (ID -> Objeto) para acesso rápido
      _contribuidoresMap = { for (var user in perfis) user.id!: user }; 


    } catch (e) {
      _errorMessage = "Erro ao carregar detalhes: ${e.toString()}";
      _cofreAtivo = null; 
    }

    // 🎯 CORREÇÃO CRÍTICA: O bloco finally é sempre executado
    finally {
      _isLoading = false;
      notifyListeners(); // Notifica a View que o carregamento terminou
    }
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