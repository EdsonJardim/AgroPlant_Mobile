import 'package:flutter/material.dart';

import '../services/admin_service.dart';
import '../widgets/agroplant_app_bar.dart';

class AdministradoresScreen extends StatefulWidget {
  const AdministradoresScreen({super.key});

  @override
  State<AdministradoresScreen> createState() => _AdministradoresScreenState();
}

class _AdministradoresScreenState extends State<AdministradoresScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _buscaController = TextEditingController();

  static const String _uidPrincipal = 'caaZpZoJqZfTwYcsJ1k9AGpxRi53';

  List<Map<String, dynamic>> _administradores = [];
  List<Map<String, dynamic>> _usuariosDisponiveis = [];

  bool _carregando = true;
  bool _processando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  int get _totalAtivos => _administradores.where((admin) {
    return admin['ativo'] == true;
  }).length;

  int get _totalInativos => _administradores.where((admin) {
    return admin['ativo'] != true;
  }).length;

  List<Map<String, dynamic>> get _usuariosFiltrados {
    final busca = _buscaController.text.trim().toLowerCase();

    if (busca.isEmpty) return _usuariosDisponiveis;

    return _usuariosDisponiveis.where((usuario) {
      final nome = (usuario['nome'] ?? '').toString().toLowerCase();
      final email = (usuario['email'] ?? '').toString().toLowerCase();

      return nome.contains(busca) || email.contains(busca);
    }).toList();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final resultados = await Future.wait([
        _adminService.listarAdministradores(),
        _adminService.listarUsuariosDisponiveisParaAdmin(),
      ]);

      if (!mounted) return;

      setState(() {
        _administradores = resultados[0];
        _usuariosDisponiveis = resultados[1];
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

  void _mostrarMensagem(String mensagem, {bool erro = false}) {
    final cores = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? cores.error : cores.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _promoverUsuario(Map<String, dynamic> usuario) async {
    if (_processando) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        final cores = Theme.of(context).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Promover administrador',
            style: TextStyle(
              color: cores.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deseja promover ${usuario['nome']} a administrador da equipe?',
            style: TextStyle(color: cores.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: cores.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() => _processando = true);

    try {
      await _adminService.cadastrarAdministrador(
        uid: usuario['uid'],
        nome: usuario['nome'],
        email: usuario['email'],
      );

      if (!mounted) return;

      _mostrarMensagem('Administrador cadastrado com sucesso!');

      _buscaController.clear();
      await _carregarDados();
    } catch (e) {
      if (!mounted) return;

      _mostrarMensagem('Erro ao cadastrar administrador: $e', erro: true);
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  Future<void> _alterarStatus(
    Map<String, dynamic> administrador,
    bool ativo,
  ) async {
    if (_processando) return;

    if (administrador['uid'] == _uidPrincipal) {
      _mostrarMensagem(
        'O administrador principal não pode ser alterado.',
        erro: true,
      );
      return;
    }

    setState(() => _processando = true);

    try {
      await _adminService.alterarStatusAdministrador(
        uid: administrador['uid'],
        ativo: ativo,
      );

      if (!mounted) return;

      _mostrarMensagem(
        ativo ? 'Administrador ativado!' : 'Administrador desativado!',
      );

      await _carregarDados();
    } catch (e) {
      if (!mounted) return;

      _mostrarMensagem('Erro ao alterar administrador: $e', erro: true);
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  Future<void> _removerAdministrador(
    Map<String, dynamic> administrador,
  ) async {
    if (_processando) return;

    if (administrador['uid'] == _uidPrincipal) {
      _mostrarMensagem(
        'O administrador principal não pode ser removido.',
        erro: true,
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        final cores = Theme.of(context).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Remover administrador',
            style: TextStyle(
              color: cores.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deseja remover ${administrador['nome']} da equipe administrativa? '
            'A conta de usuário continuará existindo.',
            style: TextStyle(color: cores.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: cores.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cores.error,
                foregroundColor: cores.onError,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() => _processando = true);

    try {
      await _adminService.removerAdministrador(administrador['uid']);

      if (!mounted) return;

      _mostrarMensagem('Administrador removido com sucesso!');

      await _carregarDados();
    } catch (e) {
      if (!mounted) return;

      _mostrarMensagem('Erro ao remover administrador: $e', erro: true);
    } finally {
      if (mounted) {
        setState(() => _processando = false);
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
        foregroundColor:
            tema.appBarTheme.foregroundColor ?? cores.onSurface,
        centerTitle: true,
        title: Text(
          'Administradores',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: tema.appBarTheme.foregroundColor ?? cores.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _carregando || _processando ? null : _carregarDados,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar lista',
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
      return Center(
        child: CircularProgressIndicator(color: cores.primary),
      );
    }

    if (_erro != null) {
      return _construirErro();
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _carregarDados,
          color: cores.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
            children: [
              Center(
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: cores.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: cores.primary,
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Equipe administrativa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: cores.primary,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Cadastre e gerencie os administradores responsáveis pelo AgroPlant.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: cores.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: _cartaoResumo(
                      titulo: 'Administradores',
                      quantidade: _administradores.length,
                      icone: Icons.people_outline,
                      cor: cores.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _cartaoResumo(
                      titulo: 'Ativos',
                      quantidade: _totalAtivos,
                      icone: Icons.check_circle_outline,
                      cor: Colors.green.shade700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _cartaoResumo(
                titulo: 'Administradores inativos',
                quantidade: _totalInativos,
                icone: Icons.block_outlined,
                cor: cores.error,
              ),

              const SizedBox(height: 30),

              Text(
                'Administradores cadastrados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cores.primary,
                ),
              ),

              const SizedBox(height: 14),

              if (_administradores.isEmpty)
                _mensagemVazia(
                  'Nenhum administrador cadastrado.',
                  Icons.admin_panel_settings_outlined,
                )
              else
                ..._administradores.map(_cartaoAdministrador),

              const SizedBox(height: 28),

              Text(
                'Adicionar administrador',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cores.primary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Pesquise um usuário cadastrado para promovê-lo a administrador da equipe.',
                style: TextStyle(
                  color: cores.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _buscaController,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: cores.onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar usuário por nome ou e-mail',
                  hintStyle: TextStyle(
                    color: cores.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(Icons.search, color: cores.primary),
                  filled: true,
                  fillColor: tema.inputDecorationTheme.fillColor ??
                      cores.surface,
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
                    borderSide: BorderSide(
                      color: cores.secondary,
                      width: 1.5,
                    ),
                  ),
                  suffixIcon: _buscaController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _buscaController.clear();
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.close,
                            color: cores.onSurfaceVariant,
                          ),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              if (_usuariosFiltrados.isEmpty)
                _mensagemVazia(
                  _usuariosDisponiveis.isEmpty
                      ? 'Não existem usuários disponíveis para promover.'
                      : 'Nenhum usuário encontrado para essa pesquisa.',
                  Icons.person_search_outlined,
                )
              else
                ..._usuariosFiltrados.map(_cartaoUsuario),
            ],
          ),
        ),

        if (_processando)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.12),
              child: Center(
                child: CircularProgressIndicator(color: cores.primary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _construirErro() {
    final cores = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: cores.error, size: 48),
            const SizedBox(height: 14),
            Text(
              'Não foi possível carregar os administradores.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cores.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _erro!,
              textAlign: TextAlign.center,
              style: TextStyle(color: cores.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _carregarDados,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoResumo({
    required String titulo,
    required int quantidade,
    required IconData icone,
    required Color cor,
  }) {
    final cores = Theme.of(context).colorScheme;

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
                    color: cores.onSurfaceVariant,
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

  Widget _mensagemVazia(String mensagem, IconData icone) {
    final cores = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icone, color: cores.secondary, size: 44),
          const SizedBox(height: 12),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cores.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoAdministrador(Map<String, dynamic> administrador) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    final ativo = administrador['ativo'] == true;
    final principal = administrador['uid'] == _uidPrincipal;

    final corStatus = principal
        ? cores.primary
        : ativo
            ? Colors.green.shade700
            : cores.error;

    return Card(
      color: tema.cardTheme.color ?? cores.surface,
      elevation: 1,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: cores.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    principal
                        ? Icons.verified_user_outlined
                        : Icons.admin_panel_settings_outlined,
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
                        administrador['nome'] ?? 'Nome não informado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: cores.onSurface,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        administrador['email'] ?? 'E-mail não informado',
                        style: TextStyle(
                          color: cores.onSurfaceVariant,
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
                          principal
                              ? 'Administrador principal'
                              : ativo
                                  ? 'Administrador ativo'
                                  : 'Administrador inativo',
                          style: TextStyle(
                            color: corStatus,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (principal)
                  Icon(
                    Icons.lock_outline,
                    color: cores.primary,
                    size: 23,
                  )
                else
                  Switch(
                    value: ativo,
                    onChanged: _processando
                        ? null
                        : (valor) => _alterarStatus(administrador, valor),
                  ),
              ],
            ),

            if (!principal) ...[
              Divider(
                height: 24,
                color: cores.outlineVariant,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _processando
                      ? null
                      : () => _removerAdministrador(administrador),
                  icon: Icon(
                    Icons.delete_outline,
                    color: cores.error,
                    size: 20,
                  ),
                  label: Text(
                    'Remover administrador',
                    style: TextStyle(
                      color: cores.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cartaoUsuario(Map<String, dynamic> usuario) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Card(
      color: tema.cardTheme.color ?? cores.surface,
      elevation: 1,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cores.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.person_add_alt_1,
            color: cores.primary,
            size: 25,
          ),
        ),
        title: Text(
          usuario['nome'] ?? 'Nome não informado',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: cores.onSurface,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          usuario['email'] ?? 'E-mail não informado',
          style: TextStyle(
            color: cores.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          tooltip: 'Promover a administrador',
          onPressed: _processando
              ? null
              : () => _promoverUsuario(usuario),
          icon: Icon(
            Icons.add_circle_outline,
            color: cores.primary,
            size: 28,
          ),
        ),
      ),
    );
  }
}