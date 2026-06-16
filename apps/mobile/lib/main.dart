import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/bloc/app_bloc_observer.dart';
import 'package:guardian/core/theme/app_theme.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardian/features/journey/presentation/bloc/journey_bloc.dart';
import 'package:guardian/features/auth/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the Bloc Observer to monitor all blocs
  Bloc.observer = AppBlocObserver();

  // Initialize dependency injection
  await initDependencies();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const GuardianApp());
}

class GuardianApp extends StatelessWidget {
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<JourneyBloc>(create: (context) => JourneyBloc()),
      ],
      child: MaterialApp(
        title: 'Guardian',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
