# enter_invite_code_screen.dart

* **File Path:** `apps/mobile/lib/features/circles/presentation/screens/enter_invite_code_screen.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';

import 'package:pinput/pinput.dart';

import '../widgets/youre_in_sheet.dart';
import 'package:guardian/export.dart';
class EnterInviteCodeScreen extends StatefulWidget {
  const EnterInviteCodeScreen({super.key});

  @override
  State<EnterInviteCodeScreen> createState() => _EnterInviteCodeScreenState();
}

class _EnterInviteCodeScreenState extends State<EnterInviteCodeScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(() {
      setState(() => _canSubmit = _pinController.text.length == 4);
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _showYoureInSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const YoureInSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    final fillColor = isDark
        ? const Color(0xFF1E1E22)
        : const Color(0xFFF3F3F6);
    final textColor = isDark ? Colors.white : Colors.black;
    final focusBorderColor = isDark ? Colors.white38 : const Color(0xFF1A73E8);

    final defaultPinTheme = PinTheme(
      width: 64,
      height: 64,
      textStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 1.0,
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: focusBorderColor, width: 1.5),
      borderRadius: BorderRadius.circular(16),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFD0D0D8),
          width: 1,
        ),
      ),
    );

    return BlocListener<AuthBloc, AuthState>(
      bloc: context.read<AuthBloc>(),
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.step != current.step,
      listener: (context, state) {
        if (state.step == AuthStep.enterInviteCode &&
            state.status == AuthStatus.success &&
            !state.isJoiningCircle) {
          _showYoureInSheet();
        }
      },
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            context.read<AuthBloc>().add(const NavigateBack(isNativePop: true));
          }
        },
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              if (!isKeyboardOpen)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    AppAssets.line6,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.bottomCenter,
                  ),
                ),

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

                      OnboardingTopIcon(isDark: isDark),

                      SizedBox(height: AdaptiveLayout.h(context, 24)),

                      Text(
                        "Enter your invite code",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AdaptiveLayout.sp(context, 32),
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      SizedBox(height: AdaptiveLayout.h(context, 8)),

                      Text(
                        "Ask the person who invited you for their 4-character code.",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AdaptiveLayout.sp(context, 15),
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: AdaptiveLayout.h(context, 32)),

                      // ── Pinput invite code input ──────────────────────────
                      Center(
                        child: Pinput(
                          length: 4,
                          controller: _pinController,
                          focusNode: _pinFocusNode,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          showCursor: true,
                          cursor: Container(
                            width: 2,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF1A73E8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          closeKeyboardWhenCompleted: true,
                          obscureText: true,
                          obscuringWidget: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white70 : Colors.black87,
                              shape: BoxShape.circle,
                            ),
                          ),
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          onCompleted: (code) {
                            context.read<AuthBloc>().add(SubmitInviteCode(code));
                          },
                        ),
                      ),

                      // ─────────────────────────────────────────────────────
                      SizedBox(height: AdaptiveLayout.h(context, 32)),

                      BlocBuilder<AuthBloc, AuthState>(
                        bloc: context.read<AuthBloc>(),
                        builder: (context, state) {
                          final isLoading = state.status == AuthStatus.loading;
                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: (_canSubmit && !isLoading)
                                  ? () {
                                      context.read<AuthBloc>().add(
                                        SubmitInviteCode(_pinController.text),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.white
                                    : Colors.black,
                                foregroundColor: isDark
                                    ? Colors.black
                                    : Colors.white,
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
                                        color: isDark
                                            ? Colors.black
                                            : Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Join circle",
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

                      SizedBox(height: AdaptiveLayout.h(context, 16)),

                      Center(
                        child: GestureDetector(
                          onTap: () => context.read<AuthBloc>().add(
                            const NavigateToPasteLink(),
                          ),
                          child: Text(
                            "Got a link instead? Tap here",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: AdaptiveLayout.sp(context, 14),
                              color: const Color(0xFF1A73E8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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

```
