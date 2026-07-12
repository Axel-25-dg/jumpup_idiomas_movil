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

  // UI Settings
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
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

        // ── go_router ────────────────────────────────────────────────────
        routerConfig: buildAppRouter(ref),
      ),
    );
  }
}