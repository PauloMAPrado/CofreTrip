import 'package:flutter/material.dart';
import 'package:travelbox/models/convite.dart';
import 'package:travelbox/models/permissao.dart';
import 'package:travelbox/models/statusConvite.dart';
import 'package:travelbox/models/Usuario.dart';
import 'package:travelbox/models/nivelPermissao.dart';
import 'package:travelbox/services/FirestoreService.dart';

class Conviteprovider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  bool _isloading = false;
  String? _errorMensage;
  List<Convite> _convitesRecebidos = [];

  Conviteprovider(this._firestoreService);

  bool get isloading => _isloading;
  String? get errorMensege => _errorMensage;
  List<Convite> get convitesRecebidos => _convitesRecebidos;

  Future<void> carregarConvites(String userId) async {
    _isloading = true;
    notifyListeners();
    try {
      _convitesRecebidos = await _firestoreService.getConvitesRecebidos(userId);
    } catch (e) {
      _errorMensage = e.toString();
    }
    _isloading = false;
    notifyListeners();
  }

  Future<String?> enviarConvite({
    required String emailDestino,
    required String cofreId,
    required String idUsuarioConvidador,
  }) async {
    _isloading = true;
    _errorMensage = null;
    notifyListeners();

    try {
      Usuario? usuarioDestino = await _firestoreService.buscarUsuarioPorEmail(
        emailDestino,
      );

      if (usuarioDestino == null) {
        _isloading = false;
        notifyListeners();
        return "Usuario com email $emailDestino não encontrado.";
      }

      Convite novoConvite = Convite(
        status: StatusConvite.pendente,
        dataEnvio: DateTime.now(),
        idCofre: cofreId,
        idUsuarioConvidador: idUsuarioConvidador,
        idUsuarioConvidado: usuarioDestino.id!,
      );

      await _firestoreService.criarConvite(novoConvite);

      _isloading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isloading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> responderConvite(Convite convite, bool aceitar) async {
    _isloading = true;
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

      _convitesRecebidos.removeWhere((c) => c.id == convite.id);
    } catch (e) {
      _errorMensage = e.toString();
    }

    _isloading = false;
    notifyListeners();
  }
}
