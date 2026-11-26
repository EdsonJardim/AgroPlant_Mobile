import 'package:flutter/material.dart';

import '../services/admin_service.dart';
import '../widgets/agroplant_app_bar.dart';

class ContasAcessosScreen extends StatefulWidget {
  const ContasAcessosScreen({super.key});

  @override
  State<ContasAcessosScreen> createState() =>
      _ContasAcessosScreenState();
}

class _ContasAcessosScreenState extends State<ContasAcessosScreen> {
  final AdminService _adminService = AdminService();

  static const Color _verde = Color(0xFF174D2A);
  static const Color _verdeSecundario = Color(0xFF55745D);

  List<Map<String, dynamic>> _usuarios = [];

  bool _carregando = true;
  String? _erro;
  String _filtro = 'Todas';
  String? _uidProcessando;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Color _corTexto(ThemeData tema) {
    return tema.brightness == Brightness.dark
        ? tema.colorScheme.primary
        : _verde;
  }

  Color _corSecundaria(ThemeData tema) {
    return tema.brightness == Brightness.dark
        ? tema.colorScheme.onSurfaceVariant
        : _verdeSecundario;
  }

  int get _totalAtivos =>
      _usuarios.where((u) => u['ativo'] == true).length;

  int get _totalInativos =>
      _usuarios.where((u) => u['ativo'] != true).length;

  List<Map<String, dynamic>> get _usuariosFiltrados {
    if (_filtro == 'Ativas') {
      return _usuarios.where((u) => u['ativo'] == true).toList();
    }

    if (_filtro == 'Inativas') {
      return _usuarios.where((u) => u['ativo'] != true).toList();
    }

    return _usuarios;
  }

  Future<void> _carregarUsuarios() async {
    if (!mounted) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final usuarios = await _adminService.listarUsuarios();

      if (!mounted) return;

      setState(() {
        _usuarios = usuarios;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  Future<void> _alterarStatus(
    Map<String, dynamic> usuario,
    bool ativo,
  ) async {
    final uid = usuario['uid']?.toString();

    if (uid == null || uid.isEmpty || _uidProcessando != null) {
      return;
    }

    setState(() => _uidProcessando = uid);

    try {
      await _adminService.alterarStatusUsuario(
        uid: uid,
        ativo: ativo,
      );

      if (!mounted) return;

      setState(() {
        final indice = _usuarios.indexWhere(
          (u) => u['uid'] == uid,
        );

        if (indice != -1) {
          _usuarios[indice] = {
            ..._usuarios[indice],
            'ativo': ativo,
          };
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ativo
                ? 'Conta ativada com sucesso!'
                : 'Conta desativada com sucesso!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível alterar a conta: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _uidProcessando = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      appBar: AgroPlantAppBar(
        backgroundColor:
            tema.appBarTheme.backgroundColor ?? cores.surface,
        foregroundColor: _corTexto(tema),
        centerTitle: true,
        title: Text(
          'Contas e acessos',
          style: TextStyle(
            color: _corTexto(tema),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar contas',
            onPressed: _carregarUsuarios,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _construirConteudo(),
      ),
    );
  }

  Widget _construirConteudo() {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    if (_carregando) {
      return Center(
        child: CircularProgressIndicator(color: cores.primary),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: cores.error, size: 48),
              const SizedBox(height: 12),
              Text(
                'Não foi possível carregar as contas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _corTexto(tema),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: TextStyle(color: _corSecundaria(tema)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarUsuarios,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarUsuarios,
      color: cores.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
        children: [
          Center(
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: cores.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.manage_accounts_outlined,
                color: cores.primary,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Controle de contas e acessos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _corTexto(tema),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Acompanhe a situação das contas e gerencie sua disponibilidade.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: _corSecundaria(tema),
            ),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: _cartaoResumo(
                  titulo: 'Total de usuários',
                  quantidade: _usuarios.length,
                  icone: Icons.people_outline,
                  cor: cores.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _cartaoResumo(
                  titulo: 'Contas ativas',
                  quantidade: _totalAtivos,
                  icone: Icons.check_circle_outline,
                  cor: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _cartaoResumo(
            titulo: 'Contas inativas',
            quantidade: _totalInativos,
            icone: Icons.block_outlined,
            cor: cores.error,
          ),
          const SizedBox(height: 28),
          Text(
            'Filtrar contas',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: _corTexto(tema),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _filtroChip('Todas'),
              _filtroChip('Ativas'),
              _filtroChip('Inativas'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Usuários cadastrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _corTexto(tema),
            ),
          ),
          const SizedBox(height: 14),
          if (_usuariosFiltrados.isEmpty)
            _construirVazio()
          else
            ..._usuariosFiltrados.map(_cartaoUsuario),
        ],
      ),
    );
  }

  Widget _cartaoResumo({
    required String titulo,
    required int quantidade,
    required IconData icone,
    required Color cor,
  }) {
    final tema = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tema.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icone, color: cor, size: 27),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$quantidade',
                  style: TextStyle(
                    color: cor,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  titulo,
                  style: TextStyle(
                    color: _corSecundaria(tema),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtroChip(String texto) {
    final tema = Theme.of(context);
    final selecionado = _filtro == texto;

    return ChoiceChip(
      label: Text(texto),
      selected: selecionado,
      onSelected: (valor) {
        if (valor) {
          setState(() => _filtro = texto);
        }
      },
      selectedColor: tema.colorScheme.primary.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: selecionado
            ? _corTexto(tema)
            : _corSecundaria(tema),
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selecionado
            ? tema.colorScheme.primary
            : tema.colorScheme.outlineVariant,
      ),
    );
  }

  Widget _construirVazio() {
    final tema = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: tema.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.manage_search_outlined,
            color: tema.colorScheme.primary,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma conta encontrada.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _corTexto(tema),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoUsuario(Map<String, dynamic> usuario) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    final ativo = usuario['ativo'] == true;
    final uid = usuario['uid']?.toString() ?? '';
    final nome = usuario['nome'] ?? 'Nome não informado';
    final email = usuario['email'] ?? 'E-mail não informado';

    final corStatus =
        ativo ? Colors.green.shade700 : cores.error;

    final processando = _uidProcessando == uid;

    return Card(
      color: tema.cardTheme.color ?? cores.surface,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: cores.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                Icons.person_outline,
                color: cores.primary,
                size: 29,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _corTexto(tema),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email.toString(),
                    style: TextStyle(
                      color: _corSecundaria(tema),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: corStatus.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ativo ? 'Conta ativa' : 'Conta inativa',
                      style: TextStyle(
                        color: corStatus,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (processando)
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cores.primary,
                ),
              )
            else
              Switch(
                value: ativo,
                activeTrackColor: cores.primary.withValues(alpha: 0.55),
                onChanged: _uidProcessando != null
                    ? null
                    : (valor) => _alterarStatus(usuario, valor),
              ),
          ],
        ),
      ),
    );
  }
}