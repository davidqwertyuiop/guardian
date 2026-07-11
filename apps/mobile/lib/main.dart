import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:guardian/core/services/notification_service.dart';
import 'package:guardian/core/services/background_trigger_service.dart';
import 'package:guardian/features/notifications/data/notification_repository.dart';
import 'package:guardian/features/notifications/presentation/bloc/notification_bloc.dart';
import 'export.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:guardian/core/services/deep_link_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set the Bloc Observer to monitor all blocs
  Bloc.observer = AppBlocObserver();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Log App Open event to Firebase Analytics
  await FirebaseAnalytics.instance.logAppOpen();

  // Initialize Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize Aptabase
  await Aptabase.init(dotenv.env['APTABASE_APP_KEY'] ?? '');

  // Prefer the latest Android Maps renderer before any GoogleMap is created.
  await _initializeAndroidMapRenderer();

  // Initialize notifications
  await NotificationService.initialize();

  // Start background gesture trigger listener
  BackgroundTriggerService().startListening();

  // Initialize dependency injection and get initial auth step
  final initialStep = await initDependencies();

  // Lock to portrait — landscape causes overflow on all screens.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(GuardianApp(initialStep: initialStep));
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
  bool _deepLinkInitialized = false;

  @override
  Widget build(BuildContext context) {
    final brightness = PlatformDispatcher.instance.platformBrightness;
    final isDark = brightness == Brightness.dark;

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
                AuthBloc(initialStep: widget.initialStep)..add(const AppStarted()),
          ),
          BlocProvider<JourneyBloc>(create: (context) => JourneyBloc()),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(authBloc: context.read<AuthBloc>()),
          ),
          BlocProvider<SettingsBloc>(create: (context) => SettingsBloc()),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(
              repository: context.read<NotificationRepository>(),
            )..add(const NotificationsStarted()),
          ),
        ],
        child: Builder(
          builder: (context) {
            if (!_deepLinkInitialized) {
              DeepLinkService().initialize(context.read<AuthBloc>());
              _deepLinkInitialized = true;
            }
            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final Widget homeScreen = (state.step == AuthStep.completed)
                    ? const HomeScreen()
                    : const WelcomeScreen();

                return MaterialApp(
                  title: 'Guardian',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: ThemeMode.system,
                  debugShowCheckedModeBanner: false,
                  navigatorObservers: [
                    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
                  ],
                  home: homeScreen,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
