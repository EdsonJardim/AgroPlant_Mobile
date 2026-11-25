import 'package:flutter/material.dart';

import '../services/admin_service.dart';
import '../widgets/agroplant_app_bar.dart';

class GerenciarUsuariosScreen extends StatefulWidget {
  final String titulo;

  const GerenciarUsuariosScreen({
    super.key,
    this.titulo = 'Gerenciar usuários',
  });

  @override
  State<GerenciarUsuariosScreen> createState() =>
      _GerenciarUsuariosScreenState();
}

class _GerenciarUsuariosScreenState extends State<GerenciarUsuariosScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _buscaController = TextEditingController();

  List<Map<String, dynamic>> _usuarios = [];

  bool _carregando = true;
  bool _processando = false;
  String? _erro;

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

  int get _totalAtivos =>
      _usuarios.where((usuario) => usuario['ativo'] == true).length;

  int get _totalInativos =>
      _usuarios.where((usuario) => usuario['ativo'] != true).length;

  Future<void> _carregarUsuarios({bool mostrarCarregamento = true}) async {
    if (mounted && mostrarCarregamento) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }

    try {
      final usuarios = await _adminService.listarUsuarios();

      if (!mounted) return;

      setState(() {
        _usuarios = usuarios;
        _carregando = false;
        _erro = null;
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
    if (_processando) return;

    setState(() => _processando = true);

    try {
      await _adminService.alterarStatusUsuario(
        uid: usuario['uid'],
        ativo: ativo,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ativo
                ? 'Conta ativada com sucesso!'
                : 'Conta desativada com sucesso!',
          ),
        ),
      );

      await _carregarUsuarios(mostrarCarregamento: false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível alterar a conta: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
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

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final usuariosFiltrados = _usuariosFiltrados;

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      appBar: AgroPlantAppBar(
        backgroundColor:
            tema.appBarTheme.backgroundColor ?? cores.surface,
        foregroundColor:
            tema.appBarTheme.foregroundColor ?? cores.onSurface,
        centerTitle: true,
        title: Text(
          widget.titulo,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: tema.appBarTheme.foregroundColor ?? cores.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _construirConteudo(usuariosFiltrados),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirConteudo(List<Map<String, dynamic>> usuarios) {
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
              Icon(
                Icons.error_outline,
                color: cores.error,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Não foi possível carregar os usuários.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cores.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: TextStyle(color: cores.onSurface),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _carregarUsuarios(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
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
                'Gerenciar usuários',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: cores.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Consulte os usuários cadastrados e controle a situação de suas contas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: cores.onSurface.withValues(alpha: 0.7),
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
                'Usuários cadastrados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cores.onSurface,
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _buscaController,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: cores.onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou e-mail',
                  prefixIcon: Icon(
                    Icons.search,
                    color: cores.primary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 17),
                  suffixIcon: _buscaController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _buscaController.clear();
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.close,
                            color: cores.onSurface.withValues(alpha: 0.7),
                          ),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 18),

              if (usuarios.isEmpty)
                _construirVazio()
              else
                ...usuarios.map(_cartaoUsuario),
            ],
          ),
        ),

        if (_processando)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.12),
              child: Center(
                child: CircularProgressIndicator(
                  color: cores.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _cartaoResumo({
    required String titulo,
    required int quantidade,
    required IconData icone,
    required Color cor,
  }) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cores.surface,
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
                    color: cores.onSurface.withValues(alpha: 0.7),
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

  Widget _construirVazio() {
    final cores = Theme.of(context).colorScheme;
    final temBusca = _buscaController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_search_outlined,
            color: cores.primary,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            temBusca
                ? 'Nenhum usuário encontrado.'
                : 'Nenhum usuário cadastrado.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cores.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tente atualizar a lista ou alterar sua pesquisa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cores.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoUsuario(Map<String, dynamic> usuario) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    final bool ativo = usuario['ativo'] == true;
    final nome = usuario['nome'] ?? 'Nome não informado';
    final email = usuario['email'] ?? 'E-mail não informado';

    final corStatus = ativo ? Colors.green.shade700 : cores.error;

    return Card(
      color: tema.cardTheme.color ?? cores.surface,
      elevation: 1,
      shadowColor: tema.cardTheme.shadowColor,
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
                    nome,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: cores.onSurface,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    email,
                    style: TextStyle(
                      color: cores.onSurface.withValues(alpha: 0.7),
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

            const SizedBox(width: 6),

            Switch(
              value: ativo,
              onChanged: _processando
                  ? null
                  : (valor) => _alterarStatus(usuario, valor),
            ),
          ],
        ),
      ),
    );
  }
}