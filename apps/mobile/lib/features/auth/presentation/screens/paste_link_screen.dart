import 'package:flutter/material.dart';

import 'package:guardian/export.dart';
class PasteLinkScreen extends StatefulWidget {
  const PasteLinkScreen({super.key});

  @override
  State<PasteLinkScreen> createState() => _PasteLinkScreenState();
}

class _PasteLinkScreenState extends State<PasteLinkScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() => _controller.text = data!.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
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
            // Bottom decorative line asset (hidden when keyboard is open)
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

                    // Top shake icon
                    OnboardingTopIcon(isDark: isDark),

                    SizedBox(height: AdaptiveLayout.h(context, 24)),

                    // Title
                    Text(
                      "Paste your invite link",
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
                      "Paste the link you received and we'll add you to the circle.",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AdaptiveLayout.sp(context, 15),
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: AdaptiveLayout.h(context, 32)),

                    // Link input field with paste button
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E22)
                            : const Color(0xFFF3F3F6),
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
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'wa.me/guardian/...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.grey.shade400,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _pasteFromClipboard,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Paste",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AdaptiveLayout.h(context, 24)),

                    // Join via Link button
                    BlocBuilder<AuthBloc, AuthState>(
                      bloc: context.read<AuthBloc>(),
                      builder: (context, state) {
                        final isLoading = state.status == AuthStatus.loading;
                        return SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.read<AuthBloc>().add(
                                      SubmitInviteLink(_controller.text),
                                    );
                                  },
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
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: isDark
                                          ? Colors.black
                                          : Colors.white,
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

                    // Enter code instead
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // Let the PopScope handle the bloc state sync to avoid double pop
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          "Enter a code instead",
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
}
