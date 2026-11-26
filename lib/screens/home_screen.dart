import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'perfil_screen.dart';
import 'planilhas_screen.dart';
import 'sobre_screen.dart';
import 'configuracoes_screen.dart';
import 'minha_propriedade_screen.dart';
import 'admin_screen.dart';

import '../models/propriedade.dart';
import '../services/propriedade_service.dart';
import '../services/admin_service.dart';
import '../widgets/agroplant_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color verde = Color(0xFF174D2A);
  static const Color bege = Color(0xFFE8DCC6);
  static const Color begeClaro = Color(0xFFF7F2E8);
  static const Color textoSecundario = Color(0xFF62594B);

  final ScrollController _scrollController = ScrollController();
  final PropriedadeService _propriedadeService = PropriedadeService();
  final AdminService _adminService = AdminService();

  late Future<Map<String, dynamic>?> _perfilAdminFuture;

  String? _propriedadeSelecionadaId;

  @override
  void initState() {
    super.initState();
    _perfilAdminFuture = _adminService.consultarPerfilAdmin();
  }

  void _recarregarTela() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    }

    setState(() {
      _perfilAdminFuture = _adminService.consultarPerfilAdmin();
    });
  }

  void _abrirPropriedades() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MinhaPropriedadeScreen(),
      ),
    );
  }

  void _abrirPlanilhas() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PlanilhasScreen(),
      ),
    );
  }

  void _abrirPainelAdmin(String perfil) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminScreen(perfilAdmin: perfil),
      ),
    );
  }

  Widget _construirCartaoPropriedade({
    required bool escuro,
    required Color corCartao,
    required Color corTexto,
    required Color corTextoSecundario,
    required Color corDetalhe,
  }) {
    return StreamBuilder<List<PropriedadeModel>>(
      stream: _propriedadeService.observarPropriedades(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: corCartao,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 42,
                  color: corDetalhe,
                ),
                const SizedBox(height: 12),
                Text(
                  'Não foi possível carregar suas propriedades.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: corTexto),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _abrirPropriedades,
                  child: const Text('Gerenciar propriedades'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 300,
            decoration: BoxDecoration(
              color: corCartao,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: CircularProgressIndicator(color: corDetalhe),
            ),
          );
        }

        final propriedades = snapshot.data ?? [];

        if (propriedades.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: corCartao,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: escuro ? 0.15 : 0.05,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.satellite_alt_outlined,
                  color: corDetalhe,
                  size: 54,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sua propriedade começa aqui!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: corTexto,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Cadastre sua propriedade rural para visualizar '
                  'sua localização no mapa e preparar o monitoramento '
                  'agrícola por satélite.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: corTextoSecundario,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _abrirPropriedades,
                    style: FilledButton.styleFrom(
                      backgroundColor: corDetalhe,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text(
                      'Cadastrar propriedade',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final propriedade = propriedades.firstWhere(
          (item) => item.id == _propriedadeSelecionadaId,
          orElse: () => propriedades.first,
        );

        final ponto = LatLng(
          propriedade.latitude,
          propriedade.longitude,
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: corCartao,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: escuro ? 0.15 : 0.05,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.landscape_outlined,
                    color: corDetalhe,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Minha propriedade',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: corTexto,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (propriedades.length > 1) ...[
                DropdownButtonFormField<String>(
                  initialValue: propriedade.id,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Selecionar propriedade',
                    border: OutlineInputBorder(),
                  ),
                  items: propriedades.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(
                        item.nome,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      setState(() {
                        _propriedadeSelecionadaId = id;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 230,
                  child: FlutterMap(
                    key: ValueKey(propriedade.id),
                    options: MapOptions(
                      initialCenter: ponto,
                      initialZoom: 14,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.agroplant_mobile',
                        tileProvider: NetworkTileProvider(
                          headers: {
                            'User-Agent':
                                'AgroPlant/1.0 (com.example.agroplant_mobile)',
                          },
                        ),
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: ponto,
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
                            'OpenStreetMap contributors',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                propriedade.nome,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: corTexto,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                propriedade.endereco.isEmpty
                    ? 'Endereço não informado'
                    : propriedade.endereco,
                style: TextStyle(
                  color: corTextoSecundario,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.square_foot_outlined,
                    size: 19,
                    color: corDetalhe,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${propriedade.areaHectares} hectares',
                    style: TextStyle(
                      color: corTextoSecundario,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _abrirPropriedades,
                  icon: const Icon(Icons.edit_location_alt_outlined),
                  label: const Text('Gerenciar propriedades'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: corDetalhe,
                    side: BorderSide(color: corDetalhe),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;
    final nome = usuario?.displayName?.trim();
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final corFundo = escuro ? const Color(0xFF121A14) : bege;
    final corAppBar = escuro ? const Color(0xFF202B23) : begeClaro;
    final corTexto = escuro ? Colors.white : verde;
    final corTextoSecundario =
        escuro ? Colors.white70 : textoSecundario;
    final corCartao = escuro ? const Color(0xFF202B23) : Colors.white;
    final corDetalhe = escuro ? const Color(0xFF78A878) : verde;

    return Scaffold(
      backgroundColor: corFundo,
      appBar: AgroPlantAppBar(
        showBackButton: false,
        onLogoTap: _recarregarTela,
        backgroundColor: corAppBar,
        foregroundColor: escuro ? Colors.white : verde,
        actions: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _perfilAdminFuture,
            builder: (context, snapshot) {
              final dadosPerfil = snapshot.data;
              final perfil = dadosPerfil?['role'] as String?;
              final ativo = dadosPerfil?['ativo'] == true;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              if (snapshot.hasError || perfil == null || !ativo) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Painel administrativo',
                onPressed: () => _abrirPainelAdmin(perfil),
                icon: const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 28,
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Sobre a equipe',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SobreScreen(),
                ),
              );
            },
            icon: const Icon(Icons.groups_outlined, size: 28),
          ),
          IconButton(
            tooltip: 'Configurações',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ConfiguracoesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined, size: 28),
          ),
          IconButton(
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PerfilScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.account_circle_outlined,
              size: 30,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (nome != null && nome.isNotEmpty) ...[
                Text(
                  'Olá, $nome! 👋',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: corTexto,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                'Controle sua safra, reduza seus custos e aumente sua produtividade.',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: corTexto,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Gerencie seus recursos agrícolas de forma simples e organizada.',
                style: TextStyle(
                  fontSize: 16,
                  color: corTextoSecundario,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: corDetalhe,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _abrirPlanilhas,
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text(
                    'Acessar planilhas',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _construirCartaoPropriedade(
                escuro: escuro,
                corCartao: corCartao,
                corTexto: corTexto,
                corTextoSecundario: corTextoSecundario,
                corDetalhe: corDetalhe,
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.agriculture_outlined,
                      color: corDetalhe,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'AgroPlant',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: corTexto,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tecnologia e organização para o campo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: corTextoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}