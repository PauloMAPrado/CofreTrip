import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelbox/services/AuthService.dart';
import 'package:travelbox/services/FirestoreService.dart';
import 'package:travelbox/models/Usuario.dart';

// Status da sessão. Dita se o usuario esta logado ou não.
enum SessionStatus { uninitialized, authenticated, unauthenticated }

// Enum para gerenciar o estado da UI de forma clara
enum ActionStatus { initial, loading, success, error }

class AuthStore extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  SessionStatus _sessionStatus = SessionStatus.uninitialized;
  Usuario? _usuario;
  User? _firebaseUser;
  late StreamSubscription _authStateSubscription;

  ActionStatus _actionStatus = ActionStatus.initial;
  String? _errorMessage;

  SessionStatus get sessionStatus => _sessionStatus;
  Usuario? get usuario => _usuario;
  bool get isLoggedIn => _sessionStatus == SessionStatus.authenticated;

  // Getters da Ação
  ActionStatus get actionStatus => _actionStatus;
  String? get errorMessage => _errorMessage;

  AuthStore(this._authService, this._firestoreService) {
    _authStateSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _sessionStatus = SessionStatus.unauthenticated;
      _firebaseUser = null;
      _usuario = null;
    } else {
      _sessionStatus = SessionStatus.authenticated;
      _firebaseUser = firebaseUser;

      _usuario = await _firestoreService.getUsuario(firebaseUser.uid);
    }

    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _actionStatus = ActionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    _errorMessage = await _authService.signIn(email: email, password: password);

    if (_errorMessage == null) {
      _actionStatus = ActionStatus.success;
      notifyListeners();
      return true;
    } else {
      _actionStatus = ActionStatus.error;
      _errorMessage = errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String nome,
    required String cpf,
    String? telefone,
  }) async {
    _actionStatus = ActionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    _errorMessage = await _authService.signUp(
      email: email,
      password: password,
      nome: nome,
      cpf: cpf,
      telefone: telefone,
    );

    if (_errorMessage == null) {
      _actionStatus = ActionStatus.success;
      notifyListeners();
      return true;
    } else {
      _actionStatus = ActionStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> recarregarUsuario() async {
    if (_firebaseUser != null) {
      Usuario? usuarioAtualizado;

      _usuario = usuarioAtualizado;

      notifyListeners();
    }
  }

  Future<void> signOut() async {
    // <--- CORREÇÃO APLICADA!
    await _authService.signOut();
  }

  Future<void> recoverPassword({required String email}) async {
    _actionStatus = ActionStatus.loading;
    notifyListeners();

    _errorMessage = await _authService.resetPassword(email: email);

    if (errorMessage == null) {
      _actionStatus = ActionStatus.success;
    } else {
      _actionStatus = ActionStatus.error;
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      _actionStatus = ActionStatus.initial;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
