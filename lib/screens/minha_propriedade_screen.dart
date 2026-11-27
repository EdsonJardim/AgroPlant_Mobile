import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../config/arcgis_config.dart';
import '../models/propriedade.dart';
import '../services/propriedade_service.dart';
import '../widgets/agroplant_app_bar.dart';
import '../widgets/clima_propriedade_card.dart';

class MinhaPropriedadeScreen extends StatefulWidget {
  const MinhaPropriedadeScreen({super.key});

  @override
  State<MinhaPropriedadeScreen> createState() => _MinhaPropriedadeScreenState();
}

class _MinhaPropriedadeScreenState extends State<MinhaPropriedadeScreen> {
  static const Color verde = Color(0xFF174D2A);
  static const Color bege = Color(0xFFE8DCC6);
  static const Color begeClaro = Color(0xFFF7F2E8);
  static const Color textoSecundario = Color(0xFF62594B);

  final PropriedadeService _service = PropriedadeService();

  void _abrirFormulario({PropriedadeModel? propriedade}) {
    if (propriedade == null) {
      context.push('/propriedade/nova');
    } else {
      context.push('/propriedade/editar/${propriedade.id}');
    }
  }

  Future<void> _excluirPropriedade(PropriedadeModel propriedade) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        final escuro = Theme.of(context).brightness == Brightness.dark;

        final corFundo = escuro ? const Color(0xFF202B23) : begeClaro;
        final corTitulo = escuro ? const Color(0xFFE8F0E8) : verde;
        final corTexto = escuro ? Colors.white70 : textoSecundario;
        final corCancelar = escuro ? const Color(0xFF78A878) : verde;

