import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/safra.dart';
import '../services/safra_service.dart';
import '../widgets/agroplant_app_bar.dart';

const Color _verdeSafra = Color(0xFF174D2A);
const Color _verdeClaroSafra = Color(0xFF78A878);
const Color _begeSafra = Color(0xFFE8DCC6);
const Color _fundoSafra = Color(0xFFF7F2E8);
const Color _textoSecundarioSafra = Color(0xFF62594B);

class SafraScreen extends StatefulWidget {
  const SafraScreen({super.key});

  @override
  State<SafraScreen> createState() => _SafraScreenState();
}

class _SafraScreenState extends State<SafraScreen> {
  final SafraService _service = SafraService();
  final TextEditingController _busca = TextEditingController();

  final List<String> _tipos = [
    'Soja',
    'Milho',
    'Café',
    'Cana-de-açúcar',
    'Algodão',
    'Feijão',
    'Arroz',
    'Trigo',
    'Sorgo',
    'Girassol',
    'Mandioca',
    'Batata',
    'Tomate',
    'Cebola',
    'Alho',
    'Alface',
    'Cenoura',
    'Pimentão',
    'Laranja',
    'Limão',
    'Banana',
    'Maçã',
    'Uva',
    'Morango',
    'Abacaxi',
    'Cacau',
    'Eucalipto',
    'Pasto',
    'Hortaliças',
    'Outro',
  ];

  final List<String> _status = ['Em desenvolvimento', 'Em colheita', 'Inativa'];

  String _filtro = 'Todas';

  bool get _escuro => Theme.of(context).brightness == Brightness.dark;

  Color get _corFundo => _escuro ? const Color(0xFF121A14) : _fundoSafra;

  Color get _corCartao => _escuro ? const Color(0xFF202B23) : Colors.white;

  Color get _corTexto => _escuro ? Colors.white : _verdeSafra;

  Color get _corTextoSecundario =>
      _escuro ? Colors.white70 : _textoSecundarioSafra;

  Color get _corCampo => _escuro ? const Color(0xFF29372D) : Colors.white;

  Color get _corBorda => _escuro ? const Color(0xFF46594A) : _begeSafra;

