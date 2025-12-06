import 'package:flutter/material.dart';
import 'package:travelbox/models/convite.dart';
import 'package:travelbox/models/permissao.dart';
import 'package:travelbox/models/statusConvite.dart';
import 'package:travelbox/models/Usuario.dart';
import 'package:travelbox/models/nivelPermissao.dart';
import 'package:travelbox/services/FirestoreService.dart';

class ConviteStore extends ChangeNotifier {
  final FirestoreService _firestoreService;

  bool _isLoading = false; 
  String? _errorMessage; 
  List<Convite> _convitesRecebidos = [];
  ConviteStore(this._firestoreService);
  
  
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage; 
  List<Convite> get convitesRecebidos => _convitesRecebidos;


  /// Carrega os convites pendentes do usuário
  Future<void> carregarConvites(String userId) async {
    _isLoading = true;
    _errorMessage = null; 
    notifyListeners();
    try {
      _convitesRecebidos = await _firestoreService.getConvitesRecebidos(userId);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Envia um convite por e-mail
  Future<String?> enviarConvite({
    required String emailDestino,
    required String cofreId,
    required String idUsuarioConvidador,
  }) async {
    _isLoading = true;
    _errorMessage = null; 
    notifyListeners();

    try {
      Usuario? usuarioDestino = await _firestoreService.buscarUsuarioPorEmail(
        emailDestino.trim(),
      );

      if (usuarioDestino == null) {
        _isLoading = false;
        notifyListeners();
        return "Usuario com email $emailDestino não encontrado.";
      }

      if (usuarioDestino.id == idUsuarioConvidador) {
         _isLoading = false;
         notifyListeners();
         return "Você não pode convidar a si mesmo.";
      }

      Convite novoConvite = Convite(
        status: StatusConvite.pendente,
        dataEnvio: DateTime.now(),
        idCofre: cofreId,
        idUsuarioConvidador: idUsuarioConvidador,
        idUsuarioConvidado: usuarioDestino.id!,
      );

      await _firestoreService.criarConvite(novoConvite);

      _isLoading = false;
      notifyListeners();
      return null; // Sucesso
    } catch (e) {
      // 5. CORREÇÃO: Captura o erro e retorna a mensagem
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return _errorMessage; // Retorna a mensagem de erro para a UI tratar
    }
  }

  /// Aceita ou Recusa um convite
  Future<void> responderConvite(Convite convite, bool aceitar) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      StatusConvite novoStatus = aceitar
          ? StatusConvite.aceito
          : StatusConvite.recusado;

      await _firestoreService.responderConvite(convite.id!, novoStatus);

      if (aceitar) {
        Permissao perm = Permissao(
          nivelPermissao: NivelPermissao.contribuinte,
          idUsuario: convite.idUsuarioConvidado,
          idCofre: convite.idCofre,
        );

        await _firestoreService.criarPermissao(perm);
      }

      // 6. Atualiza a lista local após a resposta
      _convitesRecebidos.removeWhere((c) => c.id == convite.id);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}