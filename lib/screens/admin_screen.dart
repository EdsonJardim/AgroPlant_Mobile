import 'package:flutter/material.dart';
import 'gerenciar_usuarios_screen.dart';
import 'administradores_screen.dart';

class AdminScreen extends StatelessWidget {
  final String perfilAdmin;

  const AdminScreen({
    super.key,
    required this.perfilAdmin,
  });

  static const Color verde = Color(0xFF174D2A);

  void _abrirGerenciamento(
    BuildContext context,
    String titulo,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GerenciarUsuariosScreen(
          titulo: titulo,
        ),
      ),
    );
  }

  void _abrirAdministradores(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdministradoresScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool superAdmin = perfilAdmin == 'super_admin';

    return Scaffold(
      backgroundColor: const Color(0xFFE8DCC6),
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        backgroundColor: const Color(0xFFF7F2E8),
        foregroundColor: verde,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Administração AgroPlant',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: verde,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                superAdmin
                    ? 'Administrador principal'
                    : 'Administrador da equipe',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF62594B),
                ),
              ),
              const SizedBox(height: 28),
              _cartao(
                icone: Icons.people_outline,
                titulo: 'Gerenciar usuários',
                descricao: 'Consultar os usuários cadastrados no AgroPlant.',
                onTap: () => _abrirGerenciamento(
                  context,
                  'Gerenciar usuários',
                ),
              ),
              const SizedBox(height: 16),
              _cartao(
                icone: Icons.person_off_outlined,
                titulo: 'Contas e acessos',
                descricao: 'Consultar a situação das contas dos usuários.',
                onTap: () => _abrirGerenciamento(
                  context,
                  'Contas e acessos',
                ),
              ),
              if (superAdmin) ...[
                const SizedBox(height: 16),
                _cartao(
                  icone: Icons.admin_panel_settings_outlined,
                  titulo: 'Administradores',
                  descricao: 'Cadastrar e gerenciar administradores da equipe.',
                  onTap: () => _abrirAdministradores(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartao({
    required IconData icone,
    required String titulo,
    required String descricao,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: Icon(icone, color: verde, size: 32),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: verde,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(descricao),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 17),
        onTap: onTap,
      ),
    );
  }
}