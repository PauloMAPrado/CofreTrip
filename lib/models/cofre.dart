import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';


class Cofre {
  final String? id;

  String nome;
  String? descricao;
  int valorPlano;
  int despesasTotal; // para o futuro
  double totalArrecadado; // progresso (novo campo!)
  DateTime dataCriacao;
  DateTime? dataViagem;
  final String joinCode;
  final bool isFinalizado;

  Cofre({
    this.id,
    required this.nome,
    required this.valorPlano,
    required this.despesasTotal,
    this.totalArrecadado = 0.0, // Inicia zerado
    required this.dataCriacao,
    this.descricao,
    this.dataViagem,
    required this.joinCode,
    this.isFinalizado = false,
  });

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

  factory Cofre.novo({
    required String nome,
    required int valorPlano,
    DateTime? dataViagem,
  }) {
    return Cofre(
      nome: nome,
      valorPlano: valorPlano,
      despesasTotal: 0,
      totalArrecadado: 0.0,
      dataCriacao: DateTime.now(),
      dataViagem: dataViagem,
      joinCode: _generateJoinCode(6),
      isFinalizado: false,
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
      
      // CORREÇÃO 2: Conversão segura de num para int
      valorPlano: (data['valor_plano'] as num).toInt(),
      despesasTotal: (data['despesas_total'] as num).toInt(),

      totalArrecadado: (data['totalArrecadado'] as num?)?.toDouble() ?? 0.0,
      
      dataCriacao: (data['data_criacao'] as Timestamp).toDate(),
      dataViagem: data['data_viagem'] != null
          ? (data['data_viagem'] as Timestamp).toDate()
          : null,
      
      // Segurança extra: se não tiver joinCode (cofres antigos), gera vazio
      joinCode: data['joinCode'] as String? ?? '', 
      isFinalizado: data['isFinalizado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'valor_plano': valorPlano,
      'despesas_total': despesasTotal,
      'totalArrecadado': totalArrecadado,
      'data_criacao': dataCriacao,
      'data_viagem': dataViagem,
      'joinCode': joinCode,
      'isFinalizado': isFinalizado,
    };
  }

  Cofre copyWith({
    String? id,
    String? nome,
    String? descricao,
    int? valorPlano,
    int? despesasTotal,
    double? totalArrecadado,
    DateTime? dataCriacao,
    DateTime? dataViagem,
    String? joinCode,
    bool? isFinalizado,
  }) {
    return Cofre(
      // CORREÇÃO 1: Bug crítico resolvido (usando ??)
      id: id ?? this.id, 
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      valorPlano: valorPlano ?? this.valorPlano,
      despesasTotal: despesasTotal ?? this.despesasTotal,
      totalArrecadado: totalArrecadado ?? this.totalArrecadado,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataViagem: dataViagem ?? this.dataViagem,
      joinCode: joinCode ?? this.joinCode,
      isFinalizado: isFinalizado ?? this.isFinalizado,
    );
  }
}
