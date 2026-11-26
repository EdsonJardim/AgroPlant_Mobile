import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _uidPrincipal =
      'caaZpZoJqZfTwYcsJ1k9AGpxRi53';

  String? get _uidAtual => _auth.currentUser?.uid;

  // Consulta o perfil do administrador autenticado.
  Future<Map<String, dynamic>?> consultarPerfilAdmin() async {
    final uid = _uidAtual;

    if (uid == null) return null;

    final documento = await _firestore
        .collection('admins')
        .doc(uid)
        .get();

    if (!documento.exists) return null;

    return documento.data();
  }

  // Verifica se o usuário autenticado é administrador.
  Future<bool> isAdmin() async {
    final perfil = await consultarPerfilAdmin();

    return perfil != null && perfil['ativo'] == true;
  }

  // Verifica se o usuário autenticado é o super administrador.
  Future<bool> isSuperAdmin() async {
    final uid = _uidAtual;

    if (uid == null) return false;

    if (uid == _uidPrincipal) return true;

    final perfil = await consultarPerfilAdmin();

    return perfil != null &&
        perfil['ativo'] == true &&
        perfil['role'] == 'super_admin';
  }

  // Lista todos os usuários cadastrados.
  Future<List<Map<String, dynamic>>> listarUsuarios() async {
    if (!await isAdmin()) {
      throw Exception('Acesso não autorizado.');
    }

    final usuariosSnapshot =
        await _firestore.collection('users_public').get();

    final statusSnapshot =
        await _firestore.collection('account_status').get();

    final Map<String, bool> statusUsuarios = {};

    for (final documento in statusSnapshot.docs) {
      statusUsuarios[documento.id] =
          documento.data()['ativo'] == true;
    }

    final List<Map<String, dynamic>> usuarios = [];

    for (final documento in usuariosSnapshot.docs) {
      final dados = documento.data();

      usuarios.add({
        'uid': documento.id,
        'nome': dados['nome'] ?? 'Sem nome',
        'email': dados['email'] ?? '',
        'criadoEm': dados['criadoEm'],
        'atualizadoEm': dados['atualizadoEm'],
        'ativo': statusUsuarios[documento.id] ?? true,
      });
    }

    usuarios.sort((a, b) {
      return (a['nome'] as String)
          .toLowerCase()
          .compareTo((b['nome'] as String).toLowerCase());
    });

    return usuarios;
  }

  // Ativa ou desativa uma conta de usuário.
  Future<void> alterarStatusUsuario({
    required String uid,
    required bool ativo,
  }) async {
    if (!await isAdmin()) {
      throw Exception('Acesso não autorizado.');
    }

    if (uid == _uidAtual) {
      throw Exception('Você não pode alterar o status da sua própria conta.');
    }

    await _firestore
        .collection('account_status')
        .doc(uid)
        .set({
      'ativo': ativo,
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Lista os administradores cadastrados.
  Future<List<Map<String, dynamic>>> listarAdministradores() async {
    if (!await isSuperAdmin()) {
      throw Exception('Apenas o super administrador pode acessar esta área.');
    }

    final snapshot = await _firestore
        .collection('admins')
        .get();

    final List<Map<String, dynamic>> administradores = [];

    for (final documento in snapshot.docs) {
      final dados = documento.data();

      administradores.add({
        'uid': documento.id,
        'nome': dados['nome'] ?? 'Sem nome',
        'email': dados['email'] ?? '',
        'role': dados['role'] ?? 'team_admin',
        'ativo': dados['ativo'] == true,
        'criadoEm': dados['criadoEm'],
      });
    }

    administradores.sort((a, b) {
      return (a['nome'] as String)
          .toLowerCase()
          .compareTo((b['nome'] as String).toLowerCase());
    });

    return administradores;
  }

  // Lista usuários que ainda não são administradores.
  Future<List<Map<String, dynamic>>>
      listarUsuariosDisponiveisParaAdmin() async {
    if (!await isSuperAdmin()) {
      throw Exception('Apenas o super administrador pode realizar esta ação.');
    }

    final usuariosSnapshot =
        await _firestore.collection('users_public').get();

    final adminsSnapshot =
        await _firestore.collection('admins').get();

    final Set<String> uidsAdministradores =
        adminsSnapshot.docs.map((doc) => doc.id).toSet();

    final List<Map<String, dynamic>> disponiveis = [];

    for (final documento in usuariosSnapshot.docs) {
      if (documento.id == _uidPrincipal) continue;

      if (uidsAdministradores.contains(documento.id)) continue;

      final dados = documento.data();

      disponiveis.add({
        'uid': documento.id,
        'nome': dados['nome'] ?? 'Sem nome',
        'email': dados['email'] ?? '',
      });
    }

    disponiveis.sort((a, b) {
      return (a['nome'] as String)
          .toLowerCase()
          .compareTo((b['nome'] as String).toLowerCase());
    });

    return disponiveis;
  }

  // Cadastra um novo administrador da equipe.
  Future<void> cadastrarAdministrador({
    required String uid,
    required String nome,
    required String email,
  }) async {
    if (!await isSuperAdmin()) {
      throw Exception('Apenas o super administrador pode cadastrar administradores.');
    }

    if (uid == _uidPrincipal) {
      throw Exception('O administrador principal não pode ser alterado.');
    }

    final documento = await _firestore
        .collection('admins')
        .doc(uid)
        .get();

    if (documento.exists) {
      throw Exception('Este usuário já é administrador.');
    }

    await _firestore
        .collection('admins')
        .doc(uid)
        .set({
      'nome': nome,
      'email': email,
      'role': 'team_admin',
      'ativo': true,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  // Ativa ou desativa um administrador da equipe.
  Future<void> alterarStatusAdministrador({
    required String uid,
    required bool ativo,
  }) async {
    if (!await isSuperAdmin()) {
      throw Exception('Apenas o super administrador pode alterar administradores.');
    }

    if (uid == _uidPrincipal) {
      throw Exception('O administrador principal não pode ser desativado.');
    }

    await _firestore
        .collection('admins')
        .doc(uid)
        .update({
      'ativo': ativo,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  // Remove um administrador da equipe.
  Future<void> removerAdministrador(String uid) async {
    if (!await isSuperAdmin()) {
      throw Exception('Apenas o super administrador pode remover administradores.');
    }

    if (uid == _uidPrincipal) {
      throw Exception('O administrador principal não pode ser removido.');
    }

    await _firestore
        .collection('admins')
        .doc(uid)
        .delete();
  }
}