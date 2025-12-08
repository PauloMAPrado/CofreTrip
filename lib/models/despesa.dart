import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelbox/models/enums/categoriaDespesa.dart';
import 'package:travelbox/models/enums/tipoDespesa.dart';



class Despesa {
  final String? id;
  final String idCofre;
  final String titulo;
  final double valor;
  final TipoDespesa tipo;
  final CategoriaDespesa categoria;
  
  // Campos para Despesa Real (Nulos se for Planejada)
  final String? pagoPorId;    // Quem pagou
  final DateTime? data;       // Data do gasto

  Despesa({
    this.id,
    required this.idCofre,
    required this.titulo,
    required this.valor,
    required this.tipo,
    required this.categoria,
    this.pagoPorId,
    this.data,
  });

  factory Despesa.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Despesa(
      id: doc.id,
      idCofre: data['id_cofre'] as String,
      titulo: data['titulo'] as String,
      valor: (data['valor'] as num).toDouble(),
      
      // Converte String do banco para Enum
      tipo: TipoDespesa.values.firstWhere((e) => e.name == data['tipo']),
      categoria: CategoriaDespesa.values.firstWhere((e) => e.name == data['categoria']),
      
      pagoPorId: data['pago_por_id'] as String?,
      data: data['data'] != null ? (data['data'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cofre': idCofre,
      'titulo': titulo,
      'valor': valor,
      'tipo': tipo.name, // Salva como string "planejada" ou "real"
      'categoria': categoria.name,
      'pago_por_id': pagoPorId,
      'data': data,
    };
  }
}