import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/theme/light_theme.dart';
import 'package:jumpup_app/theme/dark_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:jumpup_app/presentation/providers/preferences_provider.dart';
import 'package:jumpup_app/services/notification_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:jumpup_app/presentation/widgets/gamification/gamification_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Stripe setup
  await dotenv.load(fileName: '.env');
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  await Stripe.instance.applySettings();

  final prefs = await SharedPreferences.getInstance();

  // Inicializar Firebase
  try {
    await Firebase.initializeApp();
    await FirebaseAnalytics.instance.logAppOpen();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Inicializar notificaciones
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('NotificationService error: $e');
  }

  // Capturar errores de Flutter (Pantalla Roja)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F0E1A),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Algo salió mal',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  details.exception.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => FirebaseCrashlytics.instance.recordFlutterError(details),
                  child: const Text('Reportar error', style: TextStyle(color: Color(0xFF00E5FF))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  // UI Settings
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

  // Inicializar Sentry y arrancar App
  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const JumpUpApp(),
      ),
    ),
  );
}

class JumpUpApp extends ConsumerWidget {
  const JumpUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);

    return GamificationOverlay(
      child: MaterialApp.router(
        title: 'JumpUp',
        debugShowCheckedModeBanner: false,
        
        // Avoid initial white screen
        color: const Color(0xFF0F111A),

        // ─── Localization ─────────────────────────────────────────────
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
        ],
        locale: Locale(prefs.language),

        // ─── Themes ────────────────────────────────────────────────────
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: prefs.darkMode ? ThemeMode.dark : ThemeMode.light,

        // ─── go_router ────────────────────────────────────────────────────
        routerConfig: buildAppRouter(ref),
      ),
    );
  }
}