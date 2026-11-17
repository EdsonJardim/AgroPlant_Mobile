import 'package:flutter/material.dart';

import '../models/estoque.dart';
import '../services/estoque_service.dart';
import '../widgets/agroplant_app_bar.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  final _service = EstoqueService();

  final _busca = TextEditingController();
  final _produto = TextEditingController();
  final _quantidade = TextEditingController();
  final _preco = TextEditingController();
  final _data = TextEditingController();

  static const verde = Color(0xFF174D2A);
  static const verdeClaro = Color(0xFF78A878);
  static const bege = Color(0xFFE8DCC6);
  static const fundo = Color(0xFFF7F2E8);
  static const textoSecundario = Color(0xFF62594B);

  final List<String> _categorias = [
    'Semente',
    'Muda',
    'Fertilizante',
    'Adubo',
    'Calcário',
    'Defensivo',
    'Herbicida',
    'Inseticida',
    'Fungicida',
    'Ração',
    'Medicamento veterinário',
    'Ferramenta',
    'Peça de máquina',
    'Combustível',
    'Lubrificante',
    'Equipamento de irrigação',
    'EPI',
    'Armazenamento',
    'Outro',
  ];

  final List<String> _unidades = [
    'kg',
    'g',
    'mg',
    't',
    'L',
    'mL',
    'unid.',
    'saco',
    'caixa',
    'pacote',
    'litro',
    'metro',
    'par',
    'galão',
  ];

  String _categoria = 'Semente';
  String _unidade = 'kg';
  String _filtro = '';

  bool get _escuro =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _corFundo =>
      _escuro ? const Color(0xFF121A14) : fundo;

  Color get _corTexto =>
      _escuro ? Colors.white : verde;

  Color get _corTextoSecundario =>
      _escuro ? Colors.white70 : textoSecundario;

  Color get _corDestaque =>
      _escuro ? verdeClaro : verde;

  @override
  void dispose() {
    _busca.dispose();
    _produto.dispose();
    _quantidade.dispose();
    _preco.dispose();
    _data.dispose();
    super.dispose();
  }

  void _msg(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          behavior: SnackBarBehavior.floating,
          backgroundColor: verde,
        ),
      );
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

  double? _converterNumero(String texto) {
    var valor = texto.trim().replaceAll(' ', '');

    if (valor.isEmpty) return null;

    if (valor.contains(',') && valor.contains('.')) {
      valor = valor.replaceAll('.', '').replaceAll(',', '.');
    } else {
      valor = valor.replaceAll(',', '.');
    }

    return double.tryParse(valor);
  }

  InputDecoration _dec(
    BuildContext context,
    String label,
    IconData icone,
  ) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final corDestaque = escuro ? verdeClaro : verde;
    final corFundo = escuro
        ? const Color(0xFF29372D)
        : Colors.white;
    final corBorda = escuro
        ? const Color(0xFF46594A)
        : bege;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: escuro ? verdeClaro : textoSecundario),
      prefixIcon: Icon(icone, color: corDestaque),
      filled: true,
      fillColor: corFundo,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: corBorda),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: corBorda),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: verdeClaro, width: 2),
      ),
    );
  }

  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    DateTime inicial = DateTime(agora.year, agora.month, agora.day);

    if (_data.text.isNotEmpty) {
      final partes = _data.text.split('/');

      if (partes.length == 3) {
        try {
          inicial = DateTime(
            int.parse(partes[2]),
            int.parse(partes[1]),
            int.parse(partes[0]),
          );
        } catch (_) {}
      }
    }

    final escuro = _escuro;

    final data = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: escuro
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
    });
  }

  void _limparFormulario() {
    _produto.clear();
    _quantidade.clear();
    _preco.clear();
    _data.clear();
    _categoria = 'Semente';
    _unidade = 'kg';
  }

  void _preencherFormulario(Estoque item) {
    _produto.text = item.produto;
    _quantidade.text = item.quantidade.toString();
    _preco.text = item.preco.toStringAsFixed(2);
    _data.text = _formatarData(item.data);

    _categoria = _categorias.contains(item.categoria)
        ? item.categoria
        : 'Semente';

    _unidade = _unidades.contains(item.unidade)
        ? item.unidade
        : 'kg';
  }

  String _formatarData(String data) {
    if (data.isEmpty || data.contains('/')) return data;

    final partes = data.split('-');

    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }

    return data;
  }

  Future<bool> _salvar(Estoque? item) async {
    final produto = _produto.text.trim();
    final quantidade = _converterNumero(_quantidade.text);
    final preco = _converterNumero(_preco.text);
    final data = _data.text.trim();

    if (produto.isEmpty) {
      _msg('Informe o nome do produto.');
      return false;
    }

    if (quantidade == null || quantidade <= 0) {
      _msg('Informe uma quantidade válida maior que zero.');
      return false;
    }

    if (preco == null || preco <= 0) {
      _msg('Informe um preço válido maior que zero.');
      return false;
    }

    if (data.isEmpty) {
      _msg('Informe a data.');
      return false;
    }

    try {
      if (item == null) {
        await _service.adicionarEstoque(
          produto: produto,
          categoria: _categoria,
          quantidade: quantidade,
          unidade: _unidade,
          preco: preco,
          data: data,
        );
      } else {
        await _service.atualizarEstoque(
          id: item.id,
          produto: produto,
          categoria: _categoria,
          quantidade: quantidade,
          unidade: _unidade,
          preco: preco,
          data: data,
        );
      }

      if (!mounted) return false;

      _msg(
        item == null
            ? 'Produto adicionado com sucesso!'
            : 'Produto atualizado com sucesso!',
      );

      return true;
    } catch (_) {
      _msg('Não foi possível salvar o produto. Tente novamente.');
      return false;
    }
  }

  Future<void> _abrirFormulario([Estoque? item]) async {
    if (item == null) {
      _limparFormulario();
    } else {
      _preencherFormulario(item);
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _corFundo,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (modalContext) {
        bool salvando = false;

        return StatefulBuilder(
          builder: (context, atualizarModal) {
            final escuro =
                Theme.of(context).brightness == Brightness.dark;
            final corTexto = escuro ? Colors.white : verde;

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
                                ? 'Adicionar produto'
                                : 'Editar produto',
                            style: TextStyle(
                              color: corTexto,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: salvando
                              ? null
                              : () => Navigator.pop(modalContext),
                          icon: Icon(Icons.close, color: corTexto),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _produto,
                      enabled: !salvando,
                      style: TextStyle(color: corTexto),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _dec(
                        context,
                        'Nome do produto',
                        Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('categoria-$_categoria'),
                      initialValue: _categoria,
                      isExpanded: true,
                      dropdownColor: escuro
                          ? const Color(0xFF29372D)
                          : Colors.white,
                      style: TextStyle(color: corTexto),
                      decoration: _dec(
                        context,
                        'Categoria',
                        Icons.category_outlined,
                      ),
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
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _quantidade,
                            enabled: !salvando,
                            style: TextStyle(color: corTexto),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _dec(
                              context,
                              'Quantidade',
                              Icons.scale_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            key: ValueKey('unidade-$_unidade'),
                            initialValue: _unidade,
                            isExpanded: true,
                            dropdownColor: escuro
                                ? const Color(0xFF29372D)
                                : Colors.white,
                            style: TextStyle(color: corTexto),
                            decoration: _dec(
                              context,
                              'Unidade',
                              Icons.straighten,
                            ),
                            items: _unidades
                                .map(
                                  (unidade) => DropdownMenuItem(
                                    value: unidade,
                                    child: Text(unidade),
                                  ),
                                )
                                .toList(),
                            onChanged: salvando
                                ? null
                                : (valor) {
                                    if (valor != null) {
                                      atualizarModal(() {
                                        _unidade = valor;
                                      });
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _preco,
                      enabled: !salvando,
                      style: TextStyle(color: corTexto),
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _dec(
                        context,
                        'Preço unitário (R\$)',
                        Icons.attach_money,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _data,
                      readOnly: true,
                      enabled: !salvando,
                      style: TextStyle(color: corTexto),
                      onTap: salvando ? null : _selecionarData,
                      decoration: _dec(
                        context,
                        'Data',
                        Icons.calendar_month_outlined,
                      ).copyWith(hintText: 'dd/MM/yyyy'),
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
                                    ? 'Cadastrar produto'
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
      setState(_limparFormulario);
    }
  }

  Future<void> _excluir(Estoque item) async {
    final escuro = _escuro;

    final corFundo = escuro
        ? const Color(0xFF202B23)
        : fundo;
    final corTexto = escuro ? Colors.white : verde;
    final corTextoSecundario = escuro
        ? Colors.white70
        : textoSecundario;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: corFundo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            'Excluir produto',
            style: TextStyle(
              color: corTexto,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deseja realmente excluir "${item.produto}" do estoque? Essa ação não poderá ser desfeita.',
            style: TextStyle(
              color: corTextoSecundario,
              fontSize: 16,
            ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                ),
                label: const Text(
                  'Excluir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
      await _service.excluirEstoque(id: item.id);
      _msg('Produto excluído do estoque com sucesso!');
    } catch (e) {
      debugPrint('Erro ao excluir produto do estoque: $e');
      _msg('Erro ao excluir produto do estoque.');
    }
  }

  List<Estoque> _filtrar(List<Estoque> lista) {
    final busca = _filtro.trim().toLowerCase();

    return lista.where((item) {
      return item.produto.toLowerCase().contains(busca) ||
          item.categoria.toLowerCase().contains(busca);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _corFundo,
      appBar: const AgroPlantAppBar(
        backgroundColor: verde,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Estoque',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: verde,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Adicionar produto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Estoque>>(
        stream: _service.listarEstoque(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar o estoque.',
                style: TextStyle(color: _corTextoSecundario),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: verde),
            );
          }

          final todos = snapshot.data ?? [];
          final lista = _filtrar(todos);

          final valorTotal = todos.fold<double>(
            0,
            (soma, item) => soma + item.quantidade * item.preco,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              Text(
                'Controle de estoque',
                style: TextStyle(
                  color: _corTexto,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Acompanhe seus produtos, quantidades e valores.',
                style: TextStyle(
                  color: _corTextoSecundario,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _ResumoEstoque(
                    titulo: 'Produtos',
                    valor: '${todos.length}',
                    cor: verdeClaro,
                    icone: Icons.inventory_2_outlined,
                  ),
                  _ResumoEstoque(
                    titulo: 'Categorias',
                    valor:
                        '${todos.map((item) => item.categoria).toSet().length}',
                    cor: verdeClaro,
                    icone: Icons.category_outlined,
                  ),
                  _ResumoEstoque(
                    titulo: 'Valor total',
                    valor: _moeda(valorTotal),
                    cor: Colors.orange.shade800,
                    icone: Icons.attach_money,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _busca,
                style: TextStyle(color: _corTexto),
                onChanged: (valor) {
                  setState(() => _filtro = valor);
                },
                decoration: _dec(
                  context,
                  'Buscar produtos',
                  Icons.search,
                ).copyWith(
                  suffixIcon: _busca.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _busca.clear();
                            setState(() => _filtro = '');
                          },
                          icon: Icon(
                            Icons.close,
                            color: _corDestaque,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Produtos cadastrados',
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
                      color: _escuro
                          ? const Color(0xFF29372D)
                          : bege,
                      borderRadius: BorderRadius.circular(20),
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
              if (todos.isEmpty)
                _EstadoEstoque(
                  mensagem: 'Seu estoque está vazio.',
                  descricao:
                      'Adicione produtos para acompanhar suas quantidades e valores.',
                )
              else if (lista.isEmpty)
                _EstadoEstoque(
                  mensagem: 'Nenhum produto encontrado.',
                )
              else
                ...lista.map(
                  (item) => _CardEstoque(
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

class _EstadoEstoque extends StatelessWidget {
  final String mensagem;
  final String? descricao;

  const _EstadoEstoque({
    required this.mensagem,
    this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final corCartao = escuro
        ? const Color(0xFF202B23)
        : Colors.white;
    final corTexto = escuro
        ? Colors.white
        : const Color(0xFF174D2A);
    final corSecundaria = escuro
        ? Colors.white70
        : const Color(0xFF62594B);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: corCartao,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: escuro
              ? const Color(0xFF46594A)
              : const Color(0xFFE8DCC6),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFF78A878),
            size: 52,
          ),
          const SizedBox(height: 12),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: corTexto,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (descricao != null) ...[
            const SizedBox(height: 6),
            Text(
              descricao!,
              textAlign: TextAlign.center,
              style: TextStyle(color: corSecundaria),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResumoEstoque extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color cor;
  final IconData icone;

  const _ResumoEstoque({
    required this.titulo,
    required this.valor,
    required this.cor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final corCartao = escuro
        ? const Color(0xFF202B23)
        : Colors.white;
    final corTexto = escuro
        ? Colors.white
        : const Color(0xFF174D2A);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: corCartao,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: escuro
                ? const Color(0xFF46594A)
                : const Color(0xFFE8DCC6),
          ),
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
                  color: corTexto,
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

class _CardEstoque extends StatelessWidget {
  final Estoque item;
  final String Function(double) moeda;
  final VoidCallback editar;
  final VoidCallback excluir;

  const _CardEstoque({
    required this.item,
    required this.moeda,
    required this.editar,
    required this.excluir,
  });

  static const verde = Color(0xFF174D2A);
  static const verdeClaro = Color(0xFF78A878);
  static const bege = Color(0xFFE8DCC6);
  static const textoSecundario = Color(0xFF62594B);

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final corCartao = escuro
        ? const Color(0xFF202B23)
        : Colors.white;
    final corTexto = escuro ? Colors.white : verde;
    final corSecundaria = escuro
        ? Colors.white70
        : textoSecundario;
    final corBorda = escuro
        ? const Color(0xFF46594A)
        : bege;

    return Card(
      color: corCartao,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(color: corBorda),
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
                    color: verdeClaro.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: verdeClaro,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.produto,
                        style: TextStyle(
                          color: corTexto,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.categoria,
                        style: TextStyle(
                          color: corSecundaria,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 25, color: corBorda),
            _InfoEstoque(
              titulo: 'Quantidade',
              valor: '${item.quantidade} ${item.unidade}',
            ),
            _InfoEstoque(
              titulo: 'Preço unitário',
              valor: moeda(item.preco),
            ),
            _InfoEstoque(
              titulo: 'Valor total',
              valor: moeda(item.quantidade * item.preco),
              cor: escuro ? verdeClaro : verde,
            ),
            _InfoEstoque(
              titulo: 'Data',
              valor: _formatarData(item.data),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: editar,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                    ),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: escuro ? verdeClaro : verde,
                      side: BorderSide(color: corBorda),
                      padding: const EdgeInsets.symmetric(vertical: 11),
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
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                    ),
                    label: const Text('Excluir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      side: BorderSide(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
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

  static String _formatarData(String data) {
    if (data.isEmpty || data.contains('/')) return data;

    final partes = data.split('-');

    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }

    return data;
  }
}

class _InfoEstoque extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color? cor;

  const _InfoEstoque({
    required this.titulo,
    required this.valor,
    this.cor,
  });

  static const verde = Color(0xFF174D2A);
  static const textoSecundario = Color(0xFF62594B);

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              titulo,
              style: TextStyle(
                color: escuro ? Colors.white70 : textoSecundario,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                color: cor ??
                    (escuro ? Colors.white : verde),
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