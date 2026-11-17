import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'recuperar_senha_screen.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _authService = AuthService();

  bool _carregando = false;
  bool _mostrarSenha = false;
  bool _mostrarConfirmarSenha = false;
  bool _modoCadastro = false;

  static const Color verde = Color(0xFF174D2A);
  static const Color verdeClaro = Color(0xFF78A878);
  static const Color bege = Color(0xFFE8DCC6);
  static const Color begeClaro = Color(0xFFF7F2E8);
  static const Color fundoEscuro = Color(0xFF121A14);
  static const Color superficieEscura = Color(0xFF202B23);
  static const Color campoEscuro = Color(0xFF29372D);

  bool get _escuro => Theme.of(context).brightness == Brightness.dark;

  Color get _corTexto => _escuro ? Colors.white : verde;
  Color get _corSecundaria =>
      _escuro ? Colors.white70 : const Color(0xFF62594B);
  Color get _corFundo => _escuro ? fundoEscuro : bege;
  Color get _corCartao => _escuro ? superficieEscura : Colors.white;
  Color get _corCampo => _escuro ? campoEscuro : begeClaro;
  Color get _corDestaque => _escuro ? verdeClaro : verde;
  Color get _corBorda => _escuro ? verdeClaro : bege;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _alternarModo() {
    if (_carregando) return;

    setState(() {
      _modoCadastro = !_modoCadastro;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
    });

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (erro) {
      _mostrarErro(_mensagemErroLogin(erro));
    } catch (erro) {
      debugPrint('Erro no login: $erro');
      _mostrarErro('Ocorreu um erro ao realizar o login.');
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _recuperarSenha() async {
    if (_carregando) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecuperarSenhaScreen(),
      ),
    );
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_senhaController.text != _confirmarSenhaController.text) {
      _mostrarErro('As senhas não coincidem.');
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      await _authService.cadastrar(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (erro) {
      _mostrarErro(_mensagemErroCadastro(erro));
    } catch (erro) {
      debugPrint('Erro no cadastro: $erro');
      _mostrarErro('Ocorreu um erro ao criar a conta.');
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _google() async {
    setState(() {
      _carregando = true;
    });

    try {
      final usuario = await _authService.loginComGoogle();

      if (usuario == null) return;

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (erro) {
      _mostrarErro(_mensagemErroGoogle(erro));
    } catch (erro) {
      debugPrint('Erro no Google: $erro');

      if (mounted) {
        _mostrarErro('Não foi possível continuar com o Google.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  String _mensagemErroLogin(FirebaseAuthException erro) {
    switch (erro.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'E-mail ou senha incorretos.';
      case 'invalid-email':
        return 'Digite um e-mail válido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'method-disabled':
        return 'O acesso por e-mail está desativado para esta conta.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Não foi possível realizar o login.';
    }
  }

  String _mensagemErroCadastro(FirebaseAuthException erro) {
    switch (erro.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'Digite um e-mail válido.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'operation-not-allowed':
        return 'O cadastro por e-mail está desativado.';
      default:
        return 'Não foi possível criar a conta.';
    }
  }

  String _mensagemErroGoogle(FirebaseAuthException erro) {
    switch (erro.code) {
      case 'account-exists-with-different-credential':
        return 'Este e-mail já está vinculado a outro método de login.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Login com Google cancelado.';
      case 'network-request-failed':
        return 'Verifique sua conexão com a internet.';
      case 'method-disabled':
        return 'O acesso pelo Google está desativado para esta conta.';
      default:
        return 'Não foi possível continuar com o Google.';
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: _corDestaque,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _decoracaoCampo({
    required String rotulo,
    required IconData icone,
    Widget? sufixo,
  }) {
    return InputDecoration(
      labelText: rotulo,
      prefixIcon: Icon(icone, color: _corDestaque),
      suffixIcon: sufixo,
      filled: true,
      fillColor: _corCampo,
      labelStyle: TextStyle(color: _corTexto),
      hintStyle: TextStyle(color: _corSecundaria),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _corBorda),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _corBorda),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _corDestaque, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _corFundo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Image.asset(
                    'assets/images/logo_agroplant.png',
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _modoCadastro
                        ? 'Faça parte da AgroPlant'
                        : 'Bem-vindo à AgroPlant!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: _corTexto,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _modoCadastro
                        ? 'Crie sua conta e comece a organizar sua produção.'
                        : 'Entre para gerenciar seus recursos agrícolas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: _corSecundaria,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    color: _corCartao,
                    elevation: 3,
                    shadowColor: verdeClaro.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: _modoCadastro
                                      ? _alternarModo
                                      : null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _modoCadastro
                                        ? _corCampo
                                        : _corDestaque,
                                    foregroundColor: _modoCadastro
                                        ? _corTexto
                                        : Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text('Entrar'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _modoCadastro
                                      ? null
                                      : _alternarModo,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _modoCadastro
                                        ? _corDestaque
                                        : _corCampo,
                                    foregroundColor: _modoCadastro
                                        ? Colors.white
                                        : _corTexto,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text('Criar conta'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (_modoCadastro) ...[
                            TextFormField(
                              controller: _nomeController,
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(color: _corTexto),
                              decoration: _decoracaoCampo(
                                rotulo: 'Nome',
                                icone: Icons.person_outline,
                              ),
                              validator: (valor) {
                                if (valor == null || valor.trim().isEmpty) {
                                  return 'Digite seu nome.';
                                }
                                if (valor.trim().length < 2) {
                                  return 'Digite um nome válido.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: _corTexto),
                            decoration: _decoracaoCampo(
                              rotulo: 'E-mail',
                              icone: Icons.email_outlined,
                            ),
                            validator: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return 'Digite seu e-mail.';
                              }
                              if (!valor.contains('@')) {
                                return 'Digite um e-mail válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _senhaController,
                            obscureText: !_mostrarSenha,
                            style: TextStyle(color: _corTexto),
                            decoration: _decoracaoCampo(
                              rotulo: 'Senha',
                              icone: Icons.lock_outline,
                              sufixo: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _mostrarSenha = !_mostrarSenha;
                                  });
                                },
                                icon: Icon(
                                  _mostrarSenha
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: _corDestaque,
                                ),
                              ),
                            ),
                            validator: (valor) {
                              if (valor == null || valor.isEmpty) {
                                return 'Digite sua senha.';
                              }
                              if (_modoCadastro && valor.length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres.';
                              }
                              return null;
                            },
                          ),
                          if (!_modoCadastro) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _carregando
                                    ? null
                                    : _recuperarSenha,
                                style: TextButton.styleFrom(
                                  foregroundColor: _corDestaque,
                                ),
                                child: const Text(
                                  'Esqueci minha senha',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (_modoCadastro) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmarSenhaController,
                              obscureText: !_mostrarConfirmarSenha,
                              style: TextStyle(color: _corTexto),
                              decoration: _decoracaoCampo(
                                rotulo: 'Confirme sua senha',
                                icone: Icons.lock_outline,
                                sufixo: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _mostrarConfirmarSenha =
                                          !_mostrarConfirmarSenha;
                                    });
                                  },
                                  icon: Icon(
                                    _mostrarConfirmarSenha
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: _corDestaque,
                                  ),
                                ),
                              ),
                              validator: (valor) {
                                if (valor == null || valor.isEmpty) {
                                  return 'Confirme sua senha.';
                                }
                                if (valor != _senhaController.text) {
                                  return 'As senhas não coincidem.';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: _carregando
                                  ? null
                                  : (_modoCadastro ? _cadastrar : _entrar),
                              style: FilledButton.styleFrom(
                                backgroundColor: _corDestaque,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _carregando
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _modoCadastro ? 'Criar conta' : 'Entrar',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: _corBorda),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'ou',
                                  style: TextStyle(color: _corSecundaria),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: _corBorda),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _carregando ? null : _google,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _corDestaque,
                                side: BorderSide(
                                  color: _corDestaque,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(
                                Icons.account_circle_outlined,
                              ),
                              label: Text(
                                _modoCadastro
                                    ? 'Cadastrar com Google'
                                    : 'Continuar com Google',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _carregando ? null : _alternarModo,
                    style: TextButton.styleFrom(
                      foregroundColor: _corDestaque,
                    ),
                    child: Text(
                      _modoCadastro
                          ? 'Já tenho uma conta'
                          : 'Não tenho uma conta',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tecnologia e organização para o campo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: _corSecundaria,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}