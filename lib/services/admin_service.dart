import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _uidPrincipal =
      'caaZpZoJqZfTwYcsJ1k9AGpxRi53';

  Future<String?> consultarPerfilAdmin() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return null;

    if (usuario.uid == _uidPrincipal) {
      return 'super_admin';
    }

    final documento = await _firestore
        .collection('admins')
        .doc(usuario.uid)
        .get();

    if (!documento.exists) return null;

    final dados = documento.data();

    if (dados == null || dados['ativo'] != true) {
      return null;
    }

    if (dados['role'] == 'team_admin') {
      return 'team_admin';
    }

    return null;
  }

  Future<bool> isAdmin() async {
    return await consultarPerfilAdmin() != null;
  }

  Future<bool> isSuperAdmin() async {
    return await consultarPerfilAdmin() == 'super_admin';
  }

  Future<void> _verificarAdministrador() async {
    if (!await isAdmin()) {
      throw Exception(
        'Acesso permitido somente para administradores.',
      );
    }
  }

  Future<void> _verificarSuperAdmin() async {
    if (!await isSuperAdmin()) {
      throw Exception(
        'Somente o administrador principal pode realizar esta ação.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> listarUsuarios() async {
    await _verificarAdministrador();

    final resultado = await _firestore
        .collection('users_public')
        .get();

    final usuarios = await Future.wait(
      resultado.docs.map((documento) async {
        final status = await _firestore
            .collection('account_status')
            .doc(documento.id)
            .get();

        final dadosStatus = status.data();
        final dados = documento.data();

        return <String, dynamic>{
          'uid': documento.id,
          'nome': dados['nome'] ?? 'Nome não informado',
          'email': dados['email'] ?? 'E-mail não informado',
          'ativo': dadosStatus == null
              ? true
              : dadosStatus['ativo'] == true,
        };
      }),
    );

    usuarios.sort(
      (a, b) => (a['nome'] as String).toLowerCase().compareTo(
            (b['nome'] as String).toLowerCase(),
          ),
    );

    return usuarios;
  }

  Future<void> alterarStatusUsuario({
    required String uid,
    required bool ativo,
  }) async {
    await _verificarAdministrador();

    final usuarioAtual = FirebaseAuth.instance.currentUser;

    if (usuarioAtual == null) {
      throw Exception('Administrador não autenticado.');
    }

    if (uid == usuarioAtual.uid) {
      throw Exception(
        'Você não pode alterar o status da sua própria conta.',
      );
    }

    await _firestore.collection('account_status').doc(uid).set({
      'ativo': ativo,
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> listarAdministradores() async {
    await _verificarSuperAdmin();

    final resultado = await _firestore
        .collection('admins')
        .get();

    final administradores = resultado.docs.map((documento) {
      final dados = documento.data();

      return <String, dynamic>{
        'uid': documento.id,
        'nome': dados['nome'] ?? 'Nome não informado',
        'email': dados['email'] ?? 'E-mail não informado',
        'role': dados['role'] ?? 'team_admin',
        'ativo': dados['ativo'] == true,
      };
    }).toList();

    administradores.sort(
      (a, b) => (a['nome'] as String).toLowerCase().compareTo(
            (b['nome'] as String).toLowerCase(),
          ),
    );

    return administradores;
  }

  Future<List<Map<String, dynamic>>>
      listarUsuariosDisponiveisParaAdmin() async {
    await _verificarSuperAdmin();

    final resultados = await Future.wait([
      _firestore.collection('users_public').get(),
      _firestore.collection('admins').get(),
    ]);

    final usuarios = resultados[0].docs;
    final administradores = resultados[1].docs;

    final uidsAdministradores = administradores
        .map((documento) => documento.id)
        .toSet();

    final disponiveis = usuarios
        .where((documento) =>
            documento.id != _uidPrincipal &&
            !uidsAdministradores.contains(documento.id))
        .map((documento) {
      final dados = documento.data();

      return <String, dynamic>{
        'uid': documento.id,
        'nome': dados['nome'] ?? 'Nome não informado',
        'email': dados['email'] ?? 'E-mail não informado',
      };
    }).toList();

    disponiveis.sort(
      (a, b) => (a['nome'] as String).toLowerCase().compareTo(
            (b['nome'] as String).toLowerCase(),
          ),
    );

    return disponiveis;
  }

  Future<void> cadastrarAdministrador({
    required String uid,
    required String nome,
    required String email,
  }) async {
    await _verificarSuperAdmin();

    if (uid == _uidPrincipal) {
      throw Exception(
        'O administrador principal não pode ser alterado.',
      );
    }

    final usuario = await _firestore
        .collection('users_public')
        .doc(uid)
        .get();

    if (!usuario.exists) {
      throw Exception('Usuário não encontrado.');
    }

    final referenciaAdmin = _firestore.collection('admins').doc(uid);
    final administradorExistente = await referenciaAdmin.get();

    if (administradorExistente.exists) {
      throw Exception('Este usuário já é administrador.');
    }

    await referenciaAdmin.set({
      'nome': nome,
      'email': email,
      'role': 'team_admin',
      'ativo': true,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> alterarStatusAdministrador({
    required String uid,
    required bool ativo,
  }) async {
    await _verificarSuperAdmin();

    if (uid == _uidPrincipal) {
      throw Exception(
        'O administrador principal não pode ser alterado.',
      );
    }

    await _firestore.collection('admins').doc(uid).update({
      'ativo': ativo,
    });
  }

  Future<void> removerAdministrador(String uid) async {
    await _verificarSuperAdmin();

    if (uid == _uidPrincipal) {
      throw Exception(
        'O administrador principal não pode ser removido.',
      );
    }

    await _firestore.collection('admins').doc(uid).delete();
  }
}