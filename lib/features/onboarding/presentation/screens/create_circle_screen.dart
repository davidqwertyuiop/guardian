import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/fade_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/onboarding_cubit.dart';
import '../widgets/onboarding_widgets.dart';
import 'circle_empty_screen.dart';

class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  final TextEditingController _circleNameController = TextEditingController();

  @override
  void dispose() {
    _circleNameController.dispose();
    super.dispose();
  }

  void _onCreate() async {
    final name = _circleNameController.text.trim();
    if (name.isNotEmpty) {
      final cubit = context.read<OnboardingCubit>();
      await cubit.createCircle(name);
      
      // Save invite link to SharedPreferences for CircleEmptyScreen
      final prefs = await SharedPreferences.getInstance();
      final code = cubit.state.circleCode;
      final inviteLink = "wa.me/guardian/${code.toLowerCase()}";
      await prefs.setString('invite_link', inviteLink);

      if (mounted) {
        Navigator.of(context).push(
          FadeRoute(page: const CircleEmptyScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shake Icon in circular container at the top (unified design)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C60FF).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF7C60FF).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Image.asset(
                    AppAssets.shake,
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.circle_notifications,
                      color: Color(0xFF7C60FF),
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const OnboardingTitleHeader(
                title: "Name your circle",
                subtitle: "Something people will search.",
              ),
              const SizedBox(height: 24),
              OnboardingInputField(
                hintText: "e.g. Family",
                controller: _circleNameController,
              ),
              const SizedBox(height: 16),
              
              // map-image.png centralized, padded, not zoomed
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Image.asset(
                      AppAssets.mapImage,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: "Create circle",
                onPressed: _onCreate,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
