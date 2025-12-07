import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String? id;

  String nome;
  String _email;
  String? telefone;
  String _cpf;

  Usuario({
    this.id,
    required this.nome,
    required String email,
    required String cpf,
    this.telefone,
  }) : _email = email,
       _cpf = cpf;

  String get email => _email;
  String get cpf => _cpf;

  void set novoEmail(String novoEmail) {
    _email = novoEmail;
  }

  factory Usuario.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!; // Pega o mapa de dados
    return Usuario(
      id: doc.id, // Pega o ID do documento
      nome: data['nome'] as String,
      email: data['email'] as String,
      cpf: data['cpf'] as String,
      telefone: data['telefone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
    };
  }

  Usuario copyWith({
    String? nome,
    String? email,
    String? telefone,
    String? cpf,
  }) {
    return Usuario(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      cpf: cpf ?? this.cpf,
    );
  }
}
