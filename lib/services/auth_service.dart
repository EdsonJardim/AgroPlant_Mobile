import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _referenciaAutenticacao(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('configuracoes')
        .doc('autenticacao');
  }

  Future<void> _garantirConfiguracao(String uid) async {
    final referencia = _referenciaAutenticacao(uid);
    final documento = await referencia.get();

    if (!documento.exists) {
      await referencia.set({
        'emailDesativado': false,
        'googleDesativado': false,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<bool> metodoDesativado({
    required String uid,
    required String metodo,
  }) async {
    final documento = await _referenciaAutenticacao(uid).get();

    if (!documento.exists) return false;

    final dados = documento.data();

    if (metodo == 'email') {
      return dados?['emailDesativado'] == true;
    }

    if (metodo == 'google') {
      return dados?['googleDesativado'] == true;
    }

    throw ArgumentError('Método de autenticação inválido.');
  }

  Future<Map<String, bool>> consultarMetodosVinculados() async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      return {
        'email': false,
        'google': false,
      };
    }

    final provedores = usuario.providerData
        .map((provedor) => provedor.providerId)
        .toSet();

    return {
      'email': provedores.contains('password'),
      'google': provedores.contains('google.com'),
    };
  }

  Future<int> _quantidadeMetodosVinculados(User usuario) async {
    await usuario.reload();

    final usuarioAtualizado = _auth.currentUser;

    if (usuarioAtualizado == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Nenhum usuário autenticado.',
      );
    }

    final metodos = usuarioAtualizado.providerData
        .map((provedor) => provedor.providerId)
        .where((id) => id == 'password' || id == 'google.com')
        .toSet();

    return metodos.length;
  }

  Future<void> definirMetodoDesativado({
    required String metodo,
    required bool desativado,
  }) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Nenhum usuário autenticado.',
      );
    }

    if (metodo != 'email' && metodo != 'google') {
      throw ArgumentError('Método de autenticação inválido.');
    }

    await _garantirConfiguracao(usuario.uid);

    final metodos = await consultarMetodosVinculados();

    if (metodos[metodo] != true) {
      throw FirebaseAuthException(
        code: 'provider-not-linked',
        message: 'Este método não está vinculado à conta.',
      );
    }

    if (desativado) {
      final outroMetodo = metodo == 'email' ? 'google' : 'email';

      if (metodos[outroMetodo] != true) {
        throw FirebaseAuthException(
          code: 'last-provider',
          message: 'Não é possível desativar seu único método de acesso.',
        );
      }
    }

    final campo = metodo == 'email'
        ? 'emailDesativado'
        : 'googleDesativado';

    await _referenciaAutenticacao(usuario.uid).set({
      campo: desativado,
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (desativado) {
      await logout();
    }
  }

  Future<void> excluirMetodo(String metodo) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Nenhum usuário autenticado.',
      );
    }

    if (metodo != 'email' && metodo != 'google') {
      throw ArgumentError('Método de autenticação inválido.');
    }

    final metodos = await consultarMetodosVinculados();

    if (metodos[metodo] != true) {
      throw FirebaseAuthException(
        code: 'provider-not-linked',
        message: 'Este método não está vinculado à conta.',
      );
    }

    if (await _quantidadeMetodosVinculados(usuario) <= 1) {
      throw FirebaseAuthException(
        code: 'last-provider',
        message: 'Não é possível excluir seu único método de acesso.',
      );
    }

    final provedor = metodo == 'email' ? 'password' : 'google.com';

    await usuario.unlink(provedor);

    final campo = metodo == 'email'
        ? 'emailDesativado'
        : 'googleDesativado';

    await _referenciaAutenticacao(usuario.uid).set({
      campo: false,
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> verificarMetodoAtivo({
    required User usuario,
    required String metodo,
  }) async {
    await _garantirConfiguracao(usuario.uid);

    final desativado = await metodoDesativado(
      uid: usuario.uid,
      metodo: metodo,
    );

    if (desativado) {
      await logout();

      throw FirebaseAuthException(
        code: 'method-disabled',
        message: 'Este método de acesso está desativado.',
      );
    }
  }

  Future<User?> login({
    required String email,
    required String senha,
  }) async {
    final credencial = await _auth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );

    final usuario = credencial.user;

    if (usuario != null) {
      await verificarMetodoAtivo(
        usuario: usuario,
        metodo: 'email',
      );
    }

    return usuario;
  }

  Future<User?> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );

    final usuario = credencial.user;

    if (usuario != null) {
      await usuario.updateDisplayName(nome);
      await usuario.reload();
      await _garantirConfiguracao(usuario.uid);
    }

    return _auth.currentUser;
  }

  Future<User?> loginComGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize();

    final GoogleSignInAccount conta =
        await googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        conta.authentication;

    final credencial = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final resultado = await _auth.signInWithCredential(credencial);

    final usuario = resultado.user;

    if (usuario != null) {
      await verificarMetodoAtivo(
        usuario: usuario,
        metodo: 'google',
      );
    }

    return usuario;
  }

  Future<void> logout() async {
    await _auth.signOut();

    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  User? get usuarioAtual => _auth.currentUser;
}