import 'package:cloud_firestore/cloud_firestore.dart';

class Acerto {
  final String? id;
  final String idCofre;
  final String idUsuarioPagador;
  final String idUsuarioRecebedor;
  final double valor;
  final DateTime data;

  Acerto({
    this.id,
    required this.idCofre,
    required this.idUsuarioPagador,
    required this.idUsuarioRecebedor,
    required this.valor,
    required this.data,
  });

  // --- Conversão para Firestore ---
  Map<String, dynamic> toMap() {
    return {
      'idCofre': idCofre,
      'idUsuarioPagador': idUsuarioPagador,
      'idUsuarioRecebedor': idUsuarioRecebedor,
      'valor': valor,
      'data': Timestamp.fromDate(data),
    };
  }

  // --- Conversão de Firestore para Objeto ---
  static Acerto fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Acerto(
      id: doc.id,
      idCofre: data['idCofre'] as String,
      idUsuarioPagador: data['idUsuarioPagador'] as String,
      idUsuarioRecebedor: data['idUsuarioRecebedor'] as String,
      valor: (data['valor'] as num).toDouble(),
      data: (data['data'] as Timestamp).toDate(),
    );
  }
}