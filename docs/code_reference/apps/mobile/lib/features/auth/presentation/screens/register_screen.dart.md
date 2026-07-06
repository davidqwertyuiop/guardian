# register_screen.dart

* **File Path:** `apps/mobile/lib/features/auth/presentation/screens/register_screen.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';

import 'package:guardian/export.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = context.read<AuthBloc>();
  }

  void _completeOnboarding() {
    _authBloc.add(CompleteProfile(_nameController.text));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          if (state.errorMessage != null) {
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
        },
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              // Map Intro background image covering the whole bottom screen adaptively
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  AppAssets.mapIntro,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                ),
              ),
              SafeArea(
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
                          child: Padding(
                            padding: EdgeInsets.all(
                              AdaptiveLayout.padding(context, 24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.paddingOf(context).top + 10.0,
                                ),
                                Text(
                                  "Setting up your profile!",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: AdaptiveLayout.sp(context, 28),
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                SizedBox(height: AdaptiveLayout.h(context, 20)),
                                Text(
                                  "What should we call you?",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: AdaptiveLayout.sp(context, 15),
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: AdaptiveLayout.h(context, 8)),
                                RegisterNameInput(controller: _nameController),
                                const SizedBox(height: 4),
                                Text(
                                  "This is what your circle will see.",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: AdaptiveLayout.sp(context, 12),
                                    color: Colors.grey,
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  height: AdaptiveLayout.h(context, 160),
                                ),
                                RegisterButtons(onPressed: _completeOnboarding),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
