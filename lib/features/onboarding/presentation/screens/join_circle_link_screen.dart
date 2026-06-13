import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/fade_route.dart';
import '../bloc/onboarding_cubit.dart';
import '../widgets/onboarding_widgets.dart';
import 'package:guardian/features/home/presentation/screens/home_screen.dart';

class JoinCircleLinkScreen extends StatefulWidget {
  const JoinCircleLinkScreen({super.key});

  @override
  State<JoinCircleLinkScreen> createState() => _JoinCircleLinkScreenState();
}

class _JoinCircleLinkScreenState extends State<JoinCircleLinkScreen> {
  final TextEditingController _linkController = TextEditingController();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _linkController.text = clipboardData.text!;
      });
    }
  }

  void _onJoinLink() {
    final link = _linkController.text.trim();
    if (link.isNotEmpty) {
      // Extract code from link if possible (e.g. wa.me/guardian/abcd -> abcd)
      String code = link;
      if (link.contains('/')) {
        code = link.split('/').last;
      }
      context.read<OnboardingCubit>().joinCircle(code.toUpperCase());
      Navigator.of(context).pushAndRemoveUntil(
        FadeRoute(page: const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

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
              // Shake Icon in circular container at the top
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
                title: "Join with a link",
                subtitle: "Paste the circle invitation link to join automatically.",
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OnboardingInputField(
                      hintText: "e.g. wa.me/guardian/grd-code",
                      controller: _linkController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFF3F3F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.content_paste,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      onPressed: _pasteFromClipboard,
                      tooltip: "Paste link",
                    ),
                  ),
                ],
              ),


              // map-image.png centralized as the bottom graphic
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.08,
                      vertical: 8,
                    ),
                    child: Image.asset(
                      AppAssets.mapImage,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  ),
                ),
              ),

              PrimaryButton(
                text: "JOIN VIA LINK",
                onPressed: _onJoinLink,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
