import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:guardian/core/services/notification_service.dart';
import 'package:guardian/core/services/telemetry_service.dart';
import 'package:guardian/features/notifications/data/notification_repository.dart';
import 'package:guardian/features/notifications/presentation/bloc/notification_bloc.dart';
import 'export.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:guardian/core/services/deep_link_service.dart';

import 'package:guardian/core/theme/smooth_page_route.dart';

void main() {
  runZonedGuarded(_bootstrap, (error, stackTrace) {
    unawaited(
      TelemetryService.recordError(
        error,
        stackTrace,
        reason: 'Uncaught zone error',
        fatal: true,
      ),
    );
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set the Bloc Observer to monitor all blocs
  Bloc.observer = AppBlocObserver();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load environment variables safely
  try {
    await dotenv.load(fileName: ".env");
  } catch (error, stackTrace) {
    // If .env is missing or empty (e.g. on CI/CD build environments), log it without crashing
    debugPrint('Warning: .env file could not be loaded: $error');
    await TelemetryService.recordError(
      error,
      stackTrace,
      reason: '.env load failed',
    );
  }

  await TelemetryService.initialize(
    aptabaseAppKey: dotenv.env['APTABASE_APP_KEY'] ?? '',
  );

  // Register storage and repositories before any startup service can use
  // ApiService/TokenManager (notification token upload does exactly that).
  final initialStep = await initDependencies();

  // Log App Open event to Firebase Analytics
  try {
    await FirebaseAnalytics.instance.logAppOpen();
    await TelemetryService.trackEvent('app_open');
  } catch (error, stackTrace) {
    debugPrint('Warning: Firebase Analytics failed to log app open: $error');
    await TelemetryService.recordError(
      error,
      stackTrace,
      reason: 'Firebase Analytics logAppOpen failed',
    );
  }

  // Prefer the latest Android Maps renderer before any GoogleMap is created.
  await _initializeAndroidMapRenderer();

  await _initializeNotificationsSafely();

  // Lock to portrait — landscape causes overflow on all screens.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(GuardianApp(initialStep: initialStep));
}

Future<void> _initializeNotificationsSafely() async {
  // Permission is requested later from the onboarding notification screen.
  // Startup should still reach runApp if native notification setup fails.
  try {
    await NotificationService.initialize();
  } catch (error, stackTrace) {
    debugPrint('Warning: notification initialization failed: $error');
    await TelemetryService.recordError(
      error,
      stackTrace,
      reason: 'Notification initialization failed',
    );
  }
}

Future<void> _initializeAndroidMapRenderer() async {
  final mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is! GoogleMapsFlutterAndroid) return;

  try {
    await mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
  } catch (error, stackTrace) {
    log(
      'Failed to initialize latest Android Google Maps renderer.',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

class GuardianApp extends StatefulWidget {
  final AuthStep initialStep;
  const GuardianApp({super.key, required this.initialStep});

  @override
  State<GuardianApp> createState() => _GuardianAppState();
}

class _GuardianAppState extends State<GuardianApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _deepLinkInitialized = false;
  late bool _isHomeVisible;

  @override
  void initState() {
    super.initState();
    _isHomeVisible = widget.initialStep == AuthStep.completed;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = PlatformDispatcher.instance.platformBrightness;
    final isDark = brightness == Brightness.dark;
    final navigatorObservers = Firebase.apps.isNotEmpty
        ? <NavigatorObserver>[
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
          ]
        : <NavigatorObserver>[];

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<NotificationRepository>(
          create: (context) => locator<NotificationRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(initialStep: widget.initialStep)
                  ..add(const AppStarted()),
          ),
          BlocProvider<JourneyBloc>(create: (context) => JourneyBloc()),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(authBloc: context.read<AuthBloc>()),
          ),
          BlocProvider<SettingsBloc>(create: (context) => SettingsBloc()),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(
              repository: context.read<NotificationRepository>(),
            ),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) {
            if (previous.step == current.step) return false;
            return current.step == AuthStep.completed ||
                previous.step == AuthStep.completed;
          },
          listener: (context, state) {
            if (state.step == AuthStep.completed && !_isHomeVisible) {
              _isHomeVisible = true;
              _navigatorKey.currentState?.pushAndRemoveUntil(
                SmoothPageRoute(child: const HomeScreen()),
                (route) => false,
              );
            } else if (state.step != AuthStep.completed && _isHomeVisible) {
              _isHomeVisible = false;
              _navigatorKey.currentState?.pushAndRemoveUntil(
                SmoothPageRoute(child: const WelcomeScreen()),
                (route) => false,
              );
            }
          },
          child: Builder(
            builder: (context) {
              if (!_deepLinkInitialized) {
                DeepLinkService().initialize(context.read<AuthBloc>());
                _deepLinkInitialized = true;
              }
              final Widget initialHome =
                  (widget.initialStep == AuthStep.completed)
                  ? const HomeScreen()
                  : const WelcomeScreen();

              return MaterialApp(
                navigatorKey: _navigatorKey,
                title: 'Guardian',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.system,
                debugShowCheckedModeBanner: false,
                navigatorObservers: navigatorObservers,
                home: initialHome,
              );
            },
          ),
        ),
      ),
    );
  }
}
