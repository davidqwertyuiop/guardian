import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/fade_route.dart';
import '../bloc/onboarding_cubit.dart';
import '../widgets/onboarding_widgets.dart';
import 'package:guardian/features/home/presentation/screens/home_screen.dart';
import 'join_circle_link_screen.dart';

class JoinCircleScreen extends StatefulWidget {
  const JoinCircleScreen({super.key});

  @override
  State<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends State<JoinCircleScreen> {
  final List<TextEditingController> _codeControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _codeControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onJoin() {
    final code = _codeControllers.map((c) => c.text.trim()).join();
    if (code.length == 4) {
      context.read<OnboardingCubit>().joinCircle(code);
      Navigator.of(context).pushAndRemoveUntil(
        FadeRoute(page: const HomeScreen()),
        (route) => false,
      );
    }
  }

  void _onChanged(int index, String val) {
    if (val.isNotEmpty) {
      if (val.length > 1) {
        // Handle paste
        final pastedText = val.toUpperCase();
        for (int i = 0; i < 4 - index && i < pastedText.length; i++) {
          _codeControllers[index + i].text = pastedText[i];
        }
        FocusScope.of(context).unfocus();
        return;
      }
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
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
                title: "Enter your invite code",
                subtitle: "Ask the person who invited you for their 4-character code.",
              ),
              const SizedBox(height: 32),
              // 4 Code input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildCodeBox(index, isDark)),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      FadeRoute(page: const JoinCircleLinkScreen()),
                    );
                  },
                  child: Text(
                    "Got a link instead? Tap here",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF7C60FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // map-image.png centralized, contained — replaces old JoinCardPainter
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
                text: "JOIN CIRCLE",
                onPressed: _onJoin,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeBox(int index, bool isDark) {
    return Container(
      width: 52,
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C24) : const Color(0xFFF3F3F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(2), // Allow 2 characters for paste handling
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) => _onChanged(index, val),
      ),
    );
  }
}
