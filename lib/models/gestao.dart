import 'package:cloud_firestore/cloud_firestore.dart';

class Gestao {
  final String id;
  final String tipo;
  final String descricao;
  final String categoria;
  final double valor;
  final String data;
  final String mes;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Gestao({
    required this.id,
    required this.tipo,
    required this.descricao,
    required this.categoria,
    required this.valor,
    required this.data,
    required this.mes,
    this.createdAt,
    this.updatedAt,
  });

  factory Gestao.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final dados = documento.data() ?? {};

    return Gestao(
      id: documento.id,
      tipo: dados['tipo'] ?? '',
      descricao: dados['descricao'] ?? '',
      categoria: dados['categoria'] ?? '',
      valor: (dados['valor'] ?? 0).toDouble(),
      data: dados['data'] ?? '',
      mes: dados['mes'] ?? '',
      createdAt: dados['createdAt'] as Timestamp?,
      updatedAt: dados['updatedAt'] as Timestamp?,
    );
  }
}