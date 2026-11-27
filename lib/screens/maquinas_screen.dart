import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/maquina.dart';
import '../services/maquina_service.dart';
import '../widgets/agroplant_app_bar.dart';

const Color verde = Color(0xFF174D2A);
const Color verdeClaro = Color(0xFF78A878);
const Color bege = Color(0xFFE8DCC6);
const Color fundo = Color(0xFFF7F2E8);
const Color textoSecundario = Color(0xFF62594B);

String _formatarDataBrasilMaquina(String data) {
  if (data.isEmpty) return 'Não informada';

  try {
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(data));
  } catch (_) {
    return data;
  }
}

class MaquinasScreen extends StatefulWidget {
  const MaquinasScreen({super.key});

  @override
  State<MaquinasScreen> createState() => _MaquinasScreenState();
}

class _MaquinasScreenState extends State<MaquinasScreen> {
  final MaquinaService _service = MaquinaService();
  final TextEditingController _busca = TextEditingController();

  final List<String> _tipos = [
    'Trator',
    'Colheitadeira',
    'Pulverizador',
    'Irrigação',
    'Plantadeira',
    'Semeadeira',
    'Adubadora',
    'Arado',
    'Grade Agrícola',
    'Enxada Rotativa',
    'Roçadeira',
    'Carreta Agrícola',
    'Caminhão',
    'Veículo',
    'Drone Agrícola',
    'Motobomba',
    'Gerador',
    'Triturador',
    'Ensiladeira',
    'Ordenhadeira',
    'Ferramentas',
    'Outro',
  ];

  final List<String> _status = ['Operacional', 'Em manutenção', 'Inativa'];

  String _filtro = 'Todas';

  bool get _escuro => Theme.of(context).brightness == Brightness.dark;

  Color get _corFundo => _escuro ? const Color(0xFF121A14) : fundo;

  Color get _corCartao => _escuro ? const Color(0xFF202B23) : Colors.white;

  Color get _corCampo => _escuro ? const Color(0xFF29372D) : Colors.white;

  Color get _corBorda => _escuro ? const Color(0xFF46594A) : bege;

  Color get _corTexto => _escuro ? Colors.white : verde;

  Color get _corTextoSecundario => _escuro ? Colors.white70 : textoSecundario;

  Color get _corDestaque => _escuro ? verdeClaro : verde;

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
          backgroundColor: erro ? Colors.red.shade700 : verde,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  List<Maquina> _filtrar(List<Maquina> maquinas) {
    final consulta = _busca.text.trim().toLowerCase();

    return maquinas.where((maquina) {
      final correspondeBusca =
          maquina.nome.toLowerCase().contains(consulta) ||
          maquina.tipo.toLowerCase().contains(consulta) ||
          maquina.status.toLowerCase().contains(consulta);

      final correspondeFiltro =
          _filtro == 'Todas' ||
          (_filtro == 'Operacionais' && maquina.status == 'Operacional') ||
          (_filtro == 'Manutenção' && maquina.status == 'Em manutenção') ||
          (_filtro == 'Inativas' && maquina.status == 'Inativa');

      return correspondeBusca && correspondeFiltro;
    }).toList();
  }

