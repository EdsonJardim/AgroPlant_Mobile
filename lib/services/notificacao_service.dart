import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificacaoService {
  NotificacaoService._();

  static final NotificacaoService instance = NotificacaoService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _notificacoesLocais =
      FlutterLocalNotificationsPlugin();

  static const String canalId = 'agroplant_alertas';
  static const String canalNome = 'Alertas do AgroPlant';

  bool _inicializado = false;

  Future<void> inicializar() async {
    if (_inicializado) return;

    const configuracoesAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const configuracoesIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const configuracoes = InitializationSettings(
      android: configuracoesAndroid,
      iOS: configuracoesIOS,
    );

    await _notificacoesLocais.initialize(
      settings: configuracoes,
    );

    const canal = AndroidNotificationChannel(
      canalId,
      canalNome,
      description:
          'Avisos sobre clima, atividades e cuidados com as plantações.',
      importance: Importance.high,
    );

    await _notificacoesLocais
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(canal);

    FirebaseMessaging.onMessage.listen(_aoReceberNotificacao);

    _messaging.onTokenRefresh.listen((token) async {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) return;

      final preferencias = await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .collection('configuracoes')
          .doc('preferencias')
          .get();

      if (preferencias.data()?['notificacoesAtivadas'] == true) {
        await _salvarToken(token, usuario.uid);
      }
    });

    _inicializado = true;
  }

  Future<bool> solicitarPermissaoERegistrar() async {
    final permissao = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final autorizado =
        permissao.authorizationStatus == AuthorizationStatus.authorized ||
        permissao.authorizationStatus == AuthorizationStatus.provisional;

    if (!autorizado) return false;

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return false;

    final token = await _messaging.getToken();

    if (token == null || token.isEmpty) return false;

    await _salvarToken(token, usuario.uid);

    return true;
  }

  Future<void> _salvarToken(String token, String uid) async {
    final idDispositivo =
        base64Url.encode(utf8.encode(token)).replaceAll('=', '');

    final plataforma = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dispositivos')
        .doc(idDispositivo)
        .set({
      'token': token,
      'plataforma': plataforma,
      'ativo': true,
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> desativarRegistro() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    final token = await _messaging.getToken();

    if (token == null || token.isEmpty) return;

    final idDispositivo =
        base64Url.encode(utf8.encode(token)).replaceAll('=', '');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(usuario.uid)
        .collection('dispositivos')
        .doc(idDispositivo)
        .set({
      'ativo': false,
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _aoReceberNotificacao(RemoteMessage mensagem) async {
    final titulo = mensagem.notification?.title ??
        mensagem.data['titulo']?.toString() ??
        'AgroPlant';

    final corpo = mensagem.notification?.body ??
        mensagem.data['corpo']?.toString() ??
        'Você recebeu um novo aviso.';

    await _notificacoesLocais.show(
      id: mensagem.hashCode,
      title: titulo,
      body: corpo,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          canalId,
          canalNome,
          channelDescription:
              'Avisos sobre clima, atividades e cuidados com as plantações.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}