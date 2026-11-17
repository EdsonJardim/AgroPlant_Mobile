import 'package:cloud_firestore/cloud_firestore.dart';

class Estoque {
  final String id;
  final String produto;
  final String categoria;
  final double quantidade;
  final String unidade;
  final double preco;
  final String data;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Estoque({
    required this.id,
    required this.produto,
    required this.categoria,
    required this.quantidade,
    required this.unidade,
    required this.preco,
    required this.data,
    this.createdAt,
    this.updatedAt,
  });

  factory Estoque.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final dados = documento.data() ?? {};

    return Estoque(
      id: documento.id,
      produto: dados['produto'] ?? '',
      categoria: dados['categoria'] ?? '',
      quantidade: (dados['quantidade'] ?? 0).toDouble(),
      unidade: dados['unidade'] ?? '',
      preco: (dados['preco'] ?? 0).toDouble(),
      data: dados['data'] ?? '',
      createdAt: dados['createdAt'] as Timestamp?,
      updatedAt: dados['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'produto': produto,
      'categoria': categoria,
      'quantidade': quantidade,
      'unidade': unidade,
      'preco': preco,
      'data': data,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}