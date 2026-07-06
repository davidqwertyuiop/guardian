# main.dart

* **File Path:** `apps/mobile/lib/main.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guardian/core/services/notification_service.dart';
import 'package:guardian/core/services/background_trigger_service.dart';
import 'export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set the Bloc Observer to monitor all blocs
  Bloc.observer = AppBlocObserver();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

class GuardianApp extends StatelessWidget {
  final AuthStep initialStep;
  const GuardianApp({super.key, required this.initialStep});

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
        RepositoryProvider<FirebaseAuthService>(
          create: (context) => FirebaseAuthService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(initialStep: initialStep)..add(const AppStarted()),
          ),
          BlocProvider<JourneyBloc>(create: (context) => JourneyBloc()),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(authBloc: context.read<AuthBloc>()),
          ),
          BlocProvider<SettingsBloc>(create: (context) => SettingsBloc()),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
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
              home: homeScreen,
            );
          },
        ),
      ),
    );
  }
}

```
