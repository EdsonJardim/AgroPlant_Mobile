import 'package:flutter/material.dart';

import '../models/gestao.dart';
import '../services/gestao_service.dart';
import '../widgets/agroplant_app_bar.dart';

String formatarDataBrasil(String data) {
  if (data.isEmpty) return '';

  if (data.contains('/')) return data;

  if (data.contains('-')) {
    final partes = data.split('-');

    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }
  }

  return data;
}

class GestaoScreen extends StatefulWidget {
  const GestaoScreen({super.key});

  @override
  State<GestaoScreen> createState() => _GestaoScreenState();
}

class _GestaoScreenState extends State<GestaoScreen> {
  final _service = GestaoService();

  final _descricao = TextEditingController();
  final _valor = TextEditingController();
  final _data = TextEditingController();
  final _busca = TextEditingController();

  static const verde = Color(0xFF174D2A);
  static const verdeClaro = Color(0xFF78A878);
  static const bege = Color(0xFFE8DCC6);
  static const fundo = Color(0xFFF7F2E8);
  static const textoSecundario = Color(0xFF62594B);

  bool get _escuro => Theme.of(context).brightness == Brightness.dark;

  Color get _corFundo => _escuro ? const Color(0xFF121A14) : fundo;

  Color get _corCartao => _escuro ? const Color(0xFF202B23) : Colors.white;

  Color get _corTexto => _escuro ? Colors.white : verde;

  Color get _corTextoSecundario => _escuro ? Colors.white70 : textoSecundario;

  Color get _corCampo => _escuro ? const Color(0xFF29372D) : Colors.white;

  Color get _corBorda => _escuro ? const Color(0xFF46594A) : bege;

  Color get _corDestaque => _escuro ? const Color(0xFF78A878) : verdeClaro;

  final List<String> _receitas = [
    'Venda de grãos',
    'Venda de frutos',
    'Venda de vegetais',
    'Venda de animais',
    'Venda de leite',
    'Venda de ovos',
    'Venda de madeira',
    'Venda de café',
    'Venda de cana-de-açúcar',
    'Venda de hortaliças',
    'Prestação de serviços',
    'Arrendamento',
    'Financiamento agrícola',
    'Subsídio',
    'Investimentos',
    'Outro',
  ];

  final List<String> _despesas = [
    'Insumos',
    'Sementes',
    'Fertilizantes',
    'Defensivos agrícolas',
    'Ração',
    'Medicamentos veterinários',
    'Combustível',
    'Mão de obra',
    'Manutenção',
    'Peças de máquinas',
    'Energia',
    'Água',
    'Impostos',
    'Transporte',
    'Armazenamento',
    'Seguro agrícola',
    'Financiamento',
    'Outro',
  ];

  final List<String> _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  String _tipo = 'Receita';
  String _categoria = 'Venda de grãos';
  String _mes = 'Maio';
  String _filtro = 'Todos';

  List<String> get _categorias => _tipo == 'Receita' ? _receitas : _despesas;

  @override
  void dispose() {
    _descricao.dispose();
    _valor.dispose();
    _data.dispose();
    _busca.dispose();
    super.dispose();
  }

