import 'package:cloud_firestore/cloud_firestore.dart';

class Safra {
  final String id;
  final String plantacao;
  final String tipo;
  final String maquinario;
  final String tempoColheita;
  final double custo;
  final String status;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Safra({
    required this.id,
    required this.plantacao,
    required this.tipo,
    required this.maquinario,
    required this.tempoColheita,
    required this.custo,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  static String _converterTempo(dynamic valor) {
    if (valor == null) return '';

    if (valor is num) {
      final horas = valor.floor();
      final minutos = ((valor - horas) * 60).round();

      final horasAjustadas = minutos == 60 ? horas + 1 : horas;
      final minutosAjustados = minutos == 60 ? 0 : minutos;

      return '${horasAjustadas.toString().padLeft(2, '0')}:'
          '${minutosAjustados.toString().padLeft(2, '0')}';
    }

    final texto = valor.toString().trim();

    if (RegExp(r'^\d+$').hasMatch(texto)) {
      return '${texto.padLeft(2, '0')}:00';
    }

    final formatoHora = RegExp(r'^(\d+):([0-5]?\d)$');
    final resultado = formatoHora.firstMatch(texto);

    if (resultado != null) {
      final horas = resultado.group(1)!.padLeft(2, '0');
      final minutos = resultado.group(2)!.padLeft(2, '0');

      return '$horas:$minutos';
    }

    return texto;
  }

  factory Safra.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final dados = documento.data() ?? {};

    return Safra(
      id: documento.id,
      plantacao: dados['plantacao'] ?? '',
      tipo: dados['tipo'] ?? 'Soja',
      maquinario: dados['maquinario'] ?? '',
      tempoColheita: _converterTempo(dados['tempoColheita']),
      custo: (dados['custo'] ?? 0).toDouble(),
      status: dados['status'] ?? 'Em desenvolvimento',
      createdAt: dados['createdAt'] as Timestamp?,
      updatedAt: dados['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'plantacao': plantacao,
      'tipo': tipo,
      'maquinario': maquinario,
      'tempoColheita': tempoColheita,
      'custo': custo,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}