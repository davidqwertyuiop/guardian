import 'package:flutter/material.dart';

import 'package:guardian/export.dart';

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
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.read<AuthBloc>().add(const NavigateBack());
      },
      child: BlocListener<AuthBloc, AuthState>(
        bloc: context.read<AuthBloc>(),
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == AuthStatus.failure,
        listener: (context, state) {
          if (state.errorMessage != null &&
              (ModalRoute.of(context)?.isCurrent ?? false)) {
            AuthFeedback.showError(context, state.errorMessage!);
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
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
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Stack(
                          children: [
                            AuthBackgroundEllipses(
                              isKeyboardOpen: isKeyboardOpen,
                            ),
                            Column(
                              children: [
                                SizedBox(height: statusBarHeight),
                                const Spacer(flex: 2),
                                const AvatarCluster(),
                                SizedBox(height: AdaptiveLayout.h(context, 24)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  child: AuthTitle(
                                    text: "Let's get you\nsigned in",
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
      ),
    );
  }
}