  void _msg(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
          backgroundColor: verde,
        ),
      );
  }

  void _limpar() {
    _descricao.clear();
    _valor.clear();
    _data.clear();
    _tipo = 'Receita';
    _categoria = _receitas.first;
    _mes = _meses[DateTime.now().month - 1];
  }

  void _editarCampos(Gestao item) {
    _descricao.text = item.descricao;
    _valor.text = item.valor.toStringAsFixed(2);
    _data.text = formatarDataBrasil(item.data);
    _tipo = item.tipo;
    _categoria = item.categoria;
    _mes = _meses.contains(item.mes)
        ? item.mes
        : _meses[DateTime.now().month - 1];

    if (!_categorias.contains(_categoria)) {
      _categoria = _categorias.first;
    }
  }

  Future<void> _selecionarData() async {
    DateTime inicial = DateTime.now();

    if (_data.text.isNotEmpty) {
      try {
        final partes = _data.text.split('/');

        if (partes.length == 3) {
          inicial = DateTime(
            int.parse(partes[2]),
            int.parse(partes[1]),
            int.parse(partes[0]),
          );
        }
      } catch (_) {}
    }

    final data = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: _escuro
                ? const ColorScheme.dark(
                    primary: verdeClaro,
                    onPrimary: Colors.white,
                    surface: Color(0xFF202B23),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: verde,
                    onPrimary: Colors.white,
                    surface: fundo,
                    onSurface: verde,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (data == null || !mounted) return;

    setState(() {
      _data.text =
          '${data.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')}/'
          '${data.year}';

      _mes = _meses[data.month - 1];
    });
  }

  double? _converterValor(String texto) {
    var valor = texto.trim().replaceAll(' ', '');

    if (valor.isEmpty) return null;

    if (valor.contains(',') && valor.contains('.')) {
      valor = valor.replaceAll('.', '').replaceAll(',', '.');
    } else {
      valor = valor.replaceAll(',', '.');
    }

    return double.tryParse(valor);
  }

  Future<bool> _salvar(Gestao? item) async {
    final descricao = _descricao.text.trim();
    final valor = _converterValor(_valor.text);
    final data = _data.text.trim();

    if (descricao.isEmpty) {
      _msg('Informe a descrição.');
      return false;
    }

    if (valor == null || valor <= 0) {
      _msg('Informe um valor válido maior que zero.');
      return false;
    }

    if (data.isEmpty) {
      _msg('Informe a data.');
      return false;
    }

    try {
      if (item == null) {
        await _service.adicionarGestao(
          tipo: _tipo,
          descricao: descricao,
          categoria: _categoria,
          valor: valor,
          data: data,
          mes: _mes,
        );
      } else {
        await _service.atualizarGestao(
          id: item.id,
          tipo: _tipo,
          descricao: descricao,
          categoria: _categoria,
          valor: valor,
          data: data,
          mes: _mes,
        );
      }

      if (!mounted) return false;

      _msg(
        item == null
            ? 'Lançamento adicionado com sucesso!'
            : 'Lançamento atualizado com sucesso!',
      );

      return true;
    } catch (e) {
      debugPrint('Erro Gestão: $e');
      _msg('Erro ao salvar lançamento.');
      return false;
    }
  }

  Future<void> _abrirFormulario([Gestao? item]) async {
    if (item == null) {
      _limpar();
    } else {
      _editarCampos(item);
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _corFundo,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        bool salvando = false;

        return StatefulBuilder(
          builder: (context, atualizarModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item == null
                                ? 'Novo lançamento'
                                : 'Editar lançamento',
                            style: TextStyle(
                              color: _corTexto,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: salvando
                              ? null
                              : () => Navigator.pop(modalContext),
                          icon: Icon(Icons.close, color: _corTexto),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      initialValue: _tipo,
                      isExpanded: true,
                      decoration: _dec('Tipo', Icons.swap_vert),
                      dropdownColor: _corCartao,
                      style: TextStyle(color: _corTexto),
                      items: const [
                        DropdownMenuItem(
                          value: 'Receita',
                          child: Text('Receita'),
                        ),
                        DropdownMenuItem(
                          value: 'Despesa',
                          child: Text('Despesa'),
                        ),
                      ],
                      onChanged: salvando
                          ? null
                          : (valor) {
                              if (valor == null) return;

                              atualizarModal(() {
                                _tipo = valor;
                                _categoria = _categorias.first;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descricao,
                      enabled: !salvando,
                      style: TextStyle(color: _corTexto),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _dec('Descrição', Icons.description_outlined),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('categoria-$_tipo-$_categoria'),
                      initialValue: _categorias.contains(_categoria)
                          ? _categoria
                          : _categorias.first,
                      isExpanded: true,
                      decoration: _dec('Categoria', Icons.category_outlined),
                      dropdownColor: _corCartao,
                      style: TextStyle(color: _corTexto),
                      items: _categorias
                          .map(
                            (categoria) => DropdownMenuItem(
                              value: categoria,
                              child: Text(categoria),
                            ),
                          )
                          .toList(),
                      onChanged: salvando
                          ? null
                          : (valor) {
                              if (valor != null) {
                                atualizarModal(() {
                                  _categoria = valor;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _valor,
                      enabled: !salvando,
                      style: TextStyle(color: _corTexto),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _dec('Valor (R\$)', Icons.attach_money),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _data,
                      readOnly: true,
                      enabled: !salvando,
                      style: TextStyle(color: _corTexto),
                      onTap: salvando ? null : _selecionarData,
                      decoration: _dec(
                        'Data',
                        Icons.calendar_month_outlined,
                      ).copyWith(hintText: 'dd/MM/yyyy'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _mes,
                      isExpanded: true,
                      decoration: _dec('Mês', Icons.date_range_outlined),
                      dropdownColor: _corCartao,
                      style: TextStyle(color: _corTexto),
                      items: _meses
                          .map(
                            (mes) =>
                                DropdownMenuItem(value: mes, child: Text(mes)),
                          )
                          .toList(),
                      onChanged: salvando
                          ? null
                          : (valor) {
                              if (valor != null) {
                                atualizarModal(() {
                                  _mes = valor;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: salvando
                            ? null
                            : () async {
                                atualizarModal(() {
                                  salvando = true;
                                });

                                final salvo = await _salvar(item);

                                if (!modalContext.mounted) return;

                                if (salvo) {
                                  Navigator.pop(modalContext);
                                } else {
                                  atualizarModal(() {
                                    salvando = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verde,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: verdeClaro,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: salvando
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                item == null
                                    ? 'Cadastrar lançamento'
                                    : 'Salvar alterações',
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
          },
        );
      },
    );

    if (mounted) {
      setState(_limpar);
    }
  }

  Future<void> _excluir(Gestao item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _corCartao,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            'Excluir lançamento',
            style: TextStyle(
              color: _corTexto,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deseja realmente excluir "${item.descricao}"? Essa ação não poderá ser desfeita.',
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
                  backgroundColor: verde,
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
      await _service.excluirGestao(id: item.id);
      _msg('Lançamento excluído com sucesso!');
    } catch (e) {
      debugPrint('Erro ao excluir: $e');
      _msg('Erro ao excluir lançamento.');
    }
  }

  List<Gestao> _filtrar(List<Gestao> lista) {
    final busca = _busca.text.toLowerCase().trim();

    return lista.where((item) {
      final texto =
          item.descricao.toLowerCase().contains(busca) ||
          item.categoria.toLowerCase().contains(busca);

      return texto && (_filtro == 'Todos' || item.tipo == _filtro);
    }).toList();
  }

  double _total(List<Gestao> lista, String tipo) {
    return lista
        .where((item) => item.tipo == tipo)
        .fold(0.0, (soma, item) => soma + item.valor);
  }

  String _moeda(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final inteiro = partes[0];
    final buffer = StringBuffer();

    for (int i = 0; i < inteiro.length; i++) {
      buffer.write(inteiro[i]);

      final restante = inteiro.length - i - 1;

      if (restante > 0 && restante % 3 == 0) {
        buffer.write('.');
      }
    }

    return 'R\$ ${buffer.toString()},${partes[1]}';
  }

  InputDecoration _dec(String label, IconData icone) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _corTextoSecundario),
      prefixIcon: Icon(icone, color: _corDestaque),
      filled: true,
      fillColor: _corCampo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _corBorda),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _corBorda),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _corDestaque, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _corFundo,
      appBar: const AgroPlantAppBar(
        backgroundColor: verde,
        foregroundColor: Colors.white,
        centerTitle: true,
        fallbackRoute: '/planilhas',
        title: Text('Gestão', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: verde,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo lançamento'),
      ),
      body: StreamBuilder<List<Gestao>>(
        stream: _service.listarGestao(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar gestão.',
                style: TextStyle(color: _corTextoSecundario),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: verde));
          }

          final todos = snapshot.data ?? [];
          final lista = _filtrar(todos);
          final receitas = _total(todos, 'Receita');
          final despesas = _total(todos, 'Despesa');
          final saldo = receitas - despesas;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              Text(
                'Controle financeiro',
                style: TextStyle(
                  color: _corTexto,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Acompanhe suas receitas, despesas e saldo.',
                style: TextStyle(color: _corTextoSecundario, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _Resumo(
                    titulo: 'Receitas',
                    valor: _moeda(receitas),
                    cor: verdeClaro,
                    icone: Icons.trending_up,
                  ),
                  _Resumo(
                    titulo: 'Despesas',
                    valor: _moeda(despesas),
                    cor: Colors.red.shade700,
                    icone: Icons.trending_down,
                  ),
                  _Resumo(
                    titulo: 'Saldo',
                    valor: _moeda(saldo),
                    cor: saldo < 0 ? Colors.red.shade700 : _corDestaque,
                    icone: Icons.account_balance_wallet_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _busca,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: _corTexto),
                decoration: _dec('Buscar lançamentos', Icons.search).copyWith(
                  suffixIcon: _busca.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _busca.clear();
                            setState(() {});
                          },
                          icon: Icon(Icons.close, color: _corTextoSecundario),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _Filtro(
                    titulo: 'Todos',
                    selecionado: _filtro == 'Todos',
                    onTap: () => setState(() => _filtro = 'Todos'),
                  ),
                  _Filtro(
                    titulo: 'Receitas',
                    selecionado: _filtro == 'Receita',
                    onTap: () => setState(() => _filtro = 'Receita'),
                  ),
                  _Filtro(
                    titulo: 'Despesas',
                    selecionado: _filtro == 'Despesa',
                    onTap: () => setState(() => _filtro = 'Despesa'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lançamentos',
                      style: TextStyle(
                        color: _corTexto,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _corCampo,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _corBorda),
                    ),
                    child: Text(
                      '${lista.length}',
                      style: TextStyle(
                        color: _corTexto,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (lista.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: _corCartao,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _corBorda),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: _corDestaque,
                        size: 52,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum lançamento encontrado.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _corTexto,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Adicione receitas e despesas para acompanhar suas finanças.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _corTextoSecundario),
                      ),
                    ],
                  ),
                )
              else
                ...lista.map(
                  (item) => _CardGestao(
                    item: item,
                    moeda: _moeda,
                    editar: () => _abrirFormulario(item),
                    excluir: () => _excluir(item),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color cor;
  final IconData icone;

  const _Resumo({
    required this.titulo,
    required this.valor,
    required this.cor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final cartao = escuro ? const Color(0xFF202B23) : Colors.white;
    final texto = escuro ? Colors.white : const Color(0xFF174D2A);
    final borda = escuro ? const Color(0xFF46594A) : const Color(0xFFE8DCC6);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14),
        decoration: BoxDecoration(
          color: cartao,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borda),
        ),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 25),
            const SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valor,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: texto,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Filtro extends StatelessWidget {
  final String titulo;
  final bool selecionado;
  final VoidCallback onTap;

  const _Filtro({
    required this.titulo,
    required this.selecionado,
    required this.onTap,
  });

  static const verde = Color(0xFF174D2A);
  static const bege = Color(0xFFE8DCC6);

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final cartao = escuro ? const Color(0xFF202B23) : Colors.white;
    final borda = escuro ? const Color(0xFF46594A) : bege;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: selecionado ? verde : cartao,
            foregroundColor: selecionado
                ? Colors.white
                : escuro
                ? Colors.white
                : verde,
            side: BorderSide(color: selecionado ? verdeClaro : borda),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  static const verdeClaro = Color(0xFF78A878);
}

class _CardGestao extends StatelessWidget {
  final Gestao item;
  final String Function(double) moeda;
  final VoidCallback editar;
  final VoidCallback excluir;

  const _CardGestao({
    required this.item,
    required this.moeda,
    required this.editar,
    required this.excluir,
  });

  static const verde = Color(0xFF174D2A);
  static const verdeClaro = Color(0xFF78A878);
  static const bege = Color(0xFFE8DCC6);

  @override
  Widget build(BuildContext context) {
    final receita = item.tipo == 'Receita';
    final cor = receita ? verdeClaro : Colors.red.shade700;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final cartao = escuro ? const Color(0xFF202B23) : Colors.white;
    final texto = escuro ? Colors.white : verde;
    final textoSecundario = escuro ? Colors.white70 : const Color(0xFF62594B);
    final borda = escuro ? const Color(0xFF46594A) : bege;

    return Card(
      color: cartao,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(color: borda),
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
                    color: cor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    receita ? Icons.trending_up : Icons.trending_down,
                    color: cor,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.descricao,
                        style: TextStyle(
                          color: texto,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.categoria,
                        style: TextStyle(color: textoSecundario, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.tipo,
                    style: TextStyle(
                      color: receita ? verdeClaro : cor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 25, color: borda),
            _Info(
              titulo: 'Valor',
              valor: moeda(item.valor),
              cor: receita ? verdeClaro : cor,
            ),
            _Info(titulo: 'Data', valor: formatarDataBrasil(item.data)),
            _Info(titulo: 'Mês', valor: item.mes),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: editar,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: escuro ? Colors.white : verde,
                      side: BorderSide(color: borda),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: excluir,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Excluir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
}

class _Info extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color? cor;

  const _Info({required this.titulo, required this.valor, this.cor});

  static const verde = Color(0xFF174D2A);

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final texto = escuro ? Colors.white70 : const Color(0xFF62594B);
    final destaque = escuro ? Colors.white : verde;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(titulo, style: TextStyle(color: texto, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                color: cor ?? destaque,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
