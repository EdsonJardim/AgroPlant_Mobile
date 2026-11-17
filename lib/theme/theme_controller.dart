import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.light);

  static Future<void> carregarTema() async {
    final preferencias = await SharedPreferences.getInstance();
    final modoEscuro = preferencias.getBool('modoEscuro') ?? false;

    themeMode.value = modoEscuro ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> alterarTema(bool modoEscuro) async {
    themeMode.value = modoEscuro ? ThemeMode.dark : ThemeMode.light;

    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setBool('modoEscuro', modoEscuro);
  }
}