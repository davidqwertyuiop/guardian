import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import 'package:guardian/core/utils/fade_route.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/avatar_cluster.dart';
import '../widgets/login_bottom_sheet.dart';
import 'otp_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == AuthStatus.codeSent) {
            Navigator.of(context).push(FadeRoute(page: const OtpScreen()));
          } else if (state.status == AuthStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
            );
          }
        },
        child: SafeArea(
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
                            const Spacer(flex: 2),
                            const AvatarCluster(),
                            SizedBox(height: AdaptiveLayout.h(context, 24)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text("Let's get you\nsigned in",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: AdaptiveLayout.sp(context, 32),
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : Colors.black, height: 1.1,
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
    );
  }

  Widget _buildBackgroundEllipses(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: AdaptiveLayout.h(context, 20), left: AdaptiveLayout.w(context, 20),
          child: Image.asset(AppAssets.ellipse1, width: 40, opacity: const AlwaysStoppedAnimation(0.6)),
        ),
        Positioned(
          top: AdaptiveLayout.h(context, 100), right: AdaptiveLayout.w(context, 30),
          child: Image.asset(AppAssets.ellipse2, width: 30, opacity: const AlwaysStoppedAnimation(0.5)),
        ),
        Positioned(
          top: AdaptiveLayout.h(context, 250), left: AdaptiveLayout.w(context, 10),
          child: Image.asset(AppAssets.ellipse3, width: 50, opacity: const AlwaysStoppedAnimation(0.4)),
        ),
        Positioned(
          top: AdaptiveLayout.h(context, 350), right: AdaptiveLayout.w(context, 15),
          child: Image.asset(AppAssets.ellipse4, width: 45, opacity: const AlwaysStoppedAnimation(0.6)),
        ),
      ],
    );
  }
}
