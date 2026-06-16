import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class NameCircleScreen extends StatefulWidget {
  const NameCircleScreen({super.key});

  @override
  State<NameCircleScreen> createState() => _NameCircleScreenState();
}

class _NameCircleScreenState extends State<NameCircleScreen> {
  final TextEditingController _controller = TextEditingController(text: 'Home');
  StreamSubscription<AuthState>? _subscription;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);

    _subscription = locator<AuthBloc>().stream.listen((state) {
      if (!mounted) return;
      if (state.step == AuthStep.nameCircle && state.status == AuthStatus.success) {
        _showCircleReadySheet();
      }
    });
  }

  void _validateInput() {
    setState(() {
      _isValid = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _showCircleReadySheet() {
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
              // Blue circle radar icon
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F0FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.album_outlined,
                  color: Color(0xFF1A73E8),
                  size: 32,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                "Your circle is ready 🎉",
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
                "Invite your people so they can see you're safe.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AdaptiveLayout.sp(sheetContext, 14),
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              // Link box
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF3F3F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "wa.me/guardian/abct123",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AdaptiveLayout.sp(sheetContext, 14),
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          const ClipboardData(text: "wa.me/guardian/abct123"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Invite link copied!"),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.copy_rounded,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Button: Share on WhatsApp
              SizedBox(
                width: double.infinity,
                height: 54,
                child: TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF26262B) : const Color(0xFFEBEBEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.green,
                  ),
                  label: Text(
                    "Share on WhatsApp",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Button: Done - I'll invite them later
              SizedBox(
                width: double.infinity,
                height: 54,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    locator<AuthBloc>().add(const CompleteCircleOnboarding());
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Done — I'll invite them later",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: isDark ? Colors.white : Colors.black,
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
                    _buildTopIcon(context, isDark),

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
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isValid
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
                        child: const Text(
                          "Create circle",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
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
}
