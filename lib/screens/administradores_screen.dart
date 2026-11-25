import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdministradoresScreen extends StatefulWidget {
  const AdministradoresScreen({super.key});

  @override
  State<AdministradoresScreen> createState() =>
      _AdministradoresScreenState();
}

class _AdministradoresScreenState
    extends State<AdministradoresScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _buscaController =
      TextEditingController();

  static const Color verde = Color(0xFF174D2A);
  static const Color bege = Color(0xFFE8DCC6);

  // UID do administrador principal.
  static const String _uidPrincipal =
      'caaZpZoJqZfTwYcsJ1k9AGpxRi53';

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

  Future<void> _carregarDados() async {
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

  List<Map<String, dynamic>> get _usuariosFiltrados {
    final busca =
        _buscaController.text.trim().toLowerCase();

    if (busca.isEmpty) return _usuariosDisponiveis;

    return _usuariosDisponiveis.where((usuario) {
      final nome = usuario['nome'].toString().toLowerCase();
      final email =
          usuario['email'].toString().toLowerCase();

      return nome.contains(busca) ||
          email.contains(busca);
    }).toList();
  }

  Future<void> _promoverUsuario(
    Map<String, dynamic> usuario,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promover administrador'),
        content: Text(
          'Deseja promover ${usuario['nome']} a administrador da equipe?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _processando = true);

    try {
      await _adminService.cadastrarAdministrador(
        uid: usuario['uid'],
        nome: usuario['nome'],
        email: usuario['email'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Administrador cadastrado com sucesso!',
          ),
          backgroundColor: verde,
        ),
      );

      _buscaController.clear();
      await _carregarDados();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao cadastrar administrador: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
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
    setState(() => _processando = true);

    try {
      await _adminService.alterarStatusAdministrador(
        uid: administrador['uid'],
        ativo: ativo,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ativo
                ? 'Administrador ativado!'
                : 'Administrador desativado!',
          ),
          backgroundColor: verde,
        ),
      );

      await _carregarDados();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao alterar administrador: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  Future<void> _removerAdministrador(
    Map<String, dynamic> administrador,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover administrador'),
        content: Text(
          'Deseja remover ${administrador['nome']} da equipe administrativa? '
          'A conta de usuário continuará existindo.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _processando = true);

    try {
      await _adminService.removerAdministrador(
        administrador['uid'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Administrador removido com sucesso!',
          ),
          backgroundColor: verde,
        ),
      );

      await _carregarDados();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao remover administrador: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bege,
      appBar: AppBar(
        title: const Text('Administradores'),
        backgroundColor: const Color(0xFFF7F2E8),
        foregroundColor: verde,
        actions: [
          IconButton(
            onPressed: _carregarDados,
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
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(
          color: verde,
        ),
      );
    }

    if (_erro != null) {
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
              const Text(
                'Não foi possível carregar os administradores.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _erro!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarDados,
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
          onRefresh: _carregarDados,
          color: verde,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Equipe administrativa',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: verde,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Consulte e controle os administradores da equipe.',
                style: TextStyle(
                  color: Color(0xFF62594B),
                ),
              ),
              const SizedBox(height: 18),

              ..._administradores.map(
                _cartaoAdministrador,
              ),

              const SizedBox(height: 28),

              const Text(
                'Adicionar administrador',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: verde,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecione um usuário cadastrado para promover a administrador da equipe.',
                style: TextStyle(
                  color: Color(0xFF62594B),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _buscaController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText:
                      'Buscar usuário por nome ou e-mail',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: verde,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _buscaController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ..._usuariosFiltrados.map(_cartaoUsuario),

              if (_usuariosFiltrados.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Nenhum usuário disponível para promover.',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),

        if (_processando)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  color: verde,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Cartão dos administradores.
  // O administrador principal não pode ser removido
  // ou desativado pela interface.
  Widget _cartaoAdministrador(
    Map<String, dynamic> administrador,
  ) {
    final ativo = administrador['ativo'] == true;

    final principal =
        administrador['uid'] == _uidPrincipal;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      const Color(0xFFE8DCC6),
                  child: Icon(
                    principal
                        ? Icons.verified_user
                        : Icons.admin_panel_settings,
                    color: verde,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        administrador['nome'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: verde,
                        ),
                      ),
                      Text(
                        administrador['email'],
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        principal
                            ? 'Administrador principal'
                            : ativo
                                ? 'Administrador ativo'
                                : 'Administrador inativo',
                        style: TextStyle(
                          color: principal
                              ? verde
                              : ativo
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                if (principal)
                  const Icon(
                    Icons.lock,
                    color: verde,
                    size: 24,
                  )
                else
                  Switch(
                    value: ativo,
                    activeThumbColor: verde,
                    onChanged: _processando
                        ? null
                        : (valor) => _alterarStatus(
                              administrador,
                              valor,
                            ),
                  ),
              ],
            ),

            if (!principal)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _processando
                      ? null
                      : () => _removerAdministrador(
                            administrador,
                          ),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Remover administrador',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Cartão dos usuários que podem ser promovidos.
  Widget _cartaoUsuario(
    Map<String, dynamic> usuario,
  ) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8DCC6),
          child: Icon(
            Icons.person_add_alt_1,
            color: verde,
          ),
        ),
        title: Text(
          usuario['nome'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: verde,
          ),
        ),
        subtitle: Text(usuario['email']),
        trailing: IconButton(
          tooltip: 'Promover a administrador',
          onPressed: _processando
              ? null
              : () => _promoverUsuario(usuario),
          icon: const Icon(
            Icons.add_circle_outline,
            color: verde,
          ),
        ),
      ),
    );
  }
}