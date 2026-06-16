import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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

  StreamSubscription<AuthState>? _subscription;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _c1.addListener(_onCodeChanged);
    _c2.addListener(_onCodeChanged);
    _c3.addListener(_onCodeChanged);
    _c4.addListener(_onCodeChanged);

    _subscription = locator<AuthBloc>().stream.listen((state) {
      if (!mounted) return;
      if (state.step == AuthStep.enterInviteCode &&
          state.status == AuthStatus.success &&
          !state.isJoiningCircle) {
        _showYoureInSheet();
      }
    });
  }

  void _onCodeChanged() {
    // Auto focus next field
    if (_c1.text.length == 1 && _fn1.hasFocus) {
      _fn2.requestFocus();
    }
    if (_c2.text.length == 1 && _fn2.hasFocus) {
      _fn3.requestFocus();
    }
    if (_c3.text.length == 1 && _fn3.hasFocus) {
      _fn4.requestFocus();
    }

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
    _subscription?.cancel();
    super.dispose();
  }

  void _showYoureInSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16161A) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: 24 + MediaQuery.paddingOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Green circle handshake/key icon
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F4EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.vpn_key_outlined,
                  color: Color(0xFF137333),
                  size: 32,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                "You're in 🤝",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AdaptiveLayout.sp(sheetContext, 22),
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                "You've joined Ngozi's circle. You can now see each other's location.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AdaptiveLayout.sp(sheetContext, 14),
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              // Button: Go to map
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    locator<AuthBloc>().add(const CompleteCircleOnboarding());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Go to map",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.paddingOf(context).top;
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
        body: Stack(
          children: [
            // Bottom line graphic asset (hidden when keyboard is open)
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
                    _buildTopIcon(context, isDark),

                    SizedBox(height: AdaptiveLayout.h(context, 24)),

                    // Title
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

                    // Subtitle
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

                    // Four character input boxes
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

                    // Join Circle Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _canSubmit
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
                        child: const Text(
                          "Join circle",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AdaptiveLayout.h(context, 16)),

                    // Got a link instead? Click link
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
    );
  }

  Widget _buildTopIcon(BuildContext context, bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        AppAssets.shake,
        color: isDark ? Colors.white : Colors.black,
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
