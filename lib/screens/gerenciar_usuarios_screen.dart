import 'package:flutter/material.dart';

import '../services/admin_service.dart';
import '../widgets/agroplant_app_bar.dart';

class GerenciarUsuariosScreen extends StatefulWidget {
  const GerenciarUsuariosScreen({super.key});

  @override
  State<GerenciarUsuariosScreen> createState() =>
      _GerenciarUsuariosScreenState();
}

class _GerenciarUsuariosScreenState extends State<GerenciarUsuariosScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _buscaController = TextEditingController();

  static const Color _verdeAgroPlant = Color(0xFF174D2A);
  static const Color _verdeSecundario = Color(0xFF55745D);

  List<Map<String, dynamic>> _usuarios = [];

  bool _carregando = true;
  String? _erro;

  Color _corTextoPrincipal(ThemeData tema) {
    return tema.brightness == Brightness.dark
        ? tema.colorScheme.primary
        : _verdeAgroPlant;
  }

  Color _corTextoSecundario(ThemeData tema) {
    return tema.brightness == Brightness.dark
        ? tema.colorScheme.onSurfaceVariant
        : _verdeSecundario;
  }

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarUsuarios() async {
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

  List<Map<String, dynamic>> get _usuariosFiltrados {
    final busca = _buscaController.text.trim().toLowerCase();

    if (busca.isEmpty) return _usuarios;

    return _usuarios.where((usuario) {
      final nome = (usuario['nome'] ?? '').toString().toLowerCase();

      final email = (usuario['email'] ?? '').toString().toLowerCase();

      return nome.contains(busca) || email.contains(busca);
    }).toList();
  }

  void _mostrarDetalhes(Map<String, dynamic> usuario) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    final ativo = usuario['ativo'] == true;
    final nome = usuario['nome'] ?? 'Nome não informado';
    final email = usuario['email'] ?? 'E-mail não informado';
    final uid = usuario['uid'] ?? '';

    final corStatus = ativo ? Colors.green.shade700 : cores.error;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cores.surface,
          title: Text(
            'Dados do usuário',
            style: TextStyle(
              color: _corTextoPrincipal(tema),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detalhe('Nome', nome.toString(), tema),
                const SizedBox(height: 14),
                _detalhe('E-mail', email.toString(), tema),
                const SizedBox(height: 14),
                _detalhe('UID', uid.toString(), tema),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(
                      ativo ? Icons.check_circle : Icons.block,
                      color: corStatus,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ativo ? 'Conta ativa' : 'Conta inativa',
                      style: TextStyle(
                        color: corStatus,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Fechar', style: TextStyle(color: cores.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _detalhe(String titulo, String valor, ThemeData tema) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: _corTextoSecundario(tema),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(
          valor,
          style: TextStyle(color: _corTextoPrincipal(tema), fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    final corTexto = _corTextoPrincipal(tema);

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      appBar: AgroPlantAppBar(
        backgroundColor: tema.appBarTheme.backgroundColor ?? cores.surface,
        foregroundColor: corTexto,
        centerTitle: true,
        fallbackRoute: '/admin',
        title: Text(
          'Gerenciar usuários',
          style: TextStyle(fontWeight: FontWeight.w600, color: corTexto),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar usuários',
            onPressed: _carregarUsuarios,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(child: _construirConteudo()),
    );
  }

  Widget _construirConteudo() {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    if (_carregando) {
      return Center(child: CircularProgressIndicator(color: cores.primary));
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
                'Não foi possível carregar os usuários.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _corTextoPrincipal(tema),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: TextStyle(color: _corTextoSecundario(tema)),
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

    final usuarios = _usuariosFiltrados;

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
                Icons.people_alt_outlined,
                color: cores.primary,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Usuários cadastrados',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: _corTextoPrincipal(tema),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Consulte os dados e a situação das contas dos usuários cadastrados no AgroPlant.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: _corTextoSecundario(tema),
            ),
          ),
          const SizedBox(height: 26),
          TextField(
            controller: _buscaController,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: _corTextoPrincipal(tema)),
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou e-mail',
              hintStyle: TextStyle(
                color: _corTextoSecundario(tema).withValues(alpha: 0.85),
              ),
              prefixIcon: Icon(Icons.search, color: cores.primary),
              filled: true,
              fillColor: tema.inputDecorationTheme.fillColor ?? cores.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 17),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: cores.secondary, width: 1.5),
              ),
              suffixIcon: _buscaController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _buscaController.clear();
                        setState(() {});
                      },
                      icon: Icon(Icons.close, color: _corTextoSecundario(tema)),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${usuarios.length} usuário(s) encontrado(s)',
            style: TextStyle(
              color: _corTextoSecundario(tema),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          if (usuarios.isEmpty)
            _construirVazio()
          else
            ...usuarios.map(_cartaoUsuario),
        ],
      ),
    );
  }

  Widget _construirVazio() {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    final temBusca = _buscaController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.person_search_outlined, color: cores.primary, size: 48),
          const SizedBox(height: 12),
          Text(
            temBusca
                ? 'Nenhum usuário encontrado.'
                : 'Nenhum usuário cadastrado.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _corTextoPrincipal(tema),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tente alterar sua pesquisa ou atualizar a lista.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _corTextoSecundario(tema), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _cartaoUsuario(Map<String, dynamic> usuario) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    final ativo = usuario['ativo'] == true;
    final nome = usuario['nome'] ?? 'Nome não informado';
    final email = usuario['email'] ?? 'E-mail não informado';

    final corStatus = ativo ? Colors.green.shade700 : cores.error;

    return Card(
      color: tema.cardTheme.color ?? cores.surface,
      elevation: 1,
      shadowColor: tema.cardTheme.shadowColor,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _mostrarDetalhes(usuario),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        color: _corTextoPrincipal(tema),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email.toString(),
                      style: TextStyle(
                        color: _corTextoSecundario(tema),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            ativo ? Icons.check_circle : Icons.cancel,
                            size: 13,
                            color: corStatus,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            ativo ? 'Conta ativa' : 'Conta inativa',
                            style: TextStyle(
                              color: corStatus,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.visibility_outlined, color: cores.primary),
            ],
          ),
        ),
      ),
    );
  }
}
