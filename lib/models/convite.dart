import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelbox/models/enums/statusConvite.dart';

class Convite {
  final String? id;

  StatusConvite status;
  DateTime dataEnvio;

  final String idCofre;
  final String idUsuarioConvidador;
  final String idUsuarioConvidado;

  Convite({
    this.id,
    required this.status,
    required this.dataEnvio,
    required this.idCofre,
    required this.idUsuarioConvidador,
    required this.idUsuarioConvidado,
  });

  factory Convite.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Convite(
      id: doc.id,
      status: StatusConvite.fromString(data['status'] as String),
      dataEnvio: (data['data_envio'] as Timestamp).toDate(),
      idCofre: data['id_cofre'] as String,
      idUsuarioConvidador: data['id_usuario_convidador'] as String,
      idUsuarioConvidado: data['id_usuario_convidado'] as String,
    );
  }


  /// Converte o objeto Convite para um mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'status': status.name, // Salva o enum como string
      'data_envio': dataEnvio, 
      'id_cofre': idCofre,
      'id_usuario_convidador': idUsuarioConvidador,
      'id_usuario_convidado': idUsuarioConvidado,
    };
  }

  
  Convite copyWith({
    String? id,
    StatusConvite? status,
    DateTime? dataEnvio,
    String? idCofre,
    String? idUsuarioConvidador,
    String? idUsuarioConvidado,
  }) {
    return Convite(
      id: id ?? this.id,
      status: status ?? this.status,
      dataEnvio: dataEnvio ?? this.dataEnvio,
      idCofre: idCofre ?? this.idCofre,
      idUsuarioConvidador: idUsuarioConvidador ?? this.idUsuarioConvidador,
      idUsuarioConvidado: idUsuarioConvidado ?? this.idUsuarioConvidado,
    );
  }


}
