import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/theme/light_theme.dart';
import 'package:jumpup_app/theme/dark_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga variables de entorno (.env bundled como asset)
  await dotenv.load(fileName: '.env');

  // Barra de estado transparente para que el Splash ocupe toda la pantalla
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Orientación vertical únicamente (mobile)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: JumpUpApp()));
}

class JumpUpApp extends ConsumerWidget {
  const JumpUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'JumpUp',
      debugShowCheckedModeBanner: false,

      // ── Tema azul/celeste/blanco ─────────────────────────────────────────
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // respeta la preferencia del SO

      // ── go_router ────────────────────────────────────────────────────────
      routerConfig: buildAppRouter(ref),
    );
  }
}
