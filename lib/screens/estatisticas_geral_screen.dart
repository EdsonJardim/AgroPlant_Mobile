import 'dart:async';

import 'package:flutter/material.dart';

import '../models/estoque.dart';
import '../models/gestao.dart';
import '../models/maquina.dart';
import '../models/safra.dart';
import '../services/estoque_service.dart';
import '../services/gestao_service.dart';
import '../services/maquina_service.dart';
import '../services/safra_service.dart';
import '../widgets/agroplant_app_bar.dart';

class EstatisticasGeralScreen extends StatefulWidget {
  const EstatisticasGeralScreen({super.key});

  @override
  State<EstatisticasGeralScreen> createState() =>
      _EstatisticasGeralScreenState();
}

class _EstatisticasGeralScreenState extends State<EstatisticasGeralScreen> {
  static const Color verde = Color(0xFF174D2A);
  static const Color verdeClaro = Color(0xFF78A878);
  static const Color bege = Color(0xFFE8DCC6);
  static const Color begeClaro = Color(0xFFF7F2E8);

  static const Color corReceita = Color(0xFF3D9660);
  static const Color corDespesa = Color(0xFFD47762);
  static const Color corAviso = Color(0xFFD5A044);
  static const Color corNeutra = Color(0xFF87918A);

  final EstoqueService _estoqueService = EstoqueService();
  final GestaoService _gestaoService = GestaoService();
  final MaquinaService _maquinaService = MaquinaService();
  final SafraService _safraService = SafraService();

  List<Estoque> _estoques = [];
  List<Gestao> _gestoes = [];
  List<Maquina> _maquinas = [];
  List<Safra> _safras = [];

  StreamSubscription<List<Estoque>>? _estoqueSubscription;
  StreamSubscription<List<Gestao>>? _gestaoSubscription;
  StreamSubscription<List<Maquina>>? _maquinaSubscription;
  StreamSubscription<List<Safra>>? _safraSubscription;

  bool _estoqueCarregado = false;
  bool _gestaoCarregado = false;
  bool _maquinasCarregadas = false;
  bool _safrasCarregadas = false;

  Object? _erro;

  bool get _carregando =>
      !_estoqueCarregado ||
      !_gestaoCarregado ||
      !_maquinasCarregadas ||
      !_safrasCarregadas;

  double get _totalEstoque =>
      _estoques.fold(0, (total, item) => total + item.quantidade * item.preco);

  double get _totalQuantidadeEstoque =>
      _estoques.fold(0, (total, item) => total + item.quantidade);

  double get _receitas => _gestoes
      .where((item) => item.tipo.trim().toLowerCase() == 'receita')
      .fold(0, (total, item) => total + item.valor);

  double get _despesas => _gestoes
      .where((item) => item.tipo.trim().toLowerCase() == 'despesa')
      .fold(0, (total, item) => total + item.valor);

  double get _saldo => _receitas - _despesas;

  int get _maquinasOperacionais => _maquinas
      .where((item) => item.status.trim().toLowerCase() == 'operacional')
      .length;

  int get _maquinasManutencao => _maquinas
      .where((item) => item.status.trim().toLowerCase() == 'em manutenção')
      .length;

  int get _maquinasInativas => _maquinas
      .where((item) => item.status.trim().toLowerCase() == 'inativa')
      .length;

  int get _safrasColheita => _safras
      .where((item) => item.status.trim().toLowerCase() == 'em colheita')
      .length;

  int get _safrasDesenvolvimento => _safras
      .where((item) => item.status.trim().toLowerCase() == 'em desenvolvimento')
      .length;

  int get _safrasInativas => _safras
      .where((item) => item.status.trim().toLowerCase() == 'inativa')
      .length;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    try {
      _estoqueSubscription = _estoqueService.listarEstoque().listen((dados) {
        if (!mounted) return;

        setState(() {
          _estoques = dados;
          _estoqueCarregado = true;
        });
      }, onError: _tratarErro);

      _gestaoSubscription = _gestaoService.listarGestao().listen((dados) {
        if (!mounted) return;

        setState(() {
          _gestoes = dados;
          _gestaoCarregado = true;
        });
      }, onError: _tratarErro);

      _maquinaSubscription = _maquinaService.observarMaquinas().listen((dados) {
        if (!mounted) return;

        setState(() {
          _maquinas = dados;
          _maquinasCarregadas = true;
        });
      }, onError: _tratarErro);

      _safraSubscription = _safraService.observarSafras().listen((dados) {
        if (!mounted) return;

        setState(() {
          _safras = dados;
          _safrasCarregadas = true;
        });
      }, onError: _tratarErro);
    } catch (erro) {
      _tratarErro(erro);
    }
  }

  void _tratarErro(Object erro) {
    if (!mounted) return;

    setState(() {
      _erro = erro;
    });
  }

  Future<void> _reiniciarCarregamento() async {
    await _cancelarInscricoes();

    if (!mounted) return;

    setState(() {
      _erro = null;
      _estoqueCarregado = false;
      _gestaoCarregado = false;
      _maquinasCarregadas = false;
      _safrasCarregadas = false;
    });

    _carregarDados();
  }

  Future<void> _cancelarInscricoes() async {
    await _estoqueSubscription?.cancel();
    await _gestaoSubscription?.cancel();
    await _maquinaSubscription?.cancel();
    await _safraSubscription?.cancel();
  }

  @override
  void dispose() {
    _estoqueSubscription?.cancel();
    _gestaoSubscription?.cancel();
    _maquinaSubscription?.cancel();
    _safraSubscription?.cancel();
    super.dispose();
  }

  String _dinheiro(double valor) {
    final partes = valor.abs().toStringAsFixed(2).split('.');
    final inteiro = partes[0];
    final buffer = StringBuffer();

    for (int i = 0; i < inteiro.length; i++) {
      if (i > 0 && (inteiro.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(inteiro[i]);
    }

    final sinal = valor < 0 ? '-' : '';

    return '${sinal}R\$ ${buffer.toString()},${partes[1]}';
  }

  Widget _indicador({
    required String titulo,
    required String valor,
    required Color cor,
    required IconData icone,
    required bool escuro,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      decoration: BoxDecoration(
        color: escuro ? const Color(0xFF29372D) : const Color(0xFFF0F5EF),
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: cor, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icone, size: 19, color: cor),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                color: escuro ? Colors.white70 : verde,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: escuro ? Colors.white : verde,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartao({
    required String titulo,
    required String descricao,
    required IconData icone,
    required Color corIcone,
    required List<Widget> indicadores,
    required bool escuro,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: escuro ? const Color(0xFF202B23) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: escuro ? const Color(0xFF354C3A) : const Color(0xFFECE7DA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: escuro ? 0.16 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: corIcone.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icone, color: corIcone, size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        color: escuro ? Colors.white : verde,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      descricao,
                      style: TextStyle(
                        color: escuro
                            ? const Color(0xFFB8C1B9)
                            : const Color(0xFF777E75),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...indicadores,
        ],
      ),
    );
  }

  Widget _conteudo(bool escuro) {
    final corFundo = escuro ? const Color(0xFF101A13) : bege;
    final corTexto = escuro ? Colors.white : verde;
    final corDetalhe = escuro ? verdeClaro : verde;

    return Scaffold(
      backgroundColor: corFundo,
      appBar: AgroPlantAppBar(
        backgroundColor: escuro ? const Color(0xFF1E2D23) : begeClaro,
        foregroundColor: corDetalhe,
        centerTitle: true,
        title: Text(
          'Estatísticas',
          style: TextStyle(color: corTexto, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final largura = constraints.maxWidth;

          final int colunas = largura >= 1100
              ? 4
              : largura >= 600
              ? 2
              : largura >= 380
              ? 2
              : 1;

          const espacamento = 16.0;

          final larguraCartao =
              (largura - espacamento * (colunas - 1)) / colunas;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visão geral',
                            style: TextStyle(
                              color: corTexto,
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Acompanhe os principais indicadores da sua propriedade.',
                            style: TextStyle(
                              color: escuro
                                  ? const Color(0xFFB8C1B9)
                                  : const Color(0xFF62594B),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: corDetalhe.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        color: corDetalhe,
                        size: 27,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Wrap(
                  spacing: espacamento,
                  runSpacing: espacamento,
                  children: [
                    SizedBox(
                      width: larguraCartao,
                      child: _cartao(
                        titulo: 'Gestão',
                        descricao: 'Controle financeiro',
                        icone: Icons.account_balance_wallet_outlined,
                        corIcone: verdeClaro,
                        escuro: escuro,
                        indicadores: [
                          _indicador(
                            titulo: 'Receitas',
                            valor: _dinheiro(_receitas),
                            cor: corReceita,
                            icone: Icons.trending_up,
                            escuro: escuro,
                          ),
                          _indicador(
                            titulo: 'Despesas',
                            valor: _dinheiro(_despesas),
                            cor: corDespesa,
                            icone: Icons.trending_down,
                            escuro: escuro,
                          ),
                          _indicador(
                            titulo: 'Saldo',
                            valor: _dinheiro(_saldo),
                            cor: _saldo >= 0 ? corReceita : corDespesa,
                            icone: Icons.account_balance_outlined,
                            escuro: escuro,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: larguraCartao,
                      child: _cartao(
                        titulo: 'Estoque',
                        descricao: 'Produtos e recursos',
                        icone: Icons.inventory_2_outlined,
                        corIcone: const Color(0xFF6C9B73),
                        escuro: escuro,
                        indicadores: [
                          _indicador(
                            titulo: 'Total de itens',
                            valor: '${_estoques.length}',
                            cor: verdeClaro,
                            icone: Icons.category_outlined,
                            escuro: escuro,
                          ),
                          _indicador(
                            titulo: 'Quantidade total',
                            valor: _totalQuantidadeEstoque.toStringAsFixed(2),
                            cor: verdeClaro,
                            icone: Icons.scale_outlined,
                            escuro: escuro,
                          ),
                          _indicador(
                            titulo: 'Valor em estoque',
                            valor: _dinheiro(_totalEstoque),
                            cor: corReceita,
                            icone: Icons.payments_outlined,
                            escuro: escuro,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: larguraCartao,
                      child: _cartao(
                        titulo: 'Máquinas',
                        descricao: 'Equipamentos agrícolas',
                        icone: Icons.agriculture_outlined,
                        corIcone: const Color(0xFF9A9E54),
                        escuro: escuro,
                        indicadores: [
                          _indicador(
                            titulo: 'Total de máquinas',
                            valor: '${_maquinas.length}',
                            cor: verdeClaro,
                            icone: Icons.precision_manufacturing_outlined,
                            escuro: escuro,
                          ),
                          _indicador(
                            titulo: 'Operacionais',
                            valor: '$_maquinasOperacionais',
                            cor: corReceita,
                            icone: Icons.check_circle_outline,
                            escuro: escuro,
                          ),
                          _indicador(
                            titulo: 'Em manutenção',
                            valor: '$_maquinasManutencao',
                            cor: corAviso,
                            icone: Icons.build_outlined,
                            escuro: escuro,
                          ),
                          _indicador(
                            titulo: 'Inativas',
                            valor: '$_maquinasInativas',
                            cor: corNeutra,
                            icone: Icons.pause_circle_outline,
                            escuro: escuro,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: larguraCartao,
                      child: _cartao(
                        titulo: 'Safras',
                        descricao: 'Acompanhamento da produção',
                        icone: Icons.grass_outlined,
                        corIcone: verdeClaro,
                        escuro: escuro,
                        indicadores: [
                          _indicador(
                            titulo: 'Total de safras',
                            valor: '${_safras.length}',
                            cor: verdeClaro,
                            icone: Icons.agriculture_outlined,
                            escuro: escuro,
                          ),
                          _indicador(
                            titulo: 'Em colheita',
                            valor: '$_safrasColheita',
                            cor: corReceita,
                            icone: Icons.check_circle_outline,
                            escuro: escuro,
                          ),
                          _indicador(
                            titulo: 'Em desenvolvimento',
                            valor: '$_safrasDesenvolvimento',
                            cor: corAviso,
                            icone: Icons.timelapse_outlined,
                            escuro: escuro,
                          ),
                          _indicador(
                            titulo: 'Inativas',
                            valor: '$_safrasInativas',
                            cor: corNeutra,
                            icone: Icons.pause_circle_outline,
                            escuro: escuro,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: escuro
                        ? const Color(0xFF202B23)
                        : const Color(0xFFEAF2E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sync, color: corDetalhe, size: 21),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Indicadores atualizados automaticamente pelo Firestore.',
                          style: TextStyle(color: corTexto, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.eco_outlined, color: corDetalhe, size: 27),
                      const SizedBox(height: 7),
                      Text(
                        'AgroPlant',
                        style: TextStyle(
                          color: corTexto,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tecnologia e organização para o campo.',
                        style: TextStyle(
                          color: escuro
                              ? const Color(0xFFB8C1B9)
                              : const Color(0xFF62594B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _telaCarregamento(bool escuro) {
    return Scaffold(
      backgroundColor: escuro ? const Color(0xFF101A13) : bege,
      appBar: AgroPlantAppBar(
        backgroundColor: escuro ? const Color(0xFF1E2D23) : begeClaro,
        foregroundColor: escuro ? verdeClaro : verde,
        centerTitle: true,
        fallbackRoute: '/planilhas',
        title: Text(
          'Estatísticas',
          style: TextStyle(
            color: escuro ? Colors.white : verde,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: escuro ? verdeClaro : verde),
            const SizedBox(height: 16),
            Text(
              'Carregando estatísticas...',
              style: TextStyle(color: escuro ? Colors.white : verde),
            ),
          ],
        ),
      ),
    );
  }

  Widget _telaErro(bool escuro) {
    return Scaffold(
      backgroundColor: escuro ? const Color(0xFF101A13) : bege,
      appBar: AgroPlantAppBar(
        backgroundColor: escuro ? const Color(0xFF1E2D23) : begeClaro,
        foregroundColor: escuro ? verdeClaro : verde,
        centerTitle: true,
        title: Text(
          'Estatísticas',
          style: TextStyle(
            color: escuro ? Colors.white : verde,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: corDespesa, size: 48),
              const SizedBox(height: 14),
              Text(
                'Não foi possível carregar as estatísticas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: escuro ? Colors.white : verde,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Verifique sua conexão e tente novamente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: escuro ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _reiniciarCarregamento,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: verde,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    if (_erro != null) {
      return _telaErro(escuro);
    }

    if (_carregando) {
      return _telaCarregamento(escuro);
    }

    return _conteudo(escuro);
  }
}
