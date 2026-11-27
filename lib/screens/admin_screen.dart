import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/agroplant_app_bar.dart';

class AdminScreen extends StatelessWidget {
  final String perfilAdmin;

  const AdminScreen({super.key, required this.perfilAdmin});

  static const Color _verdeAgroPlant = Color(0xFF174D2A);
  static const Color _verdeSecundario = Color(0xFF55745D);

  void _abrirGerenciamento(BuildContext context) {
    context.push('/admin/usuarios');
  }

  void _abrirContasAcessos(BuildContext context) {
    context.push('/admin/acessos');
  }

  void _abrirAdministradores(BuildContext context) {
    context.push('/admin/administradores');
  }

  @override
  Widget build(BuildContext context) {
    final bool superAdmin = perfilAdmin == 'super_admin';
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final bool temaEscuro = tema.brightness == Brightness.dark;

    final corDestaque = cores.primary;
    final corSuperficie = cores.surface;

    final corTexto = temaEscuro ? cores.primary : _verdeAgroPlant;

    final corSecundaria = temaEscuro
        ? cores.onSurface.withValues(alpha: 0.78)
        : _verdeSecundario;

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      appBar: AgroPlantAppBar(
        backgroundColor: tema.appBarTheme.backgroundColor ?? cores.surface,
        foregroundColor: corTexto,
        centerTitle: true,
        fallbackRoute: '/home',
        title: Text(
          'Painel Administrativo',
          style: TextStyle(fontWeight: FontWeight.w600, color: corTexto),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: corSuperficie,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: corDestaque,
                    size: 46,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Administração AgroPlant',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: corTexto,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                superAdmin
                    ? 'Administrador principal'
                    : 'Administrador da equipe',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: corSecundaria),
              ),
              const SizedBox(height: 8),
              Text(
                'Gerencie usuários, contas e acessos da plataforma.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: corSecundaria,
                ),
              ),
              const SizedBox(height: 34),
              Text(
                'Gerenciamento',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: corTexto,
                ),
              ),
              const SizedBox(height: 16),
              _cartao(
                tema: tema,
                icone: Icons.people_outline,
                titulo: 'Gerenciar usuários',
                descricao: 'Consulte os usuários cadastrados, seus dados e situação das contas.',
                onTap: () => _abrirGerenciamento(context),
              ),
              const SizedBox(height: 16),
              _cartao(
                tema: tema,
                icone: Icons.manage_accounts_outlined,
                titulo: 'Contas e acessos',
                descricao: 'Visualize os indicadores e controle contas ativas e inativas.',
                onTap: () => _abrirContasAcessos(context),
              ),
              if (superAdmin) ...[
                const SizedBox(height: 16),
                _cartao(
                  tema: tema,
                  icone: Icons.admin_panel_settings_outlined,
                  titulo: 'Administradores',
                  descricao:
                      'Cadastre e gerencie os administradores da equipe.',
                  onTap: () => _abrirAdministradores(context),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: corSuperficie,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: corDestaque,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seu nível de acesso',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: corTexto,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            superAdmin
                                ? 'Acesso de administrador principal'
                                : 'Acesso de administrador da equipe',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartao({
    required ThemeData tema,
    required IconData icone,
    required String titulo,
    required String descricao,
    required VoidCallback onTap,
  }) {
    final cores = tema.colorScheme;
    final bool temaEscuro = tema.brightness == Brightness.dark;

    final corTexto = temaEscuro ? cores.primary : _verdeAgroPlant;

    final corDescricao = temaEscuro
        ? cores.onSurface.withValues(alpha: 0.78)
        : _verdeSecundario;

    return Card(
      color: tema.cardTheme.color ?? cores.surface,
      elevation: 1,
      shadowColor: tema.cardTheme.shadowColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: cores.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icone, color: cores.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: corTexto,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      descricao,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: corDescricao,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: cores.primary, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
