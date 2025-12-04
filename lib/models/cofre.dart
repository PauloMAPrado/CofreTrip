import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';


class Cofre {
  // ID privado, final, mas anulável para novos cofres
  final String? id;

  String nome;
  String? descricao;
  int valorPlano;
  int despesasTotal;
  DateTime dataCriacao;
  DateTime? dataViagem;
  final String joinCode;

  Cofre({
    this.id,
    required this.nome,
    required this.valorPlano,
    required this.despesasTotal,
    required this.dataCriacao,
    this.descricao,
    this.dataViagem,
    required this.joinCode,
  });

  // Helper para gerar um código aleatório (você pode mover para outro lugar)
  static String _generateJoinCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }

  /// Construtor "Vazio" para criar um novo cofre
  /// Ele já gera o código automaticamente!
  factory Cofre.novo({
    required String nome,
    required int valorPlano,
    required DateTime dataViagem, // Corrigido para dataViagem (Data de Início da Viagem)
  }) {
    // Note que dataViagem no Model é a data de início da viagem
    return Cofre(
      nome: nome,
      valorPlano: valorPlano,
      despesasTotal: 0,
      dataCriacao: DateTime.now(), // Data atual
      dataViagem: dataViagem, // Data de Início da Viagem do formulário
      joinCode: _generateJoinCode(6), // Gera um código de 6 dígitos
      // 'id' fica nulo, esperando o Firestore
    );
  }

  // --- Métodos de Conversão (JSON) ---

  /// Cria um objeto Cofre a partir de um mapa JSON (vindo do back-end).
  factory Cofre.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Cofre(
      id: doc.id,
      nome: data['nome'] as String,
      descricao: data['descricao'] as String?,
      valorPlano: data['valor_plano'] as int,
      despesasTotal: data['despesas_total'] as int,
      // Converte o Timestamp do Firebase para DateTime
      dataCriacao: (data['data_criacao'] as Timestamp).toDate(),
      dataViagem: data['data_viagem'] != null
          ? (data['data_viagem'] as Timestamp).toDate()
          : null,
      joinCode: data['joinCode'] as String,
    );
  }

  /// Converte o objeto Cofre para um mapa JSON (para enviar ao Firebase).
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'valor_plano': valorPlano,
      'despesas_total': despesasTotal,
      // O Firebase converte DateTime para Timestamp automaticamente
      'data_criacao': dataCriacao,
      'data_viagem': dataViagem,
      'joinCode':joinCode,
    };
  }

  /// Cria uma cópia do cofre com valores atualizados.
  Cofre copyWith({
    String? id,
    String? nome,
    String? descricao,
    int? valorPlano,
    int? despesasTotal,
    DateTime? dataCriacao,
    DateTime? dataViagem,
    String? joinCode,
  }) {
    return Cofre(
      id: id, // Preserva o ID original
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      valorPlano: valorPlano ?? this.valorPlano,
      despesasTotal: despesasTotal ?? this.despesasTotal,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataViagem: dataViagem ?? this.dataViagem,
      joinCode: joinCode ?? this.joinCode,
    );
  }
}
