import 'package:flutter/material.dart';
import 'package:travelbox/models/cofre.dart';
import 'package:travelbox/models/permissao.dart';
import 'package:travelbox/models/nivelPermissao.dart';
import 'package:travelbox/services/FirestoreService.dart';

class CofreProvider extends ChangeNotifier {
  // 2. DEPENDÊNCIA DO SERVICE (A "COZINHA")
  // Ele "conhece" o service, mas a UI não.
  final FirestoreService _firestoreService;

  List<Cofre> _cofres = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Cofre> get cofres => _cofres;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CofreProvider(this._firestoreService);

  Future<void> carregarCofres(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifica a Home que o carregamento começou

    try {
      _cofres = await _firestoreService.getCofresDoUsuario(userId);
    } catch (e) {
      _errorMessage = 'Falha ao carregar cofres: ${e.toString()}';
      print('ERRO NO PROVIDER: $_errorMessage'); // Log para debug
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica a Home que o carregamento terminou
    }
  }

  // ATUALIZAÇÃO: salvarCofre agora precisa saber QUEM está criando

  Future<bool> criarCofre(String nome, int valorPlano, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Usamos nosso novo factory 'Cofre.novo'
      Cofre novoCofre = Cofre.novo(nome: nome, valorPlano: valorPlano);

      // Passa o cofre e o ID do criador para o service
      Cofre cofreSalvo = await _firestoreService.criarCofre(novoCofre, userId);

      _cofres.add(cofreSalvo); // Adiciona o novo cofre à lista local

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Erro ao salvar cofre: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  Future<String?> entrarComCodigo(String codigo, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Acha o cofre pelo código
      // Normaliza o código para maiúsculas para facilitar a digitação
      final cofre = await _firestoreService.findCofreByCode(
        codigo.toUpperCase().trim(),
      );

      if (cofre == null) {
        _isLoading = false;
        notifyListeners();
        return "Código inválido. Verifique e tente novamente.";
      }

      bool jaPaticipa = _cofres.any((c) => c.id == cofre.id);
      if (jaPaticipa) {
        _isLoading = false;
        notifyListeners();
        return "Você já participa deste cofre!";
      }

      // 2. Cria uma permissão de "leitor" (ou 'membro', 'editor', etc)
      Permissao novaPermissao = Permissao(
        id: null,
        idUsuario: userId,
        idCofre: cofre.id!,
        nivelPermissao:
            NivelPermissao.contribuinte, // Nível padrão para quem entra
      );

      // 3. Salva a permissão
      await _firestoreService.criarPermissao(novaPermissao);

      // 4. (Opcional) Adiciona o cofre à lista local
      if (!_cofres.any((c) => c.id == cofre.id)) {
        _cofres.add(cofre);
      }

      _isLoading = false;
      notifyListeners();
      return null; // Sucesso!
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Erro ao tentar entrar no cofre: ${e.toString()}";
    }
  }

  void limparDados() {
    _cofres = [];
    notifyListeners();
  }
}