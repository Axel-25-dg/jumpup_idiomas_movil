import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/theme/light_theme.dart';
import 'package:jumpup_app/theme/dark_theme.dart';
import 'package:jumpup_app/presentation/providers/preferences_provider.dart';
import 'package:jumpup_app/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Usar fuentes locales (assets) en vez de descargar desde internet
  GoogleFonts.config.allowRuntimeFetching = false;

  final prefs = await SharedPreferences.getInstance();

  // Carga variables de entorno (.env bundled como asset)
  await dotenv.load(fileName: '.env');

  // Inicializar Firebase — envuelto en try/catch para no bloquear el arranque
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Error al inicializar Firebase: $e');
  }

  // Inicializar notificaciones — solo si Firebase pudo inicializarse
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('NotificationService error: $e');
  }

  // Inicializar Stripe — solo establece la publishable key, NO llama applySettings()
  // en main() para evitar el crash cuando MainActivity no estaba lista.
  // applySettings() se llama después en cada flujo de pago.
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? 'pk_test_PLACEHOLDER';

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

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const JumpUpApp()
    )
  );
}

class JumpUpApp extends ConsumerWidget {
  const JumpUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);

    return MaterialApp.router(
      title: 'JumpUp',
      debugShowCheckedModeBanner: false,

      // ── Localización ───────────────────────────────────────────────
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      locale: Locale(prefs.language),

      // ── Temas ───────────────────────────────────────────────────────
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: prefs.darkMode ? ThemeMode.dark : ThemeMode.light,

      // ── go_router ────────────────────────────────────────────────────────
      routerConfig: buildAppRouter(ref),
    );
  }
}