        return AlertDialog(
          backgroundColor: corFundo,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: Text(
            'Excluir propriedade',
            style: TextStyle(
              color: corTitulo,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deseja realmente excluir "${propriedade.nome}"?',
            style: TextStyle(color: corTexto, fontSize: 16, height: 1.5),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: corCancelar,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Excluir',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await _service.excluirPropriedade(propriedade.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Propriedade excluída com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir propriedade: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final corFundo = escuro ? const Color(0xFF121A14) : bege;
    final corCartao = escuro ? const Color(0xFF202B23) : Colors.white;
    final corTexto = escuro ? Colors.white : verde;
    final corSecundaria = escuro ? Colors.white70 : textoSecundario;
    final corDetalhe = escuro ? const Color(0xFF78A878) : verde;

    return Scaffold(
      backgroundColor: corFundo,
      appBar: AgroPlantAppBar(
        backgroundColor: escuro
            ? const Color(0xFF202B23)
            : const Color(0xFFF7F2E8),
        foregroundColor: corTexto,
        fallbackRoute: '/home',
        title: Text(
          'Minha Propriedade',
          style: TextStyle(
            color: corTexto,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<List<PropriedadeModel>>(
        stream: _service.observarPropriedades(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar suas propriedades.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: corTexto),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: corDetalhe));
          }

          final propriedades = snapshot.data ?? [];
          final total = propriedades.length;
          final restantes = PropriedadeService.limitePropriedades - total;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: corCartao,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.agriculture_outlined,
                          color: corDetalhe,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Suas propriedades rurais',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: corTexto,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cadastre suas propriedades para acompanhar '
                      'a localização e preparar o monitoramento por satélite.',
                      style: TextStyle(color: corSecundaria, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: total / PropriedadeService.limitePropriedades,
                        minHeight: 9,
                        backgroundColor: escuro ? Colors.white12 : bege,
                        valueColor: AlwaysStoppedAnimation(corDetalhe),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$total de ${PropriedadeService.limitePropriedades} '
                      'propriedades cadastradas · $restantes vagas disponíveis',
                      style: TextStyle(
                        color: corSecundaria,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: total < PropriedadeService.limitePropriedades
                            ? () => _abrirFormulario()
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: corDetalhe,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: const Text(
                          'Cadastrar propriedade',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (total >= PropriedadeService.limitePropriedades) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Você atingiu o limite de propriedades do plano gratuito.',
                        style: TextStyle(color: corSecundaria, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Propriedades cadastradas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: corTexto,
                ),
              ),
              const SizedBox(height: 12),
              if (propriedades.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: corCartao,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.map_outlined, size: 54, color: corDetalhe),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma propriedade cadastrada',
                        style: TextStyle(
                          color: corTexto,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cadastre sua primeira propriedade para começar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: corSecundaria),
                      ),
                    ],
                  ),
                ),
              ...propriedades.map(
                (propriedade) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: corCartao,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: corDetalhe.withValues(alpha: 0.12),
                          child: Icon(
                            Icons.landscape_outlined,
                            color: corDetalhe,
                          ),
                        ),
                        title: Text(
                          propriedade.nome,
                          style: TextStyle(
                            color: corTexto,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${propriedade.areaHectares} hectares\n'
                            '${propriedade.endereco.isEmpty ? 'Endereço não informado' : propriedade.endereco}',
                            style: TextStyle(color: corSecundaria, height: 1.5),
                          ),
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (opcao) {
                            if (opcao == 'editar') {
                              _abrirFormulario(propriedade: propriedade);
                            } else if (opcao == 'excluir') {
                              _excluirPropriedade(propriedade);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                            PopupMenuItem(
                              value: 'excluir',
                              child: Text('Excluir'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: ClimaPropriedadeCard(
                          key: ValueKey(propriedade.id),
                          latitude: propriedade.latitude,
                          longitude: propriedade.longitude,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PropriedadeFormularioScreen extends StatefulWidget {
  final PropriedadeModel? propriedade;

  const PropriedadeFormularioScreen({super.key, this.propriedade});

  @override
  State<PropriedadeFormularioScreen> createState() =>
      _PropriedadeFormularioScreenState();
}

class _PropriedadeFormularioScreenState
    extends State<PropriedadeFormularioScreen> {
  static const Color verde = Color(0xFF174D2A);

  static const LatLng _localizacaoPadrao = LatLng(-21.517, -48.394);

  final PropriedadeService _service = PropriedadeService();
  final MapController _mapController = MapController();

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _areaController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  LatLng? _localizacao;
  bool _salvando = false;
  bool _obtendoLocalizacao = false;

  bool get _editando => widget.propriedade != null;

  @override
  void initState() {
    super.initState();

    final propriedade = widget.propriedade;

    if (propriedade != null) {
      _nomeController.text = propriedade.nome;
      _enderecoController.text = propriedade.endereco;
      _areaController.text = propriedade.areaHectares.toString();
      _latitudeController.text = propriedade.latitude.toString();
      _longitudeController.text = propriedade.longitude.toString();

      _localizacao = LatLng(propriedade.latitude, propriedade.longitude);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _obterLocalizacaoAtual();
        }
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _enderecoController.dispose();
    _areaController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _obterLocalizacaoAtual() async {
    if (_obtendoLocalizacao) return;

    setState(() => _obtendoLocalizacao = true);

    try {
      final servicoAtivo = await Geolocator.isLocationServiceEnabled();

      if (!servicoAtivo) {
        throw Exception(
          'Ative o GPS do dispositivo para identificar sua localização.',
        );
      }

      LocationPermission permissao = await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied) {
        throw Exception('Permissão de localização não concedida.');
      }

      if (permissao == LocationPermission.deniedForever) {
        throw Exception(
          'A permissão de localização foi bloqueada. '
          'Libere o acesso nas configurações do aplicativo.',
        );
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final ponto = LatLng(posicao.latitude, posicao.longitude);

      setState(() {
        _localizacao = ponto;
        _latitudeController.text = ponto.latitude.toStringAsFixed(6);
        _longitudeController.text = ponto.longitude.toStringAsFixed(6);
      });

      _mapController.move(ponto, 16);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localização atual identificada com sucesso!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _obtendoLocalizacao = false);
      }
    }
  }

  void _selecionarLocalizacao(LatLng ponto) {
    setState(() {
      _localizacao = ponto;
      _latitudeController.text = ponto.latitude.toStringAsFixed(6);
      _longitudeController.text = ponto.longitude.toStringAsFixed(6);
    });
  }

  void _aplicarCoordenadas() {
    final latitude = double.tryParse(
      _latitudeController.text.trim().replaceAll(',', '.'),
    );

    final longitude = double.tryParse(
      _longitudeController.text.trim().replaceAll(',', '.'),
    );

    if (latitude == null ||
        longitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe coordenadas válidas.')),
      );
      return;
    }

    final ponto = LatLng(latitude, longitude);

    setState(() {
      _localizacao = ponto;
    });

    _mapController.move(ponto, 15);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_localizacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a localização da propriedade no mapa.'),
        ),
      );
      return;
    }

    final area = double.parse(_areaController.text.trim().replaceAll(',', '.'));

    setState(() => _salvando = true);

    try {
      if (_editando) {
        final propriedade = PropriedadeModel(
          id: widget.propriedade!.id,
          nome: _nomeController.text.trim(),
          endereco: _enderecoController.text.trim(),
          latitude: _localizacao!.latitude,
          longitude: _localizacao!.longitude,
          areaHectares: area,
          criadoEm: widget.propriedade!.criadoEm,
        );

        await _service.atualizarPropriedade(propriedade);
      } else {
        await _service.cadastrarPropriedade(
          nome: _nomeController.text.trim(),
          endereco: _enderecoController.text.trim(),
          latitude: _localizacao!.latitude,
          longitude: _localizacao!.longitude,
          areaHectares: area,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Propriedade atualizada com sucesso!'
                : 'Propriedade cadastrada com sucesso!',
          ),
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final corFundo = escuro ? const Color(0xFF121A14) : const Color(0xFFE8DCC6);
    final corCartao = escuro ? const Color(0xFF202B23) : Colors.white;
    final corTexto = escuro ? Colors.white : verde;
    final corDetalhe = escuro ? const Color(0xFF78A878) : verde;

    final centro = _localizacao ?? _localizacaoPadrao;

    return Scaffold(
      backgroundColor: corFundo,
      appBar: AgroPlantAppBar(
        backgroundColor: escuro
            ? const Color(0xFF202B23)
            : const Color(0xFFF7F2E8),
        foregroundColor: corTexto,
        fallbackRoute: '/home',
        title: Text(
          _editando ? 'Editar propriedade' : 'Nova propriedade',
          style: TextStyle(
            color: corTexto,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: corCartao,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações da propriedade',
                    style: TextStyle(
                      color: corTexto,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da propriedade',
                      prefixIcon: Icon(Icons.agriculture_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Informe o nome da propriedade.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _enderecoController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço ou referência',
                      hintText: 'Cidade, bairro ou referência',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _areaController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Área em hectares',
                      prefixIcon: Icon(Icons.square_foot_outlined),
                      suffixText: 'ha',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      final area = double.tryParse(
                        (valor ?? '').trim().replaceAll(',', '.'),
                      );

                      if (area == null || area <= 0) {
                        return 'Informe uma área válida.';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Localização no mapa',
              style: TextStyle(
                color: corTexto,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no mapa para marcar a localização da propriedade.',
              style: TextStyle(
                color: escuro ? Colors.white70 : const Color(0xFF62594B),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 300,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: centro,
                    initialZoom: _localizacao == null ? 12 : 14,
                    onTap: (tapPosition, ponto) {
                      _selecionarLocalizacao(ponto);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                      userAgentPackageName: 'com.example.agroplant_mobile',
                      maxNativeZoom: 19,
                    ),
                    TileLayer(
                      urlTemplate: ArcgisConfig.satelliteUrl,
                      tileDimension: 512,
                      zoomOffset: -1,
                      maxNativeZoom: 19,
                      userAgentPackageName: 'com.example.agroplant_mobile',
                    ),
                    if (_localizacao != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _localizacao!,
                            width: 50,
                            height: 55,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'Powered by Esri | Sources: Esri, TomTom, Garmin, FAO, NOAA, USGS, OpenStreetMap contributors e GIS User Community',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _obtendoLocalizacao ? null : _obterLocalizacaoAtual,
                icon: _obtendoLocalizacao
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(
                  _obtendoLocalizacao
                      ? 'Obtendo localização...'
                      : 'Usar minha localização atual',
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: corCartao,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coordenadas',
                    style: TextStyle(
                      color: corTexto,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _latitudeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _longitudeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _aplicarCoordenadas,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Aplicar coordenadas no mapa'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                style: FilledButton.styleFrom(
                  backgroundColor: corDetalhe,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _salvando
                      ? 'Salvando...'
                      : _editando
                      ? 'Salvar alterações'
                      : 'Cadastrar propriedade',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
