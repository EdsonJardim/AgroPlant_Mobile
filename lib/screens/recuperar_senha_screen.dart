import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  State<RecuperarSenhaScreen> createState() =>
      _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _carregando = false;

  static const Color verde = Color(0xFF174D2A);
  static const Color verdeClaro = Color(0xFF78A878);
  static const Color bege = Color(0xFFE8DCC6);
  static const Color begeClaro = Color(0xFFF7F2E8);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se o e-mail estiver cadastrado, você receberá um link para redefinir sua senha. Verifique também o spam.',
          ),
          backgroundColor: verde,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (erro) {
      if (erro.code == 'invalid-email') {
        _mostrarErro('Digite um e-mail válido.');
      } else if (erro.code == 'too-many-requests') {
        _mostrarErro('Muitas tentativas. Tente novamente mais tarde.');
      } else if (erro.code == 'network-request-failed') {
        _mostrarErro('Verifique sua conexão com a internet.');
      } else {
        _mostrarErro('Não foi possível enviar o link de recuperação.');
      }
    } catch (erro) {
      debugPrint('Erro ao recuperar senha: $erro');
      _mostrarErro('Ocorreu um erro ao recuperar sua senha.');
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: verde,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _decoracaoCampo(bool escuro) {
    final corDestaque = escuro ? verdeClaro : verde;
    final corFundo = escuro
        ? const Color(0xFF29372D)
        : begeClaro;
    final corBorda = escuro
        ? const Color(0xFF46594A)
        : bege;

    return InputDecoration(
      labelText: 'E-mail',
      hintText: 'Digite seu e-mail cadastrado',
      prefixIcon: Icon(
        Icons.email_outlined,
        color: corDestaque,
      ),
      filled: true,
      fillColor: corFundo,
      labelStyle: TextStyle(color: corDestaque),
      hintStyle: TextStyle(
        color: escuro ? Colors.white54 : const Color(0xFF62594B),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: corBorda),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: corBorda),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: corDestaque, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final corFundo = escuro
        ? const Color(0xFF121A14)
        : bege;
    final corCartao = escuro
        ? const Color(0xFF202B23)
        : Colors.white;
    final corTexto = escuro ? Colors.white : verde;
    final corTextoSecundario = escuro
        ? Colors.white70
        : const Color(0xFF62594B);
    final corDestaque = escuro ? verdeClaro : verde;

    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: corFundo,
        foregroundColor: corTexto,
        elevation: 0,
        title: Text(
          'Recuperar senha',
          style: TextStyle(
            color: corTexto,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: corCartao,
              elevation: 3,
              shadowColor: verdeClaro.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: 75,
                        color: corDestaque,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Esqueceu sua senha?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: corTexto,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Informe o e-mail cadastrado na AgroPlant. Enviaremos um link para você criar uma nova senha.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: corTextoSecundario,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: corTexto),
                        decoration: _decoracaoCampo(escuro),
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Digite seu e-mail.';
                          }

                          if (!RegExp(
                            r'^[^@]+@[^@]+\.[^@]+$',
                          ).hasMatch(valor.trim())) {
                            return 'Digite um e-mail válido.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _carregando ? null : _enviarLink,
                          style: FilledButton.styleFrom(
                            backgroundColor: verde,
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
                              : const Text(
                                  'Enviar link de recuperação',
                                  style: TextStyle(
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
            ),
          ),
        ),
      ),
    );
  }
}