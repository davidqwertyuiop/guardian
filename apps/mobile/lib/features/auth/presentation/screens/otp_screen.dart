import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/otp_bottom_sheet.dart';
import 'package:toastification/toastification.dart';
import 'package:guardian/features/auth/presentation/widgets/shared/auth_shared.dart';
import 'package:guardian/features/auth/presentation/widgets/you_are_in_sheet.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  void _showYouAreInSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const YouAreInSheet(),
    );
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
      child: BlocListener<AuthBloc, AuthState>(
        bloc: locator<AuthBloc>(),
        listenWhen: (previous, current) =>
            previous.status != current.status || previous.step != current.step,
        listener: (context, state) {
          if (state.status == AuthStatus.success &&
              state.step == AuthStep.otp) {
            _showYouAreInSheet(context);
            return;
          }
          if (state.status == AuthStatus.failure &&
              state.errorMessage != null &&
              (ModalRoute.of(context)?.isCurrent ?? false)) {
            if (Theme.of(context).platform == TargetPlatform.iOS) {
              toastification.show(
                context: context,
                style: ToastificationStyle.minimal,
                title: const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                description: Text(
                  state.errorMessage!,
                  softWrap: true,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                alignment: Alignment.topCenter,
                autoCloseDuration: const Duration(seconds: 4),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              );
            } else {
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
          }
        },
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Stack(
              children: [
                // 1. Background Ellipses (hidden on keyboard)
                AuthBackgroundEllipses(isKeyboardOpen: isKeyboardOpen),

                // 2. Main Content
                Column(
                  children: [
                    // Spacer that adjusts based on keyboard to keep title visible
                    SizedBox(height: isKeyboardOpen ? 20 : 70),

                    // Title text
                    const AuthTitle(text: "Let's get you\nverified"),

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
                                    height: AdaptiveLayout.h(
                                      context,
                                      370,
                                    ), // Zoomed very well
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
      ),
    );
  }
}
