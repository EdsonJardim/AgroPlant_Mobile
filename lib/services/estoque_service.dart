import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/estoque.dart';

class EstoqueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _estoqueCollection() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    return _firestore
        .collection('users')
        .doc(usuario.uid)
        .collection('estoque');
  }

  Stream<List<Estoque>> listarEstoque() {
    return _estoqueCollection()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((documento) => Estoque.fromFirestore(documento))
              .toList();
        });
  }

  Future<void> adicionarEstoque({
    required String produto,
    required String categoria,
    required double quantidade,
    required String unidade,
    required double preco,
    required String data,
  }) async {
    final agora = Timestamp.now();

    await _estoqueCollection().add({
      'produto': produto,
      'categoria': categoria,
      'quantidade': quantidade,
      'unidade': unidade,
      'preco': preco,
      'data': data,
      'createdAt': agora,
      'updatedAt': agora,
    });
  }

  Future<void> atualizarEstoque({
    required String id,
    required String produto,
    required String categoria,
    required double quantidade,
    required String unidade,
    required double preco,
    required String data,
  }) async {
    await _estoqueCollection().doc(id).update({
      'produto': produto,
      'categoria': categoria,
      'quantidade': quantidade,
      'unidade': unidade,
      'preco': preco,
      'data': data,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> excluirEstoque({required String id}) async {
    await _estoqueCollection().doc(id).delete();
  }
}
