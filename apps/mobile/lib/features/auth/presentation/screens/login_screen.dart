import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/avatar_cluster.dart';
import '../widgets/login_bottom_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        locator<AuthBloc>().add(const NavigateBack());
      },
      child: BlocListener<AuthBloc, AuthState>(
        bloc: locator<AuthBloc>(),
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == AuthStatus.failure,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          top: false, // Extend layout under status bar
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Stack(
                      children: [
                        _buildBackgroundEllipses(context),
                        Column(
                          children: [
                            SizedBox(height: statusBarHeight),
                            const Spacer(flex: 2),
                            const AvatarCluster(),
                            SizedBox(height: AdaptiveLayout.h(context, 24)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Text(
                                "Let's get you\nsigned in",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: AdaptiveLayout.sp(context, 32),
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : Colors.black,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const Spacer(flex: 3),
                            const LoginBottomSheet(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildBackgroundEllipses(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned(
          top: statusBarHeight + AdaptiveLayout.h(context, 20),
          left: AdaptiveLayout.w(context, 20),
          child: Image.asset(
            AppAssets.ellipse1,
            width: 40,
            opacity: const AlwaysStoppedAnimation(0.6),
          ),
        ),
        Positioned(
          top: statusBarHeight + AdaptiveLayout.h(context, 100),
          right: AdaptiveLayout.w(context, 30),
          child: Image.asset(
            AppAssets.ellipse2,
            width: 30,
            opacity: const AlwaysStoppedAnimation(0.5),
          ),
        ),
        Positioned(
          top: statusBarHeight + AdaptiveLayout.h(context, 250),
          left: AdaptiveLayout.w(context, 10),
          child: Image.asset(
            AppAssets.ellipse3,
            width: 50,
            opacity: const AlwaysStoppedAnimation(0.4),
          ),
        ),
        Positioned(
          top: statusBarHeight + AdaptiveLayout.h(context, 350),
          right: AdaptiveLayout.w(context, 15),
          child: Image.asset(
            AppAssets.ellipse4,
            width: 45,
            opacity: const AlwaysStoppedAnimation(0.6),
          ),
        ),
      ],
    );
  }
}
