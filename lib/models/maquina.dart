import 'package:cloud_firestore/cloud_firestore.dart';

class Maquina {
  final String id;
  final String nome;
  final String tipo;
  final String status;
  final String horasUso;
  final String ultimaManutencao;
  final String proximaManutencao;
  final String obs;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Maquina({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.status,
    required this.horasUso,
    required this.ultimaManutencao,
    required this.proximaManutencao,
    required this.obs,
    this.createdAt,
    this.updatedAt,
  });

  factory Maquina.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final dados = documento.data() ?? {};
    final valorHoras = dados['horasUso'];

    String horasFormatadas;

    if (valorHoras is num) {
      final partes = valorHoras.toStringAsFixed(2).split('.');
      var horas = int.tryParse(partes[0]) ?? 0;
      var minutos = int.tryParse(partes[1]) ?? 0;

      horas += minutos ~/ 60;
      minutos %= 60;

      horasFormatadas =
          '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}';
    } else {
      horasFormatadas = valorHoras?.toString() ?? '00:00';
    }

    return Maquina(
      id: documento.id,
      nome: dados['nome'] ?? '',
      tipo: dados['tipo'] ?? 'Trator',
      status: dados['status'] ?? 'Operacional',
      horasUso: horasFormatadas,
      ultimaManutencao: dados['ultimaManutencao'] ?? '',
      proximaManutencao: dados['proximaManutencao'] ?? '',
      obs: dados['obs'] ?? '',
      createdAt: dados['createdAt'] as Timestamp?,
      updatedAt: dados['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'tipo': tipo,
      'status': status,
      'horasUso': horasUso,
      'ultimaManutencao': ultimaManutencao,
      'proximaManutencao': proximaManutencao,
      'obs': obs,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}