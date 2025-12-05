import 'package:flutter/material.dart';
import 'package:travelbox/models/cofre.dart';
import 'package:travelbox/models/contribuicao.dart';
import 'package:travelbox/models/permissao.dart';
import 'package:travelbox/models/usuario.dart';
import 'package:travelbox/services/firestoreService.dart';

class DetalhesCofreStore extends ChangeNotifier {
  final FirestoreService _firestoreService;

  // --- VARIÁVEIS DE ESTADO ---
  Cofre? _cofreAtivo; 
  bool _isLoading = false;
  String? _errorMessage;

  // Listas de dados
  List<Contribuicao> _contribuicoes = [];
  List<Permissao> _membros = []; 

  // Mapa para acesso rápido aos dados do usuário (ex: foto, nome) pelo ID
  Map<String, Usuario> _contribuidoresMap = {}; 
  
  // --- GETTERS PÚBLICOS ---
  Cofre? get cofreAtivo => _cofreAtivo; 
  bool get isLoading => _isLoading; 
  String? get errorMessage => _errorMessage; 
  List<Contribuicao> get contribuicoes => _contribuicoes;
  List<Permissao> get membros => _membros;
  Map<String, Usuario> get contribuidoresMap => _contribuidoresMap;

  // Cálculo Dinâmico do Saldo (Fonte Única da Verdade)
  double get totalArrecadado {
    return _contribuicoes.fold(0.0, (total, atual) => total + atual.valor);
  }

  DetalhesCofreStore(this._firestoreService);

  // ----------------------------------------------------
  // CARREGAR DADOS
  // ----------------------------------------------------
  Future<void> carregarDadosCofre(String cofreId) async {
    _isLoading = true;
    _errorMessage = null; 
    notifyListeners(); 

    try {
      // 1. Buscas concorrentes (Cofre, Contribuições, Permissões)
      final results = await Future.wait([
        _firestoreService.getCofreById(cofreId),        
        _firestoreService.getContribuicoesDoCofre(cofreId), 
        _firestoreService.getMembrosCofre(cofreId), // Corrigido nome do método
      ]);

      _cofreAtivo = results[0] as Cofre?; 
      _contribuicoes = results[1] as List<Contribuicao>;
      _membros = results[2] as List<Permissao>; 

      if (_cofreAtivo == null) {
          throw Exception("Cofre não encontrado ou acesso negado.");
      }
      
      // 2. Extrai os UIDs únicos das contribuições E dos membros
      // Assim garantimos que temos os dados de todo mundo
      final Set<String> todosIds = {};
      todosIds.addAll(_contribuicoes.map((c) => c.idUsuario));
      todosIds.addAll(_membros.map((m) => m.idUsuario));

      if (todosIds.isNotEmpty) {
        // 3. Busca os perfis de usuário em massa
        final List<Usuario> perfis = await _firestoreService.getUsuariosByIds(todosIds.toList());

        // 4. Cria o mapa
        _contribuidoresMap = { for (var user in perfis) user.id!: user }; 
      }

    } catch (e) {
      _errorMessage = "Erro ao carregar detalhes: ${e.toString()}";
      _cofreAtivo = null; 
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  } 

  // ----------------------------------------------------
  // ADICIONAR CONTRIBUIÇÃO
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
        id: null, // Firebase gera
        idCofre: cofreId,
        idUsuario: usuarioId,
        valor: valor,
        data: data,
      );

      // 1. Salva a contribuição no Banco
      await _firestoreService.addContribuicao(nova);

      // NOTA: Não precisamos chamar atualizarSaldoCofre, 
      // pois o getter 'totalArrecadado' soma tudo automaticamente.
      
      // 2. OTIMIZAÇÃO: Atualiza a lista localmente
      // Inserimos no topo da lista para aparecer na hora, sem gastar internet recarregando tudo
      _contribuicoes.insert(0, nova); 

      // Se o usuário ainda não estava no mapa (primeira contribuição), buscamos ele
      if (!_contribuidoresMap.containsKey(usuarioId)) {
         final user = await _firestoreService.getUsuario(usuarioId);
         if (user != null) {
           _contribuidoresMap[usuarioId] = user;
         }
      }

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false; 
      notifyListeners();
      return false;
    }
  }
}