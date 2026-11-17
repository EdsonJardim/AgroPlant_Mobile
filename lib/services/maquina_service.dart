import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/maquina.dart';

class MaquinaService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _colecao() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    return _firestore
        .collection('users')
        .doc(usuario.uid)
        .collection('maquinas');
  }

  Stream<List<Maquina>> observarMaquinas() {
    return _colecao()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (documento) =>
                    Maquina.fromFirestore(documento),
              )
              .toList(),
        );
  }

  Future<void> adicionarMaquina(Maquina maquina) async {
    final agora = Timestamp.now();

    await _colecao().add({
      ...maquina.toFirestore(),
      'createdAt': agora,
      'updatedAt': agora,
    });
  }

  Future<void> atualizarMaquina(Maquina maquina) async {
    await _colecao().doc(maquina.id).update({
      ...maquina.toFirestore(),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> excluirMaquina(String id) async {
    await _colecao().doc(id).delete();
  }
}