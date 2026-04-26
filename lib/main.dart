import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vibi/features/auth/presentation/providers/auth_providers.dart';
import 'package:vibi/features/inbox/presentation/view/pending_questions_cubit/pending_questions_cubit.dart';

import 'core/routing/app_router.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureImageMemoryCache();

  await _loadEnv();
  await _initializeHive();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Initialize Firebase — gracefully handles missing config (Appetizer / CI without secrets).
  await _initFirebase();

  // Initialize GraphQL client
  // This sets up the GraphQL endpoint with authentication
  await GraphQLConfig.initialize();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await setupServiceLocator(prefs);

  // Initialize Push Notifications via Service Locator
  await getIt<PushNotificationService>().initialize();

  // Enable verbose logging for debugging (rem  ove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Initialize with your OneSignal App ID
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID'] ?? '');
  // Use this method to prompt for push notifications.
  // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
  OneSignal.Notifications.requestPermission(false);
  runApp(const MyApp());
}

Future<void> _initializeHive() async {
  final appSupportDir = await getApplicationSupportDirectory();
  Hive.init(appSupportDir.path);
}

void _configureImageMemoryCache() {
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 120;
  imageCache.maximumSizeBytes = 80 << 20; // 80 MB
}

Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
    return;
  } catch (_) {
    // Fall back to .env.example in CI/dev environments where .env is not present.
  }

  try {
    await dotenv.load(fileName: '.env.example');
    return;
  } catch (_) {
    // Neither file found — initialize with an empty map to prevent NotInitializedError.
  }

  // Final fallback: load with isOptional so dotenv initializes even without a file.
  await dotenv.load(isOptional: true);
}

/// Initializes Firebase with a graceful multi-tier fallback:
///   1. No-options init — Firebase SDK reads GoogleService-Info.plist / google-services.json natively.
///   2. Dotenv options — if the native file is absent, try building options from .env vars.
///   3. Silent catch — if all else fails, continue without Firebase (Appetizer / CI without secrets).
Future<void> _initFirebase() async {
  // Tier 1: let Firebase find the native config file automatically.
  try {
    await Firebase.initializeApp();
    return;
  } catch (_) {
    // Native file missing or invalid — try dotenv options.
  }

  // Tier 2: use env-var-driven options (requires .env to be loaded with Firebase keys).
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return;
  } catch (_) {
    // Dotenv vars missing — continue without Firebase.
  }

  // Tier 3: Firebase is not available in this environment (e.g. Appetizer preview without secrets).
  debugPrint('[Firebase] Skipping Firebase init — no config available.');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final AuthCubit _authCubit;
  late final AuthController _authController;
  late final PendingQuestionsCubit _pendingQuestionsCubit;
  late final ThemeCubit _themeCubit;
  late final AppRouterHolder _routerHolder;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authCubit = getIt<AuthCubit>();
    _authController = getIt<AuthController>();
    _pendingQuestionsCubit = getIt<PendingQuestionsCubit>();
    _themeCubit = getIt<ThemeCubit>();
    _routerHolder = AppRouterHolder(createAppRouter(_authCubit));
  }

  @override
  void didHaveMemoryPressure() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _routerHolder.router.dispose();
    _authCubit.close();
    _authController.close();
    _pendingQuestionsCubit.close();
    _themeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<AuthController>.value(value: _authController),
        BlocProvider<PendingQuestionsCubit>.value(
          value: _pendingQuestionsCubit,
        ),
        BlocProvider<ThemeCubit>.value(value: _themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'ViBi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: _routerHolder.router,
          );
        },
      ),
    );
  }
}

class AppRouterHolder {
  AppRouterHolder(this.router);
  final GoRouter router;
}
