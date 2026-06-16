import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/circle_ready_sheet.dart';
import '../widgets/onboarding_top_icon.dart';

class NameCircleScreen extends StatefulWidget {
  const NameCircleScreen({super.key});

  @override
  State<NameCircleScreen> createState() => _NameCircleScreenState();
}

class _NameCircleScreenState extends State<NameCircleScreen> {
  final TextEditingController _controller = TextEditingController(text: 'Home');
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      _isValid = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showCircleReadySheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const CircleReadySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocListener<AuthBloc, AuthState>(
      bloc: locator<AuthBloc>(),
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.step != current.step,
      listener: (context, state) {
        if (state.step == AuthStep.nameCircle && state.status == AuthStatus.success) {
          _showCircleReadySheet();
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          locator<AuthBloc>().add(const NavigateBack());
        },
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              // Enlarged adaptive bottom image
              if (!isKeyboardOpen)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    AppAssets.logo,
                    height: AdaptiveLayout.h(context, 260),
                    fit: BoxFit.contain,
                  ),
                ),

              // Content
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AdaptiveLayout.padding(context, 24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: statusBarHeight + 20),

                      // Top shake icon
                      OnboardingTopIcon(isDark: isDark),

                      SizedBox(height: AdaptiveLayout.h(context, 24)),

                      // Title
                      Text(
                        "Name your circle",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AdaptiveLayout.sp(context, 32),
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      SizedBox(height: AdaptiveLayout.h(context, 8)),

                      // Subtitle
                      Text(
                        "Something simple works best.",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AdaptiveLayout.sp(context, 15),
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: AdaptiveLayout.h(context, 32)),

                      // Input Field
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF3F3F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                                ),
                              ),
                            ),
                            if (_isValid)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF1A73E8),
                                size: 20,
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: AdaptiveLayout.h(context, 16)),

                      // Create Circle Button
                      BlocBuilder<AuthBloc, AuthState>(
                        bloc: locator<AuthBloc>(),
                        builder: (context, state) {
                          final isLoading = state.status == AuthStatus.loading;
                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isValid && !isLoading
                                  ? () {
                                      locator<AuthBloc>().add(
                                        CreateCircle(_controller.text),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : Colors.black,
                                foregroundColor: isDark ? Colors.black : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: isDark ? Colors.black : Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Create circle",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