  Future<void> _abrirFormulario({Maquina? maquina}) async {
    final nomeController = TextEditingController(text: maquina?.nome ?? '');
    final horasController = TextEditingController(
      text: maquina?.horasUso ?? '',
    );
    final ultimaController = TextEditingController(
      text: maquina?.ultimaManutencao ?? '',
    );
    final proximaController = TextEditingController(
      text: maquina?.proximaManutencao ?? '',
    );
    final obsController = TextEditingController(text: maquina?.obs ?? '');

    String tipo = _tipos.contains(maquina?.tipo) ? maquina!.tipo : 'Trator';

    String status = _status.contains(maquina?.status)
        ? maquina!.status
        : 'Operacional';

    bool salvando = false;

    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _corFundo,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (contextModal, atualizarModal) {
            Future<void> selecionarData(
              TextEditingController controller,
            ) async {
              DateTime inicial;

              try {
                inicial = controller.text.isNotEmpty
                    ? DateTime.parse(controller.text)
                    : DateTime.now();
              } catch (_) {
                inicial = DateTime.now();
              }

              final data = await showDatePicker(
                context: contextModal,
                initialDate: inicial,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                locale: const Locale('pt', 'BR'),
                helpText: 'Selecione a data',
                cancelText: 'Cancelar',
                confirmText: 'Confirmar',
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

              if (data != null) {
                controller.text = DateFormat('yyyy-MM-dd').format(data);
                atualizarModal(() {});
              }
            }

            Future<void> salvar() async {
              final nome = nomeController.text.trim();
              final horas = horasController.text.trim();

              if (nome.isEmpty) {
                _mensagem('Informe o nome da máquina.', erro: true);
                return;
              }

              if (!RegExp(r'^\d+:[0-5]\d$').hasMatch(horas)) {
                _mensagem(
                  'Informe as horas no formato HH:MM. Exemplo: 08:30.',
                  erro: true,
                );
                return;
              }

              if (ultimaController.text.isEmpty) {
                _mensagem('Informe a data da última manutenção.', erro: true);
                return;
              }

              atualizarModal(() => salvando = true);

              try {
                final agora = Timestamp.now();

                final novaMaquina = Maquina(
                  id: maquina?.id ?? '',
                  nome: nome,
                  tipo: tipo,
                  status: status,
                  horasUso: horas,
                  ultimaManutencao: ultimaController.text,
                  proximaManutencao: proximaController.text,
                  obs: obsController.text.trim(),
                  createdAt: maquina?.createdAt ?? agora,
                  updatedAt: agora,
                );

                if (maquina == null) {
                  await _service.adicionarMaquina(novaMaquina);
                } else {
                  await _service.atualizarMaquina(novaMaquina);
                }

                if (modalContext.mounted) {
                  Navigator.of(modalContext).pop(true);
                }
              } catch (e) {
                atualizarModal(() => salvando = false);
                _mensagem('Não foi possível salvar a máquina: $e', erro: true);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(contextModal).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                            maquina == null
                                ? 'Adicionar máquina'
                                : 'Editar máquina',
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
                      controller: nomeController,
                      label: 'Nome da máquina',
                      icone: Icons.precision_manufacturing_outlined,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: tipo,
                      isExpanded: true,
                      decoration: _decoracao(
                        'Tipo de máquina',
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
                        'Status',
                        Icons.check_circle_outline,
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
                      controller: horasController,
                      label: 'Horas de uso (HH:MM)',
                      icone: Icons.timer_outlined,
                      teclado: TextInputType.datetime,
                    ),
                    const SizedBox(height: 14),
                    _campo(
                      controller: ultimaController,
                      label: 'Última manutenção',
                      icone: Icons.event_outlined,
                      somenteLeitura: true,
                      aoTocar: () => selecionarData(ultimaController),
                      sufixo: Icon(
                        Icons.calendar_month_outlined,
                        color: _corDestaque,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _campo(
                      controller: proximaController,
                      label: 'Próxima manutenção',
                      icone: Icons.event_available_outlined,
                      somenteLeitura: true,
                      aoTocar: () => selecionarData(proximaController),
                      sufixo: Icon(
                        Icons.calendar_month_outlined,
                        color: _corDestaque,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _campo(
                      controller: obsController,
                      label: 'Observações',
                      icone: Icons.notes_outlined,
                      maxLinhas: 3,
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
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          salvando ? 'Salvando...' : 'Salvar máquina',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verde,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: verdeClaro,
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

    nomeController.dispose();
    horasController.dispose();
    ultimaController.dispose();
    proximaController.dispose();
    obsController.dispose();

    if (resultado == true && mounted) {
      _mensagem(
        maquina == null
            ? 'Máquina cadastrada com sucesso!'
            : 'Máquina atualizada com sucesso!',
      );
    }
  }

  Future<void> _confirmarExclusao(Maquina maquina) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _corCartao,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            'Excluir máquina',
            style: TextStyle(
              color: _corTexto,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deseja realmente excluir "${maquina.nome}"? Essa ação não poderá ser desfeita.',
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
      await _service.excluirMaquina(maquina.id);
      _mensagem('Máquina excluída com sucesso!');
    } catch (e) {
      _mensagem('Não foi possível excluir a máquina: $e', erro: true);
    }
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
        title: Text('Máquinas', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: verde,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Adicionar máquina',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Maquina>>(
        stream: _service.observarMaquinas(),
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
                      'Não foi possível carregar as máquinas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _corTextoSecundario,
                        fontSize: 16,
                      ),
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
            return const Center(child: CircularProgressIndicator(color: verde));
          }

          final maquinas = snapshot.data ?? [];
          final filtradas = _filtrar(maquinas);

          final operacionais = maquinas
              .where((m) => m.status == 'Operacional')
              .length;
          final manutencao = maquinas
              .where((m) => m.status == 'Em manutenção')
              .length;
          final inativas = maquinas.where((m) => m.status == 'Inativa').length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              Text(
                'Gestão de máquinas',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: _corTexto,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Acompanhe seus equipamentos e suas manutenções.',
                style: TextStyle(fontSize: 14, color: _corTextoSecundario),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _resumo(
                      titulo: 'Operacionais',
                      quantidade: operacionais,
                      icone: Icons.check_circle_outline,
                      cor: verdeClaro,
                    ),
                  ),
                  Expanded(
                    child: _resumo(
                      titulo: 'Manutenção',
                      quantidade: manutencao,
                      icone: Icons.build_outlined,
                      cor: Colors.orange.shade800,
                    ),
                  ),
                  Expanded(
                    child: _resumo(
                      titulo: 'Inativas',
                      quantidade: inativas,
                      icone: Icons.pause_circle_outline,
                      cor: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _busca,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: _corTexto),
                decoration: InputDecoration(
                  hintText: 'Buscar máquina...',
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
                  _botaoFiltro('Operacionais'),
                  _botaoFiltro('Manutenção'),
                  _botaoFiltro('Inativas'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Máquinas cadastradas',
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
                      color: _corCampo,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _corBorda),
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
                _estadoVazio(maquinas.isEmpty)
              else
                ...filtradas.map(_cartaoMaquina),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: _corCartao,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _corBorda),
      ),
      child: Column(
        children: [
          Icon(icone, color: cor, size: 24),
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoFiltro(String titulo) {
    final selecionado = _filtro == titulo;

    return OutlinedButton(
      onPressed: () => setState(() => _filtro = titulo),
      style: OutlinedButton.styleFrom(
        backgroundColor: selecionado ? verde : _corCartao,
        foregroundColor: selecionado ? Colors.white : _corTexto,
        side: BorderSide(color: selecionado ? verdeClaro : _corBorda),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
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
            semCadastro
                ? Icons.precision_manufacturing_outlined
                : Icons.search_off_outlined,
            size: 48,
            color: _corDestaque,
          ),
          const SizedBox(height: 14),
          Text(
            semCadastro
                ? 'Nenhuma máquina cadastrada'
                : 'Nenhuma máquina encontrada',
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
                ? 'Adicione sua primeira máquina para começar.'
                : 'Tente alterar a busca ou selecionar outro filtro.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _corTextoSecundario),
          ),
        ],
      ),
    );
  }

  Widget _cartaoMaquina(Maquina maquina) {
    final corStatus = switch (maquina.status) {
      'Operacional' => verdeClaro,
      'Em manutenção' => Colors.orange.shade800,
      'Inativa' => Colors.red.shade700,
      _ => textoSecundario,
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
                    color: verdeClaro.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.precision_manufacturing_outlined,
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
                        maquina.nome,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _corTexto,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        maquina.tipo,
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
                      maquina.status,
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
              Icons.timer_outlined,
              'Horas de uso',
              '${maquina.horasUso} h',
            ),
            const SizedBox(height: 11),
            _linhaInformacao(
              Icons.event_outlined,
              'Última manutenção',
              _formatarDataBrasilMaquina(maquina.ultimaManutencao),
            ),
            const SizedBox(height: 11),
            _linhaInformacao(
              Icons.event_available_outlined,
              'Próxima manutenção',
              _formatarDataBrasilMaquina(maquina.proximaManutencao),
            ),
            if (maquina.obs.trim().isNotEmpty) ...[
              const SizedBox(height: 11),
              _linhaInformacao(
                Icons.notes_outlined,
                'Observações',
                maquina.obs,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirFormulario(maquina: maquina),
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
                    onPressed: () => _confirmarExclusao(maquina),
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
        Icon(icone, size: 18, color: _corDestaque),
        const SizedBox(width: 9),
        SizedBox(
          width: 132,
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
    bool somenteLeitura = false,
    VoidCallback? aoTocar,
    Widget? sufixo,
    int maxLinhas = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      readOnly: somenteLeitura,
      onTap: aoTocar,
      maxLines: maxLinhas,
      style: TextStyle(color: _corTexto),
      decoration: _decoracao(label, icone).copyWith(suffixIcon: sufixo),
    );
  }
}
