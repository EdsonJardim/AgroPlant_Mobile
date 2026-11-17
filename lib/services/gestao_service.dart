import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/gestao.dart';

class GestaoService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _gestaoCollection() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    return _firestore
        .collection('users')
        .doc(usuario.uid)
        .collection('gestao');
  }

  Stream<List<Gestao>> listarGestao() {
    return _gestaoCollection()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Gestao.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> adicionarGestao({
    required String tipo,
    required String descricao,
    required String categoria,
    required double valor,
    required String data,
    required String mes,
  }) async {
    final agora = Timestamp.now();

    await _gestaoCollection().add({
      'tipo': tipo,
      'descricao': descricao,
      'categoria': categoria,
      'valor': valor,
      'data': data,
      'mes': mes,
      'createdAt': agora,
      'updatedAt': agora,
    });
  }

  Future<void> atualizarGestao({
    required String id,
    required String tipo,
    required String descricao,
    required String categoria,
    required double valor,
    required String data,
    required String mes,
  }) async {
    await _gestaoCollection().doc(id).update({
      'tipo': tipo,
      'descricao': descricao,
      'categoria': categoria,
      'valor': valor,
      'data': data,
      'mes': mes,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> excluirGestao({
    required String id,
  }) async {
    await _gestaoCollection().doc(id).delete();
  }
}