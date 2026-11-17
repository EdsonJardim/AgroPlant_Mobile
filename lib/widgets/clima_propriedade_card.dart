import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/clima_service.dart';

enum TipoGraficoClima {
  temperatura,
  chuva,
  vento,
}

class ClimaPropriedadeCard extends StatefulWidget {
  final double latitude;
  final double longitude;

  const ClimaPropriedadeCard({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ClimaPropriedadeCard> createState() =>
      _ClimaPropriedadeCardState();
}

class _ClimaPropriedadeCardState extends State<ClimaPropriedadeCard>
    with WidgetsBindingObserver {
  static const Color verde = Color(0xFF174D2A);
  static const Color bege = Color(0xFFE8DCC6);
  static const Duration intervaloAtualizacao = Duration(minutes: 30);

  final ClimaService _service = ClimaService();

  late Future<ClimaDados> _climaFuture;
  Timer? _timerAtualizacao;
  DateTime? _ultimaAtualizacao;

  TipoGraficoClima _tipoGrafico = TipoGraficoClima.temperatura;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _carregarClima();
    _iniciarAtualizacaoAutomatica();
  }

  @override
  void didUpdateWidget(covariant ClimaPropriedadeCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _atualizarClima();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final ultima = _ultimaAtualizacao;

      if (ultima == null ||
          DateTime.now().difference(ultima) >= intervaloAtualizacao) {
        _atualizarClima();
      }
    }
  }

  void _iniciarAtualizacaoAutomatica() {
    _timerAtualizacao?.cancel();

    _timerAtualizacao = Timer.periodic(
      intervaloAtualizacao,
      (_) {
        if (mounted) {
          _atualizarClima();
        }
      },
    );
  }

  void _carregarClima() {
    _ultimaAtualizacao = DateTime.now();

    _climaFuture = _service.buscarClima(
      latitude: widget.latitude,
      longitude: widget.longitude,
    );
  }

  void _atualizarClima() {
    if (!mounted) return;

    setState(_carregarClima);
  }

  @override
  void dispose() {
    _timerAtualizacao?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _descricaoClima(int codigo) {
    if (codigo == 0) return 'Céu limpo';
    if (codigo == 1) return 'Predominantemente limpo';
    if (codigo == 2) return 'Parcialmente nublado';
    if (codigo == 3) return 'Nublado';
    if (codigo == 45 || codigo == 48) return 'Neblina';
    if ([51, 53, 55].contains(codigo)) return 'Garoa';
    if ([56, 57].contains(codigo)) return 'Garoa congelante';
    if ([61, 63, 65].contains(codigo)) return 'Chuva';
    if ([66, 67].contains(codigo)) return 'Chuva congelante';
    if ([71, 73, 75, 77].contains(codigo)) return 'Neve';
    if ([80, 81, 82].contains(codigo)) return 'Pancadas de chuva';
    if ([85, 86].contains(codigo)) return 'Pancadas de neve';
    if (codigo == 95) return 'Trovoadas';
    if ([96, 99].contains(codigo)) return 'Trovoadas com granizo';

    return 'Condição indisponível';
  }

  IconData _iconeClima(int codigo, bool dia) {
    if (codigo == 0) {
      return dia ? Icons.wb_sunny : Icons.nightlight_round;
    }

    if ([1, 2].contains(codigo)) {
      return dia ? Icons.wb_cloudy : Icons.cloud;
    }

    if ([3, 45, 48].contains(codigo)) {
      return Icons.cloud;
    }

    if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82]
        .contains(codigo)) {
      return Icons.cloudy_snowing;
    }

    if ([95, 96, 99].contains(codigo)) {
      return Icons.thunderstorm;
    }

    if ([71, 73, 75, 77, 85, 86].contains(codigo)) {
      return Icons.ac_unit;
    }

    return Icons.cloud_outlined;
  }

  Widget _informacao(
    IconData icone,
    String titulo,
    String valor,
    Color cor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icone, color: cor, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: cor.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _tituloGrafico() {
    switch (_tipoGrafico) {
      case TipoGraficoClima.temperatura:
        return 'Temperatura nas próximas 24 horas';
      case TipoGraficoClima.chuva:
        return 'Probabilidade de chuva nas próximas 24 horas';
      case TipoGraficoClima.vento:
        return 'Velocidade do vento nas próximas 24 horas';
    }
  }

  double _valorMaximo(List<PrevisaoHora> previsoes) {
    switch (_tipoGrafico) {
      case TipoGraficoClima.temperatura:
        final maior = previsoes
            .map((p) => p.temperatura)
            .reduce((a, b) => a > b ? a : b);

        return maior + 3;

      case TipoGraficoClima.chuva:
        return 100;

      case TipoGraficoClima.vento:
        final maior = previsoes
            .map((p) => p.vento)
            .reduce((a, b) => a > b ? a : b);

        return maior < 5 ? 10 : maior + 5;
    }
  }

  double _valorMinimo(List<PrevisaoHora> previsoes) {
    switch (_tipoGrafico) {
      case TipoGraficoClima.temperatura:
        final menor = previsoes
            .map((p) => p.temperatura)
            .reduce((a, b) => a < b ? a : b);

        return menor - 3;

      case TipoGraficoClima.chuva:
        return 0;

      case TipoGraficoClima.vento:
        return 0;
    }
  }

  double _valorGrafico(PrevisaoHora previsao) {
    switch (_tipoGrafico) {
      case TipoGraficoClima.temperatura:
        return previsao.temperatura;
      case TipoGraficoClima.chuva:
        return previsao.probabilidadeChuva.toDouble();
      case TipoGraficoClima.vento:
        return previsao.vento;
    }
  }

  String _unidadeGrafico() {
    switch (_tipoGrafico) {
      case TipoGraficoClima.temperatura:
        return '°C';
      case TipoGraficoClima.chuva:
        return '%';
      case TipoGraficoClima.vento:
        return 'km/h';
    }
  }

  Widget _seletorGrafico(
    TipoGraficoClima tipo,
    String titulo,
    Color corTexto,
    Color corDetalhe,
  ) {
    final selecionado = _tipoGrafico == tipo;

    return ChoiceChip(
      label: Text(titulo),
      selected: selecionado,
      onSelected: (_) {
        setState(() => _tipoGrafico = tipo);
      },
      selectedColor: corDetalhe.withValues(alpha: 0.18),
      backgroundColor: Colors.transparent,
      labelStyle: TextStyle(
        color: selecionado ? corDetalhe : corTexto,
        fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: selecionado ? corDetalhe : corTexto.withValues(alpha: 0.18),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _grafico(
    List<PrevisaoHora> previsoes,
    Color corTexto,
    Color corSecundaria,
    Color corDetalhe,
  ) {
    final valores = previsoes.map(_valorGrafico).toList();
    final minimo = _valorMinimo(previsoes);
    final maximo = _valorMaximo(previsoes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tituloGrafico(),
          style: TextStyle(
            color: corTexto,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Previsão horária • ${previsoes.length} registros',
          style: TextStyle(
            color: corSecundaria,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 175,
          width: double.infinity,
          child: CustomPaint(
            painter: _GraficoClimaPainter(
              previsoes: previsoes,
              valores: valores,
              minimo: minimo,
              maximo: maximo,
              tipo: _tipoGrafico,
              cor: corDetalhe,
              corGrade: corTexto.withValues(alpha: 0.12),
              corTexto: corSecundaria,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Unidade: ${_unidadeGrafico()}',
            style: TextStyle(
              color: corSecundaria,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final corTexto = escuro ? Colors.white : verde;
    final corSecundaria =
        escuro ? Colors.white70 : const Color(0xFF62594B);
    final corFundo =
        escuro ? const Color(0xFF202B23) : const Color(0xFFF7F2E8);
    final corDetalhe =
        escuro ? const Color(0xFF78A878) : verde;

    return FutureBuilder<ClimaDados>(
      future: _climaFuture,
      builder: (context, snapshot) {
        final carregando =
            snapshot.connectionState == ConnectionState.waiting;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: escuro ? Colors.white12 : bege,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_outlined, color: corTexto),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Clima na propriedade',
                      style: TextStyle(
                        color: corTexto,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: carregando ? null : _atualizarClima,
                    tooltip: 'Atualizar clima',
                    icon: const Icon(Icons.refresh),
                    color: corTexto,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (carregando)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: CircularProgressIndicator(color: corTexto),
                  ),
                )
              else if (snapshot.hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Não foi possível carregar o clima e a previsão. '
                          'Verifique sua conexão e tente novamente.',
                          style: TextStyle(
                            color: corSecundaria,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _atualizarClima,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              else if (snapshot.hasData) ...[
                _conteudoClima(
                  snapshot.data!,
                  corTexto,
                  corSecundaria,
                  corDetalhe,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _conteudoClima(
    ClimaDados dados,
    Color corTexto,
    Color corSecundaria,
    Color corDetalhe,
  ) {
    final atual = dados.atual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              _iconeClima(atual.codigoClima, atual.duranteODia),
              size: 52,
              color: const Color(0xFFD69B36),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${atual.temperatura.round()}°C',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: corTexto,
                    ),
                  ),
                  Text(
                    _descricaoClima(atual.codigoClima),
                    style: TextStyle(
                      color: corSecundaria,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 90,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          children: [
            _informacao(
              Icons.thermostat,
              'Sensação térmica',
              '${atual.sensacaoTermica.round()}°C',
              corTexto,
            ),
            _informacao(
              Icons.water_drop_outlined,
              'Umidade',
              '${atual.umidade}%',
              corTexto,
            ),
            _informacao(
              Icons.air,
              'Vento',
              '${atual.vento.round()} km/h',
              corTexto,
            ),
            _informacao(
              Icons.cloudy_snowing,
              'Precipitação atual',
              '${atual.precipitacao.toStringAsFixed(1)} mm',
              corTexto,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: corTexto.withValues(alpha: 0.12)),
        const SizedBox(height: 8),
        Text(
          'Previsão do tempo',
          style: TextStyle(
            color: corTexto,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _seletorGrafico(
              TipoGraficoClima.temperatura,
              'Temperatura',
              corTexto,
              corDetalhe,
            ),
            _seletorGrafico(
              TipoGraficoClima.chuva,
              'Chuva',
              corTexto,
              corDetalhe,
            ),
            _seletorGrafico(
              TipoGraficoClima.vento,
              'Vento',
              corTexto,
              corDetalhe,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _grafico(
          dados.previsoes,
          corTexto,
          corSecundaria,
          corDetalhe,
        ),
        const SizedBox(height: 12),
        Text(
          'Dados atuais • ${atual.horario.replaceFirst('T', ' ')}',
          style: TextStyle(
            fontSize: 10,
            color: corSecundaria,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Previsão meteorológica estimada para as coordenadas cadastradas.',
          style: TextStyle(
            fontSize: 10,
            color: corSecundaria,
          ),
        ),
      ],
    );
  }
}

class _GraficoClimaPainter extends CustomPainter {
  final List<PrevisaoHora> previsoes;
  final List<double> valores;
  final double minimo;
  final double maximo;
  final TipoGraficoClima tipo;
  final Color cor;
  final Color corGrade;
  final Color corTexto;

  _GraficoClimaPainter({
    required this.previsoes,
    required this.valores,
    required this.minimo,
    required this.maximo,
    required this.tipo,
    required this.cor,
    required this.corGrade,
    required this.corTexto,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (valores.isEmpty) return;

    const esquerda = 34.0;
    const direita = 8.0;
    const topo = 10.0;
    const inferior = 28.0;

    final largura = size.width - esquerda - direita;
    final altura = size.height - topo - inferior;

    if (largura <= 0 || altura <= 0) return;

    final grade = Paint()
      ..color = corGrade
      ..strokeWidth = 1;

    final textoStyle = TextStyle(
      color: corTexto,
      fontSize: 9,
    );

    final intervalo = (maximo - minimo).abs() < 0.001
        ? 1.0
        : maximo - minimo;

    for (var i = 0; i <= 4; i++) {
      final y = topo + altura * i / 4;

      canvas.drawLine(
        Offset(esquerda, y),
        Offset(size.width - direita, y),
        grade,
      );

      final valor = maximo - intervalo * i / 4;
      final texto = tipo == TipoGraficoClima.chuva
          ? '${valor.round()}'
          : valor.round().toString();

      _desenharTexto(
        canvas,
        texto,
        Offset(0, y - 6),
        textoStyle,
        largura: esquerda - 5,
        alinhamento: TextAlign.right,
      );
    }

    final pontos = <Offset>[];

    for (var i = 0; i < valores.length; i++) {
      final x = valores.length == 1
          ? esquerda + largura / 2
          : esquerda + largura * i / (valores.length - 1);

      final proporcao = ((valores[i] - minimo) / intervalo)
          .clamp(0.0, 1.0)
          .toDouble();

      final y = topo + altura * (1 - proporcao);

      pontos.add(Offset(x, y));
    }

    if (tipo == TipoGraficoClima.chuva) {
      final barra = Paint()
        ..color = cor.withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;

      final larguraBarra = math.max(
        3.0,
        math.min(10.0, largura / valores.length * 0.55),
      ).toDouble();

      for (final ponto in pontos) {
        final base = topo + altura;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(
              ponto.dx - larguraBarra / 2,
              ponto.dy,
              ponto.dx + larguraBarra / 2,
              base,
            ),
            const Radius.circular(3),
          ),
          barra,
        );
      }
    } else {
      final caminho = Path();

      for (var i = 0; i < pontos.length; i++) {
        if (i == 0) {
          caminho.moveTo(pontos[i].dx, pontos[i].dy);
        } else {
          caminho.lineTo(pontos[i].dx, pontos[i].dy);
        }
      }

      final preenchimento = Path.from(caminho)
        ..lineTo(pontos.last.dx, topo + altura)
        ..lineTo(pontos.first.dx, topo + altura)
        ..close();

      canvas.drawPath(
        preenchimento,
        Paint()
          ..color = cor.withValues(alpha: 0.12)
          ..style = PaintingStyle.fill,
      );

      canvas.drawPath(
        caminho,
        Paint()
          ..color = cor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      final pontoPaint = Paint()
        ..color = cor
        ..style = PaintingStyle.fill;

      for (final ponto in pontos) {
        canvas.drawCircle(ponto, 2.5, pontoPaint);
      }
    }

    final quantidadeRotulos =
        math.min(5, previsoes.length).toInt();

    for (var i = 0; i < quantidadeRotulos; i++) {
      final indice = quantidadeRotulos == 1
          ? 0
          : ((previsoes.length - 1) * i / (quantidadeRotulos - 1))
              .round();

      final horario = previsoes[indice].horario;
      final texto =
          '${horario.hour.toString().padLeft(2, '0')}:00';

      final x = pontos[indice].dx;

      _desenharTexto(
        canvas,
        texto,
        Offset(x - 18, topo + altura + 7),
        textoStyle,
        largura: 38,
        alinhamento: TextAlign.center,
      );
    }
  }

  void _desenharTexto(
    Canvas canvas,
    String texto,
    Offset posicao,
    TextStyle estilo, {
    required double largura,
    TextAlign alinhamento = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textDirection: TextDirection.ltr,
      textAlign: alinhamento,
      maxLines: 1,
    )..layout(maxWidth: largura);

    painter.paint(canvas, posicao);
  }

  @override
  bool shouldRepaint(covariant _GraficoClimaPainter oldDelegate) {
    return oldDelegate.previsoes != previsoes ||
        oldDelegate.tipo != tipo ||
        oldDelegate.cor != cor ||
        oldDelegate.minimo != minimo ||
        oldDelegate.maximo != maximo;
  }
}