import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import 'package:guardian/core/utils/fade_route.dart';
import 'package:guardian/features/location/presentation/screens/live_map_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/register_screen_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _completeOnboarding() {
    context.read<AuthBloc>().add(CompleteProfile(_nameController.text));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == AuthStatus.profileCompleted) {
            Navigator.of(context).pushAndRemoveUntil(
              FadeRoute(page: const LiveMapScreen()),
              (route) => false,
            );
          } else if (state.status == AuthStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
            );
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.all(AdaptiveLayout.padding(context, 24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AdaptiveLayout.h(context, 20)),
                          Text("Setting up your profile!",
                              style: GoogleFonts.outfit(
                                  fontSize: AdaptiveLayout.sp(context, 28),
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black)),
                          SizedBox(height: AdaptiveLayout.h(context, 24)),
                          Text("What should we call you?",
                              style: GoogleFonts.inter(
                                  fontSize: AdaptiveLayout.sp(context, 15),
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: AdaptiveLayout.h(context, 8)),
                          RegisterNameInput(controller: _nameController),
                          const SizedBox(height: 4),
                          Text("This is what your circle will see.",
                              style: GoogleFonts.inter(fontSize: AdaptiveLayout.sp(context, 12), color: Colors.grey)),
                          const Spacer(),
                          const CircleCreatureImage(),
                          const Spacer(),
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
      ),
    );
  }
}
