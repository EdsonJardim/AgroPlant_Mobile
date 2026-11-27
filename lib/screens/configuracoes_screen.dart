import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/notificacao_service.dart';
import '../theme/theme_controller.dart';
import '../widgets/agroplant_app_bar.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  static const Color verde = Color(0xFF174D2A);
  static const Color bege = Color(0xFFE8DCC6);
  static const Color begeClaro = Color(0xFFF7F2E8);
  static const Color textoSecundario = Color(0xFF62594B);

  bool _notificacoesAtivadas = false;
  bool _carregando = true;
  bool _salvando = false;

  final usuario = FirebaseAuth.instance.currentUser;

  bool get _modoEscuro => AppThemeController.instance.isDarkMode;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    if (usuario == null) {
      setState(() {
        _carregando = false;
      });
      return;
    }

    try {
      final documento = await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario!.uid)
          .collection('configuracoes')
          .doc('preferencias')
          .get();

      if (mounted) {
        setState(() {
          _notificacoesAtivadas =
              documento.data()?['notificacoesAtivadas'] == true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível carregar as configurações.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _alterarNotificacoes(bool valor) async {
    if (usuario == null || _salvando) return;

    setState(() {
      _salvando = true;
    });

    try {
      if (valor) {
        final autorizado = await NotificacaoService.instance
            .solicitarPermissaoERegistrar();

        if (!autorizado) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Permissão de notificações não concedida. '
                  'Verifique as permissões do aplicativo.',
                ),
              ),
            );
          }
          return;
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario!.uid)
          .collection('configuracoes')
          .doc('preferencias')
          .set({
            'notificacoesAtivadas': valor,
            'atualizadoEm': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!valor) {
        try {
          await NotificacaoService.instance.desativarRegistro();
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _notificacoesAtivadas = valor;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              valor ? 'Notificações ativadas.' : 'Notificações desativadas.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível atualizar as notificações.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  Future<void> _alterarModoEscuro(bool valor) async {
    await AppThemeController.instance.alterarModoEscuro(valor);

    if (mounted) {
      setState(() {});
    }
  }

  void _abrirRecuperacaoSenha() {
    context.push('/recuperar-senha');
  }

  void _abrirSuporte() {
    context.push('/suporte');
  }

  Widget _cartaoOpcao({
    required IconData icone,
    required String titulo,
    required String descricao,
    required Widget acao,
  }) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final corTexto = escuro ? Colors.white : verde;
    final corSecundaria = escuro ? Colors.white70 : textoSecundario;
    final corIcone = escuro ? const Color(0xFF78A878) : verde;
    final corFundoIcone = escuro ? const Color(0xFF29372D) : begeClaro;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: escuro
            ? []
            : [
                BoxShadow(
                  color: verde.withValues(alpha: 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: corFundoIcone,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icone, color: corIcone, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  descricao,
                  style: TextStyle(
                    color: corSecundaria,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          acao,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final corVerde = escuro ? const Color(0xFF78A878) : verde;
    final corTexto = escuro ? Colors.white70 : textoSecundario;

    return Scaffold(
      backgroundColor: escuro ? const Color(0xFF121A14) : bege,
      appBar: AgroPlantAppBar(
        backgroundColor: escuro ? const Color(0xFF202B23) : Colors.white,
        foregroundColor: escuro ? Colors.white : verde,
        showBackButton: true,
        logoWidth: 150,
        fallbackRoute: '/home',
      ),
      body: SafeArea(
        child: _carregando
            ? Center(child: CircularProgressIndicator(color: corVerde))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 68,
                        width: 68,
                        decoration: BoxDecoration(
                          color: escuro ? const Color(0xFF29372D) : begeClaro,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.settings_rounded,
                          color: corVerde,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'Configurações',
                        style: TextStyle(
                          color: corVerde,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Personalize sua experiência no AgroPlant.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: corTexto,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Preferências',
                      style: TextStyle(
                        color: corVerde,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _cartaoOpcao(
                      icone: Icons.notifications_active_outlined,
                      titulo: 'Notificações',
                      descricao: _notificacoesAtivadas
                          ? 'Notificações ativadas neste dispositivo.'
                          : 'Notificações desativadas.',
                      acao: Switch(
                        value: _notificacoesAtivadas,
                        activeThumbColor: verde,
                        onChanged: _salvando ? null : _alterarNotificacoes,
                      ),
                    ),
                    _cartaoOpcao(
                      icone: Icons.dark_mode_outlined,
                      titulo: 'Modo escuro',
                      descricao: _modoEscuro
                          ? 'Tema escuro ativado.'
                          : 'Tema claro ativado.',
                      acao: Switch(
                        value: _modoEscuro,
                        activeThumbColor: verde,
                        onChanged: _alterarModoEscuro,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Segurança',
                      style: TextStyle(
                        color: corVerde,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _cartaoOpcao(
                      icone: Icons.lock_outline_rounded,
                      titulo: 'Recuperar senha',
                      descricao: 'Solicite um link para redefinir sua senha.',
                      acao: IconButton(
                        onPressed: _abrirRecuperacaoSenha,
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: corVerde,
                          size: 19,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Conta',
                      style: TextStyle(
                        color: corVerde,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _cartaoOpcao(
                      icone: Icons.email_outlined,
                      titulo: 'E-mail cadastrado',
                      descricao: usuario?.email ?? 'E-mail não disponível',
                      acao: Icon(
                        Icons.verified_user_outlined,
                        color: corVerde,
                        size: 23,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aplicativo',
                      style: TextStyle(
                        color: corVerde,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _cartaoOpcao(
                      icone: Icons.eco_outlined,
                      titulo: 'AgroPlant',
                      descricao: 'Tecnologia e organização para o campo.',
                      acao: Icon(
                        Icons.info_outline_rounded,
                        color: corVerde,
                        size: 23,
                      ),
                    ),
                    _cartaoOpcao(
                      icone: Icons.support_agent_rounded,
                      titulo: 'Suporte',
                      descricao: 'Precisa de ajuda? Entre em contato com nossa equipe.',
                      acao: IconButton(
                        onPressed: _abrirSuporte,
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: corVerde,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Cultivando inovação.',
                        style: TextStyle(
                          color: corVerde,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
