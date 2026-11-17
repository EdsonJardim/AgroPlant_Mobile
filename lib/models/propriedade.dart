import 'package:cloud_firestore/cloud_firestore.dart';

class PropriedadeModel {
  final String id;
  final String nome;
  final String endereco;
  final double latitude;
  final double longitude;
  final double areaHectares;
  final DateTime? criadoEm;

  PropriedadeModel({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.latitude,
    required this.longitude,
    required this.areaHectares,
    this.criadoEm,
  });

  factory PropriedadeModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final dados = doc.data()!;

    return PropriedadeModel(
      id: doc.id,
      nome: dados['nome'] ?? '',
      endereco: dados['endereco'] ?? '',
      latitude: (dados['latitude'] ?? 0).toDouble(),
      longitude: (dados['longitude'] ?? 0).toDouble(),
      areaHectares: (dados['areaHectares'] ?? 0).toDouble(),
      criadoEm: (dados['criadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'endereco': endereco,
      'latitude': latitude,
      'longitude': longitude,
      'areaHectares': areaHectares,
    };
  }
}