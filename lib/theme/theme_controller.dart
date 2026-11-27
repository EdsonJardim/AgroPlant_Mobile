import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController._();

  static final AppThemeController instance = AppThemeController._();

  static const String _chaveTemaEscuro = 'modo_escuro';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> carregarPreferencia() async {
    final preferencias = await SharedPreferences.getInstance();

    final modoEscuro =
        preferencias.getBool(_chaveTemaEscuro) ?? false;

    _themeMode = modoEscuro ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }

  Future<void> alterarModoEscuro(bool ativado) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setBool(_chaveTemaEscuro, ativado);

    _themeMode = ativado ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }
}