import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/otp_bottom_sheet.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  StreamSubscription<AuthState>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = locator<AuthBloc>().stream.listen((state) {
      if (!mounted) return;
      if (state.status == AuthStatus.failure && state.errorMessage != null) {
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
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        locator<AuthBloc>().add(const NavigateBack());
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Background Ellipses (hidden on keyboard)
              _buildBackgroundEllipses(context, isKeyboardOpen),

              // 2. Main Content
              Column(
                children: [
                  // Spacer that adjusts based on keyboard to keep title visible
                  SizedBox(height: isKeyboardOpen ? 20 : 70),

                  // Title text
                  Text(
                    "Let's get you\nverified",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: AdaptiveLayout.sp(context, 34),
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),

                  SizedBox(height: isKeyboardOpen ? 10 : 15),

                  // Expanded area for the zoomed woman background (hidden on keyboard to prevent overflow)
                  Expanded(
                    child: isKeyboardOpen
                        ? const SizedBox()
                        : Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: 0, // Pushed up towards her head length
                                child: Image.asset(
                                  AppAssets.womanBackground,
                                  height: AdaptiveLayout.h(context, 370), // Zoomed very well
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                  ),

                  // Floating bottom card remains in the same place at the bottom of the Column
                  const OtpBottomSheet(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundEllipses(BuildContext context, bool isKeyboardOpen) {
    if (isKeyboardOpen) return const SizedBox();
    return Stack(
      children: [
        Positioned(
          top: AdaptiveLayout.h(context, 20),
          left: AdaptiveLayout.w(context, 20),
          child: Image.asset(
            AppAssets.ellipse1,
            width: 40,
            opacity: const AlwaysStoppedAnimation(0.6),
          ),
        ),
        Positioned(
          top: AdaptiveLayout.h(context, 100),
          right: AdaptiveLayout.w(context, 30),
          child: Image.asset(
            AppAssets.ellipse2,
            width: 30,
            opacity: const AlwaysStoppedAnimation(0.5),
          ),
        ),
        Positioned(
          top: AdaptiveLayout.h(context, 250),
          left: AdaptiveLayout.w(context, 10),
          child: Image.asset(
            AppAssets.ellipse3,
            width: 50,
            opacity: const AlwaysStoppedAnimation(0.4),
          ),
        ),
        Positioned(
          top: AdaptiveLayout.h(context, 350),
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
