import 'package:flutter/material.dart';
import '../services/admin_service.dart';

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

class _GerenciarUsuariosScreenState
    extends State<GerenciarUsuariosScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _buscaController =
      TextEditingController();

  static const Color verde = Color(0xFF174D2A);
  static const Color bege = Color(0xFFE8DCC6);

  List<Map<String, dynamic>> _usuarios = [];
  bool _carregando = true;
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

  Future<void> _alterarStatus(
    Map<String, dynamic> usuario,
    bool ativo,
  ) async {
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
          backgroundColor: verde,
        ),
      );

      await _carregarUsuarios();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível alterar a conta: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    final usuariosFiltrados = _usuariosFiltrados;

    return Scaffold(
      backgroundColor: bege,
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: const Color(0xFFF7F2E8),
        foregroundColor: verde,
        actions: [
          IconButton(
            onPressed: _carregarUsuarios,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _buscaController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou e-mail',
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
            ),
            Expanded(
              child: _construirConteudo(usuariosFiltrados),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirConteudo(
    List<Map<String, dynamic>> usuarios,
  ) {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: verde),
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
                'Não foi possível carregar os usuários.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: verde,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _erro!,
                textAlign: TextAlign.center,
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

    if (usuarios.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum usuário encontrado.',
          style: TextStyle(
            color: verde,
            fontSize: 16,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarUsuarios,
      color: verde,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          final usuario = usuarios[index];
          final bool ativo = usuario['ativo'] == true;
          final nome = usuario['nome'] ?? 'Nome não informado';
          final email = usuario['email'] ?? 'E-mail não informado';

          return Card(
            color: Colors.white,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: verde.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.person,
                      color: verde,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: verde,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ativo ? 'Conta ativa' : 'Conta inativa',
                          style: TextStyle(
                            color: ativo
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: ativo,
                    activeThumbColor: verde,
                    onChanged: (valor) {
                      _alterarStatus(usuario, valor);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}