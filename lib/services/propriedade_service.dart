import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/propriedade.dart';

class PropriedadeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int limitePropriedades = 3;

  String get _uid {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    return usuario.uid;
  }

  DocumentReference<Map<String, dynamic>> get _usuarioRef {
    return _firestore.collection('users').doc(_uid);
  }

  CollectionReference<Map<String, dynamic>> get _propriedadesRef {
    return _usuarioRef.collection('propriedades');
  }

  Stream<List<PropriedadeModel>> observarPropriedades() {
    return _propriedadesRef
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PropriedadeModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<int> quantidadePropriedades() async {
    final snapshot = await _propriedadesRef.get();
    return snapshot.docs.length;
  }

  Future<void> cadastrarPropriedade({
    required String nome,
    required String endereco,
    required double latitude,
    required double longitude,
    required double areaHectares,
  }) async {
    final usuarioRef = _usuarioRef;
    final propriedadeRef = _propriedadesRef.doc();

    await _firestore.runTransaction((transaction) async {
      final usuario = await transaction.get(usuarioRef);
      final dados = usuario.data();

      final total =
          (dados?['totalPropriedades'] as num?)?.toInt() ?? 0;

      if (total >= limitePropriedades) {
        throw Exception(
          'Você atingiu o limite de $limitePropriedades propriedades cadastradas.',
        );
      }

      transaction.set(propriedadeRef, {
        'nome': nome,
        'endereco': endereco,
        'latitude': latitude,
        'longitude': longitude,
        'areaHectares': areaHectares,
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });

      transaction.set(
        usuarioRef,
        {'totalPropriedades': total + 1},
        SetOptions(merge: true),
      );
    });
  }

  Future<void> atualizarPropriedade(
    PropriedadeModel propriedade,
  ) async {
    await _propriedadesRef.doc(propriedade.id).update({
      ...propriedade.toMap(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> excluirPropriedade(String propriedadeId) async {
    final usuarioRef = _usuarioRef;
    final propriedadeRef = _propriedadesRef.doc(propriedadeId);

    await _firestore.runTransaction((transaction) async {
      final propriedade = await transaction.get(propriedadeRef);

      if (!propriedade.exists) return;

      final usuario = await transaction.get(usuarioRef);
      final dados = usuario.data();

      final total =
          (dados?['totalPropriedades'] as num?)?.toInt() ?? 0;

      transaction.delete(propriedadeRef);

      transaction.set(
        usuarioRef,
        {'totalPropriedades': total > 0 ? total - 1 : 0},
        SetOptions(merge: true),
      );
    });
  }
}