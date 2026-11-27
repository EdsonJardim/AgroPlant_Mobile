import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'services/notificacao_service.dart';
import 'theme/theme_controller.dart';

@pragma('vm:entry-point')
Future<void> tratarNotificacaoEmSegundoPlano(
  RemoteMessage mensagem,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    tratarNotificacaoEmSegundoPlano,
  );

  await NotificacaoService.instance.inicializar();

  await AppThemeController.instance.carregarPreferencia();

  runApp(const AgroPlantApp());
}

class AgroPlantApp extends StatelessWidget {
  const AgroPlantApp({super.key});

  static const Color verde = Color(0xFF174D2A);
  static const Color verdeDetalhe = Color(0xFF78A878);
  static const Color bege = Color(0xFFE8DCC6);
  static const Color begeClaro = Color(0xFFF7F2E8);
  static const Color fundoEscuro = Color(0xFF121A14);
  static const Color superficieEscura = Color(0xFF202B23);
  static const Color campoEscuro = Color(0xFF29372D);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppThemeController.instance,
      builder: (context, child) {
        final modo = AppThemeController.instance.themeMode;

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'AgroPlant',
          themeMode: modo,
          routerConfig: appRouter,

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: bege,
            colorScheme: ColorScheme.fromSeed(
              seedColor: verde,
              primary: verde,
              secondary: verdeDetalhe,
              surface: Colors.white,
              brightness: Brightness.light,
            ),
            textTheme: ThemeData.light().textTheme.apply(
              bodyColor: verde,
              displayColor: verde,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: verde,
              elevation: 0,
              centerTitle: false,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 3,
              shadowColor: verde.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: begeClaro,
              labelStyle: const TextStyle(color: verde),
              hintStyle: const TextStyle(
                color: Color(0xFF62594B),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: bege),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: bege),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: verde,
                  width: 2,
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: verde,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? verde
                    : Colors.white;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? verdeDetalhe
                    : bege;
              }),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: begeClaro,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: verde,
              contentTextStyle: TextStyle(
                color: Colors.white,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: fundoEscuro,
            colorScheme: ColorScheme.fromSeed(
              seedColor: verdeDetalhe,
              primary: verdeDetalhe,
              secondary: bege,
              surface: superficieEscura,
              brightness: Brightness.dark,
            ),
            textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: superficieEscura,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
            ),
            cardTheme: CardThemeData(
              color: superficieEscura,
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: campoEscuro,
              labelStyle: const TextStyle(
                color: verdeDetalhe,
              ),
              hintStyle: const TextStyle(
                color: Colors.white60,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: verdeDetalhe,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: verdeDetalhe,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: verdeDetalhe,
                  width: 2,
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeDetalhe,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? verdeDetalhe
                    : Colors.white;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? verde
                    : campoEscuro;
              }),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: superficieEscura,
              surfaceTintColor: Colors.transparent,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              contentTextStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: verde,
              contentTextStyle: TextStyle(
                color: Colors.white,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          ),
        );
      },
    );
  }
}