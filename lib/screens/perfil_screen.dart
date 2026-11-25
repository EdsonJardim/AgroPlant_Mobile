import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import '../widgets/agroplant_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  static const Color verde = Color(0xFF174D2A);
  static const Color verdeClaro = Color(0xFF78A878);
  static const Color bege = Color(0xFFE8DCC6);
  static const Color fundo = Color(0xFFF7F2E8);
  static const Color textoSecundario = Color(0xFF62594B);

  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  static const String _chaveFoto = 'foto_perfil_agroplant';

  String? _caminhoFoto;
  bool _carregandoFoto = false;

  Map<String, bool> _metodosVinculados = {'email': false, 'google': false};
  Map<String, bool> _metodosDesativados = {'email': false, 'google': false};

  bool _carregandoMetodos = true;

  User? get _usuario => FirebaseAuth.instance.currentUser;

  bool get _escuro =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _corFundo =>
      _escuro ? const Color(0xFF121A14) : fundo;

  Color get _corCartao =>
      _escuro ? const Color(0xFF202B23) : Colors.white;

  Color get _corTexto =>
      _escuro ? Colors.white : verde;

  Color get _corTextoSecundario =>
      _escuro ? Colors.white70 : textoSecundario;

  Color get _corDetalhe =>
      _escuro ? const Color(0xFF29372D) : bege;

  Color get _corAppBar =>
      _escuro ? const Color(0xFF202B23) : fundo;

  Color get _corBorda =>
      _escuro ? const Color(0xFF3B5140) : bege;

  @override
  void initState() {
    super.initState();
    _carregarFoto();
    _carregarMetodos();
  }

  Future<void> _carregarFoto() async {
    final preferencias = await SharedPreferences.getInstance();
    final caminho = preferencias.getString(_chaveFoto);

    if (!mounted) return;

    if (caminho != null && await File(caminho).exists()) {
      setState(() {
        _caminhoFoto = caminho;
      });
    } else {
      await preferencias.remove(_chaveFoto);
    }
  }

  Future<void> _selecionarFoto() async {
    try {
      final imagem = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (imagem == null) return;

      setState(() {
        _carregandoFoto = true;
      });

      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setString(_chaveFoto, imagem.path);

      if (!mounted) return;

      setState(() {
        _caminhoFoto = imagem.path;
        _carregandoFoto = false;
      });

      _mensagem('Foto de perfil atualizada com sucesso!');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregandoFoto = false;
      });

      _mensagem('Não foi possível selecionar a foto.');
    }
  }

  Future<void> _removerFoto() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(_chaveFoto);

    if (!mounted) return;

    setState(() {
      _caminhoFoto = null;
    });

    _mensagem('Foto de perfil removida.');
  }

  Future<void> _mostrarOpcoesFoto() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: _corCartao,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Foto de perfil',
                  style: TextStyle(
                    color: _corTexto,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _selecionarFoto();
                    },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Escolher da galeria'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                if (_caminhoFoto != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _removerFoto();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remover foto'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                        side: BorderSide(color: Colors.red.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _mensagem(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: verde,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // EDITAR NOME
  // ============================================================

  Future<void> _editarNome() async {
    final usuario = _usuario;
    if (usuario == null) return;

    final controller = TextEditingController(
      text: usuario.displayName ?? '',
    );

    final nome = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _corCartao,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Editar nome',
            style: TextStyle(
              color: _corTexto,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: _corTexto),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nome completo',
              labelStyle: TextStyle(color: _corTextoSecundario),
              prefixIcon: Icon(Icons.person_outline, color: _corTexto),
              filled: true,
              fillColor: _corFundo,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _corBorda),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _corBorda),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: TextStyle(color: _corTextoSecundario),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: verde,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (nome == null) return;

    if (nome.isEmpty) {
      _mensagem('Informe seu nome.');
      return;
    }

    try {
      await usuario.updateDisplayName(nome);
      await usuario.reload();

      final usuarioAtualizado = FirebaseAuth.instance.currentUser;

      if (usuarioAtualizado != null) {
        final nomeAtualizado = usuarioAtualizado.displayName ?? nome;

        // Atualiza o documento privado do usuário.
        await FirebaseFirestore.instance
            .collection('users')
            .doc(usuarioAtualizado.uid)
            .update({
          'nome': nomeAtualizado,
          'atualizadoEm': FieldValue.serverTimestamp(),
        });

        // Mantém o diretório público sincronizado para o painel administrativo.
        await FirebaseFirestore.instance
            .collection('users_public')
            .doc(usuarioAtualizado.uid)
            .set({
          'nome': nomeAtualizado,
          'email': usuarioAtualizado.email ?? '',
          'atualizadoEm': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;

      setState(() {});
      _mensagem('Nome atualizado com sucesso!');
    } catch (e) {
      _mensagem('Erro ao atualizar nome.');
    }
  }

  Future<void> _alterarSenha() async {
    final email = _usuario?.email;

    if (email == null || email.isEmpty) {
      _mensagem('Não foi possível identificar o e-mail da conta.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _mensagem('Enviamos um link para redefinir sua senha.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        _mensagem('O e-mail cadastrado é inválido.');
      } else {
        _mensagem('Não foi possível enviar o e-mail de recuperação.');
      }
    } catch (e) {
      _mensagem('Ocorreu um erro ao solicitar a alteração da senha.');
    }
  }

  Future<void> _sairDaConta() async {
    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _mensagem('Não foi possível sair da conta.');
    }
  }

  Future<void> _carregarMetodos() async {
    try {
      final usuario = _usuario;
      if (usuario == null) return;

      final vinculados = await _authService.consultarMetodosVinculados();

      final emailDesativado = vinculados['email'] == true
          ? await _authService.metodoDesativado(
              uid: usuario.uid,
              metodo: 'email',
            )
          : false;

      final googleDesativado = vinculados['google'] == true
          ? await _authService.metodoDesativado(
              uid: usuario.uid,
              metodo: 'google',
            )
          : false;

      if (!mounted) return;

      setState(() {
        _metodosVinculados = vinculados;
        _metodosDesativados = {
          'email': emailDesativado,
          'google': googleDesativado,
        };
        _carregandoMetodos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregandoMetodos = false;
      });

      _mensagem('Não foi possível carregar os métodos de acesso.');
    }
  }

  String _nomeMetodo(String metodo) {
    return metodo == 'email' ? 'E-mail' : 'Google';
  }

  Future<String?> _selecionarMetodo(String titulo) async {
    final emailVinculado = _metodosVinculados['email'] == true;
    final googleVinculado = _metodosVinculados['google'] == true;

    if (emailVinculado && !googleVinculado) return 'email';
    if (googleVinculado && !emailVinculado) return 'google';

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _corCartao,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _corTexto,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emailVinculado)
                _botaoDialogo(
                  context: dialogContext,
                  metodo: 'email',
                  cor: Colors.red.shade700,
                ),
              if (emailVinculado && googleVinculado)
                const SizedBox(height: 16),
              if (googleVinculado)
                _botaoDialogo(
                  context: dialogContext,
                  metodo: 'google',
                  cor: Colors.red.shade700,
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.block),
                  label: const Text('Cancelar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verde,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _botaoDialogo({
    required BuildContext context,
    required String metodo,
    required Color cor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context, metodo),
        icon: Icon(
          metodo == 'email' ? Icons.email_outlined : Icons.g_mobiledata,
          size: 30,
        ),
        label: Text(_nomeMetodo(metodo)),
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmarAcao({
    required String titulo,
    required String mensagem,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _corCartao,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            titulo,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            mensagem,
            style: TextStyle(color: _corTexto),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: _corTextoSecundario),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    return resultado == true;
  }

  Future<void> _desativarMetodo() async {
    final metodo = await _selecionarMetodo('Qual conta deseja desativar?');

    if (metodo == null || !mounted) return;

    if (_metodosDesativados[metodo] == true) {
      _mensagem('Esse método já está desativado.');
      return;
    }

    final confirmado = await _confirmarAcao(
      titulo: 'Desativar ${_nomeMetodo(metodo)}',
      mensagem:
          'Deseja realmente desativar o acesso por ${_nomeMetodo(metodo)}? Você poderá reativá-lo posteriormente usando outro método de acesso.',
    );

    if (!confirmado || !mounted) return;

    try {
      await _authService.definirMetodoDesativado(
        metodo: metodo,
        desativado: true,
      );

      if (!mounted) return;

      _mensagem('Método desativado. Entre novamente pelo outro método.');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'last-provider') {
        _mensagem('Não é possível desativar seu único método de acesso.');
      } else {
        _mensagem(e.message ?? 'Não foi possível desativar o método.');
      }
    } catch (e) {
      _mensagem('Não foi possível desativar o método.');
    }
  }

  Future<void> _reativarMetodo(String metodo) async {
    try {
      await _authService.definirMetodoDesativado(
        metodo: metodo,
        desativado: false,
      );

      await _carregarMetodos();

      if (!mounted) return;

      _mensagem('Acesso por ${_nomeMetodo(metodo)} reativado!');
    } catch (e) {
      _mensagem('Não foi possível reativar esse método.');
    }
  }

  Future<void> _excluirMetodo() async {
    final metodo = await _selecionarMetodo('Qual conta deseja excluir?');

    if (metodo == null || !mounted) return;

    final confirmado = await _confirmarAcao(
      titulo: 'Excluir ${_nomeMetodo(metodo)}',
      mensagem:
          'Deseja realmente remover o vínculo com ${_nomeMetodo(metodo)}? Essa ação não poderá ser desfeita por este aplicativo.',
    );

    if (!confirmado || !mounted) return;

    try {
      await _authService.excluirMetodo(metodo);
      await _carregarMetodos();

      if (!mounted) return;

      _mensagem('Vínculo com ${_nomeMetodo(metodo)} removido.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'last-provider') {
        _mensagem('Não é possível excluir seu único método de acesso.');
      } else if (e.code == 'requires-recent-login') {
        _mensagem(
          'Por segurança, entre novamente na conta e tente excluir o método.',
        );
      } else {
        _mensagem(e.message ?? 'Não foi possível excluir o método.');
      }
    } catch (e) {
      _mensagem('Não foi possível excluir o método.');
    }
  }

  Widget _secaoGerenciarMetodos() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _corCartao,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _escuro ? 0.15 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métodos de acesso',
            style: TextStyle(
              color: _corTexto,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_carregandoMetodos)
            Center(
              child: CircularProgressIndicator(color: _corTexto),
            )
          else ...[
            if (_metodosVinculados['email'] == true) _itemMetodo('email'),
            if (_metodosVinculados['google'] == true) _itemMetodo('google'),
            if (_metodosVinculados.values.every((vinculado) => !vinculado))
              Text(
                'Nenhum método de acesso encontrado.',
                style: TextStyle(color: _corTextoSecundario),
              ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _carregandoMetodos ? null : _desativarMetodo,
              icon: const Icon(Icons.block),
              label: const Text('Desativar conta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _carregandoMetodos ? null : _excluirMetodo,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir conta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemMetodo(String metodo) {
    final desativado = _metodosDesativados[metodo] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            metodo == 'email' ? Icons.email_outlined : Icons.g_mobiledata,
            color: _corTexto,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nomeMetodo(metodo),
                  style: TextStyle(
                    color: _corTexto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  desativado ? 'Desativado' : 'Ativo',
                  style: TextStyle(
                    color: desativado
                        ? Colors.red.shade400
                        : Colors.green.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (desativado)
            TextButton(
              onPressed: () => _reativarMetodo(metodo),
              child: Text(
                'Reativar',
                style: TextStyle(
                  color: _corTexto,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fotoPerfil(User? usuario) {
    return GestureDetector(
      onTap: _carregandoFoto ? null : _mostrarOpcoesFoto,
      child: Stack(
        children: [
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              color: _corDetalhe,
              shape: BoxShape.circle,
              border: Border.all(color: verdeClaro, width: 3),
            ),
            child: ClipOval(
              child: _caminhoFoto != null && File(_caminhoFoto!).existsSync()
                  ? Image.file(
                      File(_caminhoFoto!),
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    )
                  : usuario?.photoURL != null
                      ? Image.network(
                          usuario!.photoURL!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 65,
                              color: _corTexto,
                            );
                          },
                        )
                      : Icon(
                          Icons.person,
                          size: 65,
                          color: _corTexto,
                        ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: verde,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _corCartao,
                  width: 2,
                ),
              ),
              child: _carregandoFoto
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 19,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoInformacao({
    required IconData icone,
    required String titulo,
    required String valor,
    VoidCallback? onEditar,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _corCartao,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _escuro ? 0.15 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _corDetalhe,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icone, color: _corTexto, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 13,
                    color: _corTextoSecundario,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _corTexto,
                  ),
                ),
              ],
            ),
          ),
          if (onEditar != null)
            IconButton(
              onPressed: onEditar,
              tooltip: 'Editar nome',
              icon: Icon(Icons.edit_outlined, color: _corTexto),
            ),
        ],
      ),
    );
  }

  Widget _tituloSecao(String titulo) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _corTexto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario;
    final nome = usuario?.displayName?.trim();
    final nomeExibicao =
        nome != null && nome.isNotEmpty ? nome : 'Usuário';

    return Scaffold(
      backgroundColor: _corFundo,
      appBar: AgroPlantAppBar(
        backgroundColor: _corAppBar,
        foregroundColor: _corTexto,
        title: Text(
          'Meu perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _corTexto,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _corCartao,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: _escuro ? 0.15 : 0.05,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _fotoPerfil(usuario),
                    const SizedBox(height: 10),
                    Text(
                      'Toque na foto para alterar',
                      style: TextStyle(
                        color: _corTextoSecundario,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      nomeExibicao,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: _corTexto,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      usuario?.email ?? 'E-mail não disponível',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: _corTextoSecundario,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _corDetalhe,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Conta AgroPlant',
                        style: TextStyle(
                          color: _corTexto,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _tituloSecao('Informações pessoais'),
              const SizedBox(height: 14),
              _cartaoInformacao(
                icone: Icons.person_outline,
                titulo: 'Nome completo',
                valor: nomeExibicao,
                onEditar: _editarNome,
              ),
              const SizedBox(height: 12),
              _cartaoInformacao(
                icone: Icons.email_outlined,
                titulo: 'E-mail',
                valor: usuario?.email ?? 'Não informado',
              ),
              const SizedBox(height: 28),
              _tituloSecao('Segurança da conta'),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _corCartao,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: _escuro ? 0.15 : 0.05,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _corDetalhe,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: _corTexto,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Senha',
                            style: TextStyle(
                              fontSize: 13,
                              color: _corTextoSecundario,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Redefinir senha por e-mail',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _corTexto,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _alterarSenha,
                      tooltip: 'Redefinir senha',
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: _corTexto,
                        size: 19,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _tituloSecao('Gerenciar conta'),
              const SizedBox(height: 14),
              _secaoGerenciarMetodos(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _sairDaConta,
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Sair da conta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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