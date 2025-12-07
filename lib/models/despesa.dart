import 'package:cloud_firestore/cloud_firestore.dart';

class Despesa {
  final String? id;
  final String idCofre;
  final String descricao;
  final double valorTotal;
  final String idUsuarioPagador;
  final DateTime data;
  
  // Lista de divisões: {idUsuario: valorDevido} para rastrear as dívidas individuais.
  // Ex: [{'idUsuario': 10.00}, {'idOutroUsuario': 20.00}]
  final List<Map<String, double>> divisao; 

  Despesa({
    this.id,
    required this.idCofre,
    required this.descricao,
    required this.valorTotal,
    required this.idUsuarioPagador,
    required this.data,
    required this.divisao,
  });

  // --- Conversão para Firestore ---
  Map<String, dynamic> toMap() {
    return {
      'idCofre': idCofre,
      'descricao': descricao,
      'valorTotal': valorTotal,
      'idUsuarioPagador': idUsuarioPagador,
      'data': Timestamp.fromDate(data),
      // Salva a lista de mapas diretamente
      'divisao': divisao, 
    };
  }

  // --- Conversão de Firestore para Objeto ---
  static Despesa fromMap(Map<String, dynamic> map, String id) {
    // Tratamento robusto para o campo 'divisao'
    List<dynamic> rawDivisao = map['divisao'] as List<dynamic>;
    
    // Mapeia a lista dinâmica de volta para List<Map<String, double>>
    List<Map<String, double>> parsedDivisao = rawDivisao.map((item) {
      // Cada item é um mapa onde o valor (devido) pode ser um 'int' ou 'double' ('num' no Dart)
      return Map<String, double>.from(item.map((key, value) => 
        MapEntry(key as String, (value as num).toDouble()))
      );
    }).toList();

    return Despesa(
      id: id,
      idCofre: map['idCofre'] as String,
      descricao: map['descricao'] as String,
      valorTotal: (map['valorTotal'] as num).toDouble(),
      idUsuarioPagador: map['idUsuarioPagador'] as String,
      data: (map['data'] as Timestamp).toDate(),
      divisao: parsedDivisao,
    );
  }
}