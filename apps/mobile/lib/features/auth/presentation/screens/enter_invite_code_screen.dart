import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/onboarding_top_icon.dart';
import '../widgets/youre_in_sheet.dart';

class EnterInviteCodeScreen extends StatefulWidget {
  const EnterInviteCodeScreen({super.key});

  @override
  State<EnterInviteCodeScreen> createState() => _EnterInviteCodeScreenState();
}

class _EnterInviteCodeScreenState extends State<EnterInviteCodeScreen> {
  final FocusNode _fn1 = FocusNode();
  final FocusNode _fn2 = FocusNode();
  final FocusNode _fn3 = FocusNode();
  final FocusNode _fn4 = FocusNode();

  final TextEditingController _c1 = TextEditingController();
  final TextEditingController _c2 = TextEditingController();
  final TextEditingController _c3 = TextEditingController();
  final TextEditingController _c4 = TextEditingController();

  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _c1.addListener(_onCodeChanged);
    _c2.addListener(_onCodeChanged);
    _c3.addListener(_onCodeChanged);
    _c4.addListener(_onCodeChanged);
  }

  void _onCodeChanged() {
    if (_c1.text.length == 1 && _fn1.hasFocus) _fn2.requestFocus();
    if (_c2.text.length == 1 && _fn2.hasFocus) _fn3.requestFocus();
    if (_c3.text.length == 1 && _fn3.hasFocus) _fn4.requestFocus();

    setState(() {
      _canSubmit = _c1.text.length == 1 &&
          _c2.text.length == 1 &&
          _c3.text.length == 1 &&
          _c4.text.length == 1;
    });
  }

  @override
  void dispose() {
    _fn1.dispose();
    _fn2.dispose();
    _fn3.dispose();
    _fn4.dispose();
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    _c4.dispose();
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

    return BlocListener<AuthBloc, AuthState>(
      bloc: locator<AuthBloc>(),
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCodeBox(context, _c1, _fn1, isDark),
                          _buildCodeBox(context, _c2, _fn2, isDark),
                          _buildCodeBox(context, _c3, _fn3, isDark),
                          _buildCodeBox(context, _c4, _fn4, isDark),
                        ],
                      ),

                      SizedBox(height: AdaptiveLayout.h(context, 32)),

                      BlocBuilder<AuthBloc, AuthState>(
                        bloc: locator<AuthBloc>(),
                        builder: (context, state) {
                          final isLoading = state.status == AuthStatus.loading;
                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: (_canSubmit && !isLoading)
                                  ? () {
                                      final fullCode = "${_c1.text}${_c2.text}${_c3.text}${_c4.text}";
                                      locator<AuthBloc>().add(SubmitInviteCode(fullCode));
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
                          onTap: () => locator<AuthBloc>().add(const NavigateToPasteLink()),
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

  Widget _buildCodeBox(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    bool isDark,
  ) {
    return Container(
      width: AdaptiveLayout.w(context, 60),
      height: AdaptiveLayout.h(context, 54),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF3F3F6),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
        ),
      ),
    );
  }
}
