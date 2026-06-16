import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import 'otp_input_field.dart';
import 'otp_bottom_sheet_widgets.dart';

class OtpBottomSheet extends StatefulWidget {
  const OtpBottomSheet({super.key});

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _seconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (var c in _controllers) {
      c.addListener(_checkOtpComplete);
    }
  }

  void _startTimer() {
    _seconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted && _seconds > 0) {
        setState(() => _seconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _checkOtpComplete() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 4) {
      context.read<AuthBloc>().add(SubmitVerificationCode(code));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<AuthBloc>().state;
    final masked = maskPhone(state.dialCode, state.phoneNumber);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AdaptiveLayout.padding(context, 20),
        vertical: AdaptiveLayout.padding(context, 16),
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13131A) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(AdaptiveLayout.padding(context, 24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OtpBottomSheetHeader(),
          SizedBox(height: AdaptiveLayout.h(context, 20)),
          Text("Check your messages",
              style: GoogleFonts.outfit(fontSize: AdaptiveLayout.sp(context, 20), fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 4),
          OtpBottomSheetSubtitle(maskedPhone: masked),
          SizedBox(height: AdaptiveLayout.h(context, 24)),
          OtpInputField(controllers: _controllers, focusNodes: _focusNodes),
          SizedBox(height: AdaptiveLayout.h(context, 24)),
          OtpTimerText(seconds: _seconds, onResend: () {
            _startTimer();
            context.read<AuthBloc>().add(const SubmitPhoneNumber());
          }),
          SizedBox(height: AdaptiveLayout.h(context, 16)),
          GestureDetector(
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'guardian@gmail.com',
              );
              try {
                await launchUrl(emailLaunchUri);
              } catch (e) {
                debugPrint('Could not launch email: $e');
              }
            },
            child: Text("Having trouble? Contact support",
                style: GoogleFonts.inter(fontSize: AdaptiveLayout.sp(context, 13), color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
