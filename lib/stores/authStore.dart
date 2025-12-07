import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelbox/services/AuthService.dart';
import 'package:travelbox/services/FirestoreService.dart';
import 'package:travelbox/models/usuario.dart';

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

      _firebaseUser = firebaseUser;

       try{
        _usuario = await _firestoreService.getUsuario(firebaseUser.uid);

        if(_usuario != null) {
          _sessionStatus = SessionStatus.authenticated;
        } else {
          _sessionStatus = SessionStatus.unauthenticated;
        }
       } catch (e) {
        print("Erro Crítico ao buscar o usuário: $e");
        _sessionStatus = SessionStatus.unauthenticated;
       }
    }
    notifyListeners();
  }

//===========================    TESTE   ==================================================

// // Monitora mudanças na autenticação (Login/Logout)
//   Future<void> _onAuthStateChanged(User? firebaseUser) async {
//     if (firebaseUser == null) {
//       print("🔒 AuthStore: Usuário deslogado (NULL)");
//       _sessionStatus = SessionStatus.unauthenticated;
//       _firebaseUser = null;
//       _usuario = null;
//     } else {
//       print("🔑 AuthStore: Usuário detectado no Firebase (${firebaseUser.uid}). Buscando perfil...");
      
//       _firebaseUser = firebaseUser;

//        try {
//         _usuario = await _firestoreService.getUsuario(firebaseUser.uid);

//         if(_usuario != null) {
//           print("✅ AuthStore: Perfil encontrado! Entrando na Home.");
//           _sessionStatus = SessionStatus.authenticated;
//         } else {
//           print("⚠️ AuthStore: Usuário autenticado, mas SEM PERFIL no Firestore.");
//           // Se não tem perfil, não podemos deixar entrar na Home, senão quebra.
//           // O ideal aqui seria jogar para uma tela de "Completar Cadastro",
//           // mas por segurança, mantemos deslogado ou forçamos logout.
//           _sessionStatus = SessionStatus.unauthenticated; 
//         }
//        } catch (e) {
//         print("🔥 AuthStore: Erro Crítico ao buscar o usuário: $e");
//         _sessionStatus = SessionStatus.unauthenticated;
//        }
//     }
//     notifyListeners();
//   }

//===========================    TESTE   ==================================================


  void resetActionStatus() {
    _actionStatus = ActionStatus.initial;
    _errorMessage = null; 
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
    // 1. Garante que o Firebase reconhece um usuário logado
    if (_firebaseUser != null) {
      // 2. Busca novamente os dados do perfil no Firestore
      Usuario? usuarioAtualizado = await _firestoreService.getUsuario(_firebaseUser!.uid);

      // 3. Atualiza o estado local
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

    if (_errorMessage == null) {
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

  /// Ação Crítica: Excluir Conta
  Future<bool> excluirConta(String password) async {
    _actionStatus = ActionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Segurança: Reautentica para provar que é o dono
      await _authService.reauthenticate(password);

      // 2. Apaga dados do Firestore
      if (_firebaseUser != null) {
        await _firestoreService.deleteUserData(_firebaseUser!.uid);
      }

      // 3. Apaga o Login (Isso desloga automaticamente)
      await _authService.deleteAuth();

      // Limpa tudo localmente
      _sessionStatus = SessionStatus.unauthenticated;
      _usuario = null;
      _firebaseUser = null;
      
      _actionStatus = ActionStatus.success;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString(); // O AppErrors vai traduzir (ex: wrong-password)
      _actionStatus = ActionStatus.error;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
