import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/fade_route.dart';
import '../bloc/onboarding_cubit.dart';
import '../widgets/onboarding_widgets.dart';
import 'location_permission_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_nameController.text.trim().isNotEmpty) {
      context.read<OnboardingCubit>().updateUsername(_nameController.text.trim());
    }
    Navigator.of(context).push(
      FadeRoute(page: const LocationPermissionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Push title text down (marginalise it)
                          SizedBox(height: size.height * 0.04),
                          const OnboardingTitleHeader(
                            title: "Setting up your profile!",
                            subtitle: "What should we call you?",
                          ),
                          const SizedBox(height: 24),
                          OnboardingInputField(
                            hintText: "e.g. John",
                            controller: _nameController,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Those who know you can see you.",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? Colors.white38 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      
                      // Bottom image & Buttons section
                      Column(
                        children: [
                          const SizedBox(height: 32),
                          // bottom-design.png center aligned and adaptive
                          Center(
                            child: Opacity(
                              opacity: 0.9,
                              child: Image.asset(
                                AppAssets.bottomDesign,
                                width: size.width * 0.6,
                                height: size.height * 0.22,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const SizedBox(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          PrimaryButton(
                            text: "Continue",
                            onPressed: _onContinue,
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: SecondaryTextButton(
                              text: "Skip for now",
                              onPressed: _onContinue,
                            ),
                          ),
                          const SizedBox(height: 16),
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
    );
  }
}
