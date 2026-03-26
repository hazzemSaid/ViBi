import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vibi/features/auth/presentation/providers/auth_providers.dart';
import 'package:vibi/features/inbox/presentation/providers/inbox_providers.dart';

import 'core/routing/app_router.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadEnv();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Push Notifications
  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initialize();

  // Initialize GraphQL client
  // This sets up the GraphQL endpoint with authentication
  GraphQLConfig.initialize();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await setupServiceLocator(prefs);

  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Initialize with your OneSignal App ID
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID'] ?? '');
  // Use this method to prompt for push notifications.
  // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
  OneSignal.Notifications.requestPermission(false);
  runApp(const MyApp());
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit _authCubit;
  late final AuthController _authController;
  late final PendingQuestionsCubit _pendingQuestionsCubit;
  late final AppRouterHolder _routerHolder;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    _authController = getIt<AuthController>();
    _pendingQuestionsCubit = getIt<PendingQuestionsCubit>();
    _routerHolder = AppRouterHolder(createAppRouter(_authCubit));
  }

  @override
  void dispose() {
    _routerHolder.router.dispose();
    _authCubit.close();
    _authController.close();
    _pendingQuestionsCubit.close();
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
      ],
      child: MaterialApp.router(
        title: 'ViBi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: _routerHolder.router,
      ),
    );
  }
}

class AppRouterHolder {
  AppRouterHolder(this.router);
  final GoRouter router;
}
