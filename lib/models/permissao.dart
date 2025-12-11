import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelbox/models/enums/nivelPermissao.dart';

class Permissao {
  final String? id;

  NivelPermissao nivelPermissao;

  final String idUsuario;
  final String idCofre;

  Permissao({
    this.id,
    required this.nivelPermissao,
    required this.idUsuario,
    required this.idCofre,
  });

  /// Converte um Documento do Firestore em um objeto Permissao.
  factory Permissao.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Permissao(
      id: doc.id,
      // Usa o helper 'fromString' do nosso enum
      nivelPermissao: NivelPermissao.fromString(
        data['nivel_permissao'] as String,
      ),
      idUsuario: data['id_usuario'] as String,
      idCofre: data['id_cofre'] as String,
    );
  }

  /// Converte o objeto Permissao para um mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'nivel_permissao': nivelPermissao.name,
      'id_usuario': idUsuario,
      'id_cofre': idCofre,
    };
  }
}
