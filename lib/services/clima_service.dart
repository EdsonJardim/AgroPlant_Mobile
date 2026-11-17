import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ClimaModel {
  final double temperatura;
  final double sensacaoTermica;
  final int umidade;
  final double vento;
  final double precipitacao;
  final int codigoClima;
  final bool duranteODia;
  final String horario;

  const ClimaModel({
    required this.temperatura,
    required this.sensacaoTermica,
    required this.umidade,
    required this.vento,
    required this.precipitacao,
    required this.codigoClima,
    required this.duranteODia,
    required this.horario,
  });

  factory ClimaModel.fromJson(Map<String, dynamic> json) {
    final atual = json['current'] as Map<String, dynamic>;

    return ClimaModel(
      temperatura: (atual['temperature_2m'] as num).toDouble(),
      sensacaoTermica:
          (atual['apparent_temperature'] as num).toDouble(),
      umidade: (atual['relative_humidity_2m'] as num).toInt(),
      vento: (atual['wind_speed_10m'] as num).toDouble(),
      precipitacao: (atual['precipitation'] as num).toDouble(),
      codigoClima: (atual['weather_code'] as num).toInt(),
      duranteODia: (atual['is_day'] as num).toInt() == 1,
      horario: atual['time'] as String,
    );
  }
}

class PrevisaoHora {
  final DateTime horario;
  final double temperatura;
  final int probabilidadeChuva;
  final double vento;

  const PrevisaoHora({
    required this.horario,
    required this.temperatura,
    required this.probabilidadeChuva,
    required this.vento,
  });
}

class ClimaDados {
  final ClimaModel atual;
  final List<PrevisaoHora> previsoes;

  const ClimaDados({
    required this.atual,
    required this.previsoes,
  });
}

class ClimaService {
  Future<ClimaDados> buscarClima({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,is_day',
        'hourly':
            'temperature_2m,precipitation_probability,wind_speed_10m',
        'forecast_days': '2',
        'timezone': 'auto',
      },
    );

    debugPrint('========== DIAGNÓSTICO DO CLIMA ==========');
    debugPrint('Coordenadas enviadas:');
    debugPrint('Latitude: $latitude');
    debugPrint('Longitude: $longitude');
    debugPrint('URL consultada: $uri');

    final resposta = await http.get(uri).timeout(
      const Duration(seconds: 15),
    );

    debugPrint('Status HTTP: ${resposta.statusCode}');

    if (resposta.statusCode != 200) {
      debugPrint('Erro retornado pela API: ${resposta.body}');
      throw Exception('Não foi possível consultar o clima.');
    }

    final dados = jsonDecode(resposta.body) as Map<String, dynamic>;

    debugPrint('Coordenadas reconhecidas pela API:');
    debugPrint('Latitude: ${dados['latitude']}');
    debugPrint('Longitude: ${dados['longitude']}');
    debugPrint('Fuso horário: ${dados['timezone']}');
    debugPrint('Abreviação: ${dados['timezone_abbreviation']}');
    debugPrint('Deslocamento UTC: ${dados['utc_offset_seconds']}');

    if (dados['current'] == null || dados['hourly'] == null) {
      throw Exception('Dados meteorológicos indisponíveis.');
    }

    final atual = ClimaModel.fromJson(dados);
    final horarioAtual = DateTime.parse(atual.horario);

    final hourly = dados['hourly'] as Map<String, dynamic>;
    final horarios = hourly['time'] as List<dynamic>;
    final temperaturas = hourly['temperature_2m'] as List<dynamic>;
    final chuvas = hourly['precipitation_probability'] as List<dynamic>;
    final ventos = hourly['wind_speed_10m'] as List<dynamic>;

    final previsoes = <PrevisaoHora>[];

    for (var i = 0; i < horarios.length; i++) {
      final horario = DateTime.parse(horarios[i] as String);

      if (horario.isBefore(horarioAtual)) {
        continue;
      }

      previsoes.add(
        PrevisaoHora(
          horario: horario,
          temperatura: (temperaturas[i] as num).toDouble(),
          probabilidadeChuva: (chuvas[i] as num).toInt(),
          vento: (ventos[i] as num).toDouble(),
        ),
      );

      if (previsoes.length == 24) {
        break;
      }
    }

    if (previsoes.isEmpty) {
      throw Exception('Previsão horária indisponível.');
    }

    debugPrint('Dados meteorológicos atuais:');
    debugPrint('Temperatura: ${atual.temperatura} °C');
    debugPrint('Sensação térmica: ${atual.sensacaoTermica} °C');
    debugPrint('Umidade: ${atual.umidade}%');
    debugPrint('Vento: ${atual.vento} km/h');
    debugPrint('Precipitação: ${atual.precipitacao} mm');
    debugPrint('Código do clima: ${atual.codigoClima}');
    debugPrint('Horário retornado: ${atual.horario}');
    debugPrint('Previsões horárias recebidas: ${previsoes.length}');
    debugPrint('==========================================');

    return ClimaDados(
      atual: atual,
      previsoes: previsoes,
    );
  }
}