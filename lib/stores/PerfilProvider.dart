import 'package:flutter/material.dart';
import 'package:travelbox/models/Usuario.dart';
import 'package:travelbox/services/AuthService.dart';
import 'package:travelbox/services/FirestoreService.dart';

class PerfilProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;

  bool _isloading = false;
  String? _errorMensage;
  String? _successMensage;

  PerfilProvider(this._firestoreService, this._authService);

  bool get isloading => _isloading;
  String? get errorMensage => _errorMensage;
  String? get successMensage => _successMensage;

  Future<bool> atualizarPerfil(Usuario usaurioAtualizado) async {
    _isloading = true;
    _errorMensage = null;
    _successMensage = null;
    notifyListeners();

    try {
      await _firestoreService.atualizarDadosUsuario(usaurioAtualizado);

      _successMensage = "Perfil atualizado!";
      _isloading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMensage = "erro ao atualizar perfil: $e";
      _isloading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> alterarSenha(String novaSenha) async {
    _isloading = true;
    _errorMensage = null;
    _successMensage = null;
    notifyListeners();

    try {
      await _authService.atualizarSenha(novaSenha);
      _successMensage = "Senha alterada com sucesso!";
      _isloading = false;
      return true;
    } catch (e) {
      _errorMensage = "Erro ao mudar senha: $e";
      _isloading = false;
      notifyListeners();
      return false;
    }
  }

  void resetMessege() {
    _errorMensage = null;
    _errorMensage = null;
    notifyListeners();
  }
}
