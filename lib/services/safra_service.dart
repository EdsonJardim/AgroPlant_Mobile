import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/safra.dart';

class SafraService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _colecao() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    return _firestore
        .collection('users')
        .doc(usuario.uid)
        .collection('safra');
  }

  Stream<List<Safra>> observarSafras() {
    return _colecao()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (documento) => Safra.fromFirestore(documento),
              )
              .toList(),
        );
  }

  Future<void> adicionarSafra(Safra safra) async {
    final agora = Timestamp.now();

    await _colecao().add({
      'plantacao': safra.plantacao,
      'tipo': safra.tipo,
      'maquinario': safra.maquinario,
      'tempoColheita': safra.tempoColheita,
      'custo': safra.custo,
      'status': safra.status,
      'createdAt': agora,
      'updatedAt': agora,
    });
  }

  Future<void> atualizarSafra(Safra safra) async {
    await _colecao().doc(safra.id).update({
      'plantacao': safra.plantacao,
      'tipo': safra.tipo,
      'maquinario': safra.maquinario,
      'tempoColheita': safra.tempoColheita,
      'custo': safra.custo,
      'status': safra.status,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> excluirSafra(String id) async {
    await _colecao().doc(id).delete();
  }
}