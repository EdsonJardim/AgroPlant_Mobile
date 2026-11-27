
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/planilhas_screen.dart';
import '../screens/minha_propriedade_screen.dart';
import '../screens/configuracoes_screen.dart';
import '../screens/sobre_screen.dart';
import '../screens/recuperar_senha_screen.dart';
import '../screens/suporte_screen.dart';

import '../screens/admin_screen.dart';
import '../screens/gerenciar_usuarios_screen.dart';
import '../screens/contas_acessos_screen.dart';
import '../screens/administradores_screen.dart';

import '../screens/estoque_screen.dart';
import '../screens/gestao_screen.dart';
import '../screens/maquinas_screen.dart';
import '../screens/safra_screen.dart';
import '../screens/estatisticas_geral_screen.dart';

import '../services/admin_service.dart';
import '../services/propriedade_service.dart';
import '../models/propriedade.dart';

class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier() {
    _subscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      _inicializado = true;
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  bool _inicializado = false;

  bool get inicializado => _inicializado;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final AuthStateNotifier _authNotifier = AuthStateNotifier();

final AdminService _adminService = AdminService();

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: _authNotifier,

  redirect: (context, state) async {
    if (!_authNotifier.inicializado) {
      return null;
    }

    final usuario = FirebaseAuth.instance.currentUser;
    final estaLogado = usuario != null;

    final caminho = state.uri.path;

    debugPrint('========== DEBUG NAVEGAÇÃO ==========');
    debugPrint('Rota solicitada: $caminho');
    debugPrint('Usuário autenticado: ${usuario?.uid}');
    debugPrint(
      'Autenticação inicializada: ${_authNotifier.inicializado}',
    );
    debugPrint('======================================');

    final rotaPublica =
        caminho == '/login' || caminho == '/recuperar-senha';

    if (!estaLogado) {
      if (rotaPublica) {
        return null;
      }

      return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
    }

    if (caminho == '/login') {
      final destino = state.uri.queryParameters['from'];

      if (destino != null &&
          destino.startsWith('/') &&
          !destino.startsWith('//') &&
          destino != '/login') {
        return destino;
      }

      return '/home';
    }

    if (caminho.startsWith('/admin')) {
      try {
        final perfil = await _adminService.consultarPerfilAdmin();

        if (perfil == null || perfil['ativo'] != true) {
          return '/home';
        }

        if (caminho == '/admin/administradores' &&
            perfil['role'] != 'super_admin') {
          return '/admin';
        }
      } catch (_) {
        return '/home';
      }
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/recuperar-senha',
      builder: (context, state) => const RecuperarSenhaScreen(),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/perfil',
      builder: (context, state) => const PerfilScreen(),
    ),

    GoRoute(
      path: '/planilhas',
      builder: (context, state) => const PlanilhasScreen(),
    ),

    GoRoute(
      path: '/propriedade',
      builder: (context, state) => const MinhaPropriedadeScreen(),
    ),

    GoRoute(
      path: '/propriedade/nova',
      builder: (context, state) => const PropriedadeFormularioScreen(),
    ),

    GoRoute(
      path: '/propriedade/editar/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;

        return FutureBuilder<PropriedadeModel?>(
          future: PropriedadeService().buscarPropriedadePorId(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Erro ao carregar propriedade: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            final propriedade = snapshot.data;

            if (propriedade == null) {
              return const Scaffold(
                body: Center(
                  child: Text('Propriedade não encontrada.'),
                ),
              );
            }

            return PropriedadeFormularioScreen(
              propriedade: propriedade,
            );
          },
        );
      },
    ),

    GoRoute(
      path: '/configuracoes',
      builder: (context, state) => const ConfiguracoesScreen(),
    ),

    GoRoute(
      path: '/sobre',
      builder: (context, state) => const SobreScreen(),
    ),

    GoRoute(
      path: '/suporte',
      builder: (context, state) => const SuporteScreen(),
    ),

    GoRoute(
      path: '/admin',
      builder: (context, state) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: _adminService.consultarPerfilAdmin(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final perfil = snapshot.data;

            if (perfil == null || perfil['ativo'] != true) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Acesso administrativo não autorizado.',
                  ),
                ),
              );
            }

            return AdminScreen(
              perfilAdmin: perfil['role']?.toString() ?? '',
            );
          },
        );
      },
    ),

    GoRoute(
      path: '/admin/usuarios',
      builder: (context, state) => const GerenciarUsuariosScreen(),
    ),

    GoRoute(
      path: '/admin/acessos',
      builder: (context, state) => const ContasAcessosScreen(),
    ),

    GoRoute(
      path: '/admin/administradores',
      builder: (context, state) => const AdministradoresScreen(),
    ),

    GoRoute(
      path: '/planilhas/estoque',
      builder: (context, state) => const EstoqueScreen(),
    ),

    GoRoute(
      path: '/planilhas/gestao',
      builder: (context, state) => const GestaoScreen(),
    ),

    GoRoute(
      path: '/planilhas/maquinas',
      builder: (context, state) => const MaquinasScreen(),
    ),

    GoRoute(
      path: '/planilhas/safra',
      builder: (context, state) => const SafraScreen(),
    ),

    GoRoute(
      path: '/planilhas/estatisticas',
      builder: (context, state) => const EstatisticasGeralScreen(),
    ),
  ],

  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
      ),
      body: Center(
        child: Text(
          'Não foi possível encontrar esta página.\n${state.uri}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  },
);