  Color get _corDestaque => _escuro ? _verdeClaroSafra : _verdeSafra;

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  void _mensagem(String texto, {bool erro = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: erro ? Colors.red.shade700 : _verdeSafra,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  List<Safra> _filtrar(List<Safra> safras) {
    final consulta = _busca.text.trim().toLowerCase();

    return safras.where((safra) {
      final correspondeBusca =
          safra.plantacao.toLowerCase().contains(consulta) ||
          safra.tipo.toLowerCase().contains(consulta) ||
          safra.status.toLowerCase().contains(consulta) ||
          safra.maquinario.toLowerCase().contains(consulta) ||
          safra.tempoColheita.toLowerCase().contains(consulta);

      final correspondeFiltro =
          _filtro == 'Todas' ||
          (_filtro == 'Em colheita' && safra.status == 'Em colheita') ||
          (_filtro == 'Em desenvolvimento' &&
              safra.status == 'Em desenvolvimento') ||
          (_filtro == 'Inativas' && safra.status == 'Inativa');

      return correspondeBusca && correspondeFiltro;
    }).toList();
  }

  Future<void> _abrirFormulario({Safra? safra}) async {
    final plantacaoController = TextEditingController(
      text: safra?.plantacao ?? '',
    );
    final maquinarioController = TextEditingController(
      text: safra?.maquinario ?? '',
    );
    final tempoController = TextEditingController(
      text: safra?.tempoColheita ?? '',
    );
    final custoController = TextEditingController(
      text: safra?.custo.toString() ?? '',
    );

    String tipo = _tipos.contains(safra?.tipo) ? safra!.tipo : 'Soja';
    String status = _status.contains(safra?.status)
        ? safra!.status
        : 'Em desenvolvimento';

    bool salvando = false;

    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _corFundo,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (contextModal, atualizarModal) {
            Future<void> salvar() async {
              final plantacao = plantacaoController.text.trim();
              final maquinario = maquinarioController.text.trim();
              final tempo = tempoController.text.trim();
              final custo = double.tryParse(
                custoController.text.trim().replaceAll(',', '.'),
              );

              if (plantacao.isEmpty) {
                _mensagem('Informe a plantação.', erro: true);
                return;
              }

              if (maquinario.isEmpty) {
                _mensagem('Informe o maquinário utilizado.', erro: true);
                return;
              }

              if (tempo.isEmpty) {
                _mensagem('Informe o tempo de colheita.', erro: true);
                return;
              }

              if (!RegExp(r'^\d+:[0-5]\d$').hasMatch(tempo)) {
                _mensagem(
                  'Informe o tempo no formato HH:MM. Exemplo: 08:30.',
                  erro: true,
                );
                return;
              }

              if (custo == null || custo <= 0) {
                _mensagem('Informe um custo maior que zero.', erro: true);
                return;
              }

              atualizarModal(() => salvando = true);

              try {
                final agora = Timestamp.now();

                final item = Safra(
                  id: safra?.id ?? '',
                  plantacao: plantacao,
                  tipo: tipo,
                  maquinario: maquinario,
                  tempoColheita: tempo,
                  custo: custo,
                  status: status,
                  createdAt: safra?.createdAt ?? agora,
                  updatedAt: agora,
                );

                if (safra == null) {
                  await _service.adicionarSafra(item);
                } else {
                  await _service.atualizarSafra(item);
                }

                if (modalContext.mounted) {
                  Navigator.of(modalContext).pop(true);
                }
              } catch (erro) {
                atualizarModal(() => salvando = false);
                _mensagem('Não foi possível salvar a safra: $erro', erro: true);
              }
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(contextModal).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _corBorda,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            safra == null ? 'Adicionar safra' : 'Editar safra',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: _corTexto,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: salvando
                              ? null
                              : () => Navigator.of(modalContext).pop(false),
                          icon: Icon(Icons.close, color: _corTextoSecundario),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _campo(
                      controller: plantacaoController,
                      label: 'Nome da plantação',
                      icone: Icons.grass_outlined,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: tipo,
                      isExpanded: true,
                      decoration: _decoracao(
                        'Tipo de cultivo',
                        Icons.category_outlined,
                      ),
                      dropdownColor: _corCartao,
                      style: TextStyle(color: _corTexto),
                      items: _tipos
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: salvando
                          ? null
                          : (valor) {
                              if (valor != null) {
                                atualizarModal(() => tipo = valor);
                              }
                            },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      isExpanded: true,
                      decoration: _decoracao(
                        'Status da safra',
                        Icons.agriculture_outlined,
                      ),
                      dropdownColor: _corCartao,
                      style: TextStyle(color: _corTexto),
                      items: _status
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: salvando
                          ? null
                          : (valor) {
                              if (valor != null) {
                                atualizarModal(() => status = valor);
                              }
                            },
                    ),
                    const SizedBox(height: 14),
                    _campo(
                      controller: maquinarioController,
                      label: 'Maquinário utilizado',
                      icone: Icons.precision_manufacturing_outlined,
                    ),
                    const SizedBox(height: 14),
                    _campo(
                      controller: tempoController,
                      label: 'Tempo de colheita (HH:MM)',
                      icone: Icons.timer_outlined,
                      teclado: TextInputType.datetime,
                    ),
                    const SizedBox(height: 14),
                    _campo(
                      controller: custoController,
                      label: 'Custo (R\$)',
                      icone: Icons.attach_money,
                      teclado: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: salvando ? null : salvar,
                        icon: salvando
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
                          salvando ? 'Salvando...' : 'Salvar safra',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _verdeSafra,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    plantacaoController.dispose();
    maquinarioController.dispose();
    tempoController.dispose();
    custoController.dispose();

    if (resultado == true && mounted) {
      _mensagem(
        safra == null
            ? 'Safra cadastrada com sucesso!'
            : 'Safra atualizada com sucesso!',
      );
    }
  }

  Future<void> _confirmarExclusao(Safra safra) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _corFundo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            'Excluir safra',
            style: TextStyle(
              color: _corTexto,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deseja realmente excluir "${safra.plantacao}"? Essa ação não poderá ser desfeita.',
            style: TextStyle(color: _corTextoSecundario, fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _verdeSafra,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                label: const Text(
                  'Excluir',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await _service.excluirSafra(safra.id);
      _mensagem('Safra excluída com sucesso!');
    } catch (erro) {
      _mensagem('Não foi possível excluir a safra: $erro', erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _corFundo,
      appBar: const AgroPlantAppBar(
        backgroundColor: _verdeSafra,
        foregroundColor: Colors.white,
        centerTitle: true,
        fallbackRoute: '/planilhas',
        title: Text('Safra', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: _verdeSafra,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Adicionar safra',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Safra>>(
        stream: _service.observarSafras(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Não foi possível carregar as safras.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _corTextoSecundario),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _corTextoSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _verdeSafra),
            );
          }

          final todas = snapshot.data ?? [];

          final colheita = todas
              .where((item) => item.status == 'Em colheita')
              .length;
          final desenvolvimento = todas
              .where((item) => item.status == 'Em desenvolvimento')
              .length;
          final inativas = todas
              .where((item) => item.status == 'Inativa')
              .length;

          final filtradas = _filtrar(todas);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              Text(
                'Controle de safras',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: _corTexto,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Acompanhe suas plantações, custos e produção.',
                style: TextStyle(fontSize: 14, color: _corTextoSecundario),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _resumo(
                    titulo: 'Em colheita',
                    quantidade: colheita,
                    icone: Icons.agriculture_outlined,
                    cor: _corDestaque,
                  ),
                  _resumo(
                    titulo: 'Em desenvolvimento',
                    quantidade: desenvolvimento,
                    icone: Icons.grass_outlined,
                    cor: Colors.orange.shade800,
                  ),
                  _resumo(
                    titulo: 'Inativas',
                    quantidade: inativas,
                    icone: Icons.pause_circle_outline,
                    cor: Colors.red.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _busca,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: _corTexto),
                decoration: InputDecoration(
                  hintText: 'Buscar safra...',
                  hintStyle: TextStyle(color: _corTextoSecundario),
                  prefixIcon: Icon(Icons.search, color: _corDestaque),
                  suffixIcon: _busca.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _busca.clear();
                            setState(() {});
                          },
                          icon: Icon(Icons.close, color: _corTextoSecundario),
                        ),
                  filled: true,
                  fillColor: _corCampo,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _corBorda),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _corDestaque, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _botaoFiltro('Todas'),
                  _botaoFiltro('Em colheita'),
                  _botaoFiltro('Em desenvolvimento'),
                  _botaoFiltro('Inativas'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Safras cadastradas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _corTexto,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _escuro ? const Color(0xFF34483A) : _begeSafra,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${filtradas.length}',
                      style: TextStyle(
                        color: _corTexto,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (filtradas.isEmpty)
                _estadoVazio(todas.isEmpty)
              else
                ...filtradas.map(_cartaoSafra),
            ],
          );
        },
      ),
    );
  }

  Widget _resumo({
    required String titulo,
    required int quantidade,
    required IconData icone,
    required Color cor,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        decoration: BoxDecoration(
          color: _corCartao,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _corBorda),
        ),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 23),
            const SizedBox(height: 8),
            Text(
              '$quantidade',
              style: TextStyle(
                color: cor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _corTextoSecundario,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoFiltro(String titulo) {
    final selecionado = _filtro == titulo;

    return OutlinedButton(
      onPressed: () => setState(() => _filtro = titulo),
      style: OutlinedButton.styleFrom(
        backgroundColor: selecionado ? _verdeSafra : _corCartao,
        foregroundColor: selecionado ? Colors.white : _corTexto,
        side: BorderSide(color: selecionado ? _verdeSafra : _corBorda),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _estadoVazio(bool semCadastro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: _corCartao,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _corBorda),
      ),
      child: Column(
        children: [
          Icon(
            semCadastro ? Icons.grass_outlined : Icons.search_off_outlined,
            size: 48,
            color: _verdeClaroSafra,
          ),
          const SizedBox(height: 14),
          Text(
            semCadastro
                ? 'Nenhuma safra cadastrada'
                : 'Nenhuma safra encontrada',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _corTexto,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            semCadastro
                ? 'Adicione sua primeira safra para começar.'
                : 'Altere a busca ou selecione outro filtro.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _corTextoSecundario),
          ),
        ],
      ),
    );
  }

  Widget _cartaoSafra(Safra safra) {
    final corStatus = switch (safra.status) {
      'Em colheita' => _corDestaque,
      'Em desenvolvimento' => Colors.orange.shade800,
      'Inativa' => Colors.red.shade700,
      _ => _corTextoSecundario,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _corCartao,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _corBorda),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _escuro ? 0.12 : 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _verdeClaroSafra.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.grass_outlined,
                    color: _corDestaque,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        safra.plantacao,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _corTexto,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        safra.tipo,
                        style: TextStyle(
                          fontSize: 13,
                          color: _corTextoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: corStatus.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      safra.status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: corStatus,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: _corBorda, height: 1),
            ),
            _linhaInformacao(
              Icons.precision_manufacturing_outlined,
              'Maquinário',
              safra.maquinario,
            ),
            const SizedBox(height: 11),
            _linhaInformacao(
              Icons.timer_outlined,
              'Tempo de colheita',
              '${safra.tempoColheita} h',
            ),
            const SizedBox(height: 11),
            _linhaInformacao(
              Icons.attach_money,
              'Custo',
              _formatarMoeda(safra.custo),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirFormulario(safra: safra),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _corTexto,
                      side: BorderSide(color: _corBorda),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmarExclusao(safra),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Excluir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaInformacao(IconData icone, String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 18, color: _verdeClaroSafra),
        const SizedBox(width: 9),
        SizedBox(
          width: 125,
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: _corTextoSecundario,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              color: _corTexto,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatarMoeda(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final inteiro = partes[0];
    final buffer = StringBuffer();

    for (int i = 0; i < inteiro.length; i++) {
      if (i > 0 && (inteiro.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(inteiro[i]);
    }

    return 'R\$ ${buffer.toString()},${partes[1]}';
  }

  InputDecoration _decoracao(String label, IconData icone) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _corTextoSecundario),
      prefixIcon: Icon(icone, color: _corDestaque),
      filled: true,
      fillColor: _corCampo,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _corBorda),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _corDestaque, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icone,
    TextInputType teclado = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      style: TextStyle(color: _corTexto),
      decoration: _decoracao(label, icone),
    );
  }
}
