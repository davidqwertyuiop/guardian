import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/bloc/app_bloc_observer.dart';
import 'package:guardian/core/theme/app_theme.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_state.dart';
import 'package:guardian/features/auth/presentation/screens/welcome_screen.dart';
import 'package:guardian/features/home/home.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:guardian/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set the Bloc Observer to monitor all blocs
  Bloc.observer = AppBlocObserver();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependency injection
  await initDependencies();

  // Dispatch AppStarted to initialize the active onboarding/authenticated step
  locator<AuthBloc>().add(const AppStarted());

  // Lock to portrait — landscape causes overflow on all screens.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const GuardianApp());
}

class GuardianApp extends StatelessWidget {
  const GuardianApp({super.key});

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

    return BlocBuilder<AuthBloc, AuthState>(
      bloc: locator<AuthBloc>(),
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
    );
  }
}
