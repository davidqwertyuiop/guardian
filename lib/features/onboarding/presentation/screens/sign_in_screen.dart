import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/services/api_service.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_state.dart';
import 'package:guardian/features/auth/presentation/widgets/avatar_cluster.dart';
import 'package:guardian/features/auth/presentation/widgets/country_picker_bottom_sheet.dart';
import 'package:guardian/features/auth/presentation/widgets/otp_input_field.dart';
import 'package:guardian/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:guardian/features/onboarding/presentation/screens/profile_setup_screen.dart';
import 'package:guardian/core/utils/fade_route.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(4, (_) => FocusNode());
  late AuthBloc _authBloc;
  String? _mockOtp;
  String? _errorMessage;
  Timer? _resendTimer;
  int _resendCountdown = 30;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _phoneController.addListener(() {
      _authBloc.add(PhoneNumberChanged(_phoneController.text));
    });
    for (var c in _otpControllers) {
      c.addListener(_onOtpChanged);
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = 30;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _contactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'guardian@gmail.com',
      queryParameters: {
        'subject': 'Guardian Support Request',
      },
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      Clipboard.setData(const ClipboardData(text: 'guardian@gmail.com'));
      setState(() {
        _errorMessage = "Could not open mail app. Support email copied.";
      });
    }
  }

  void _onOtpChanged() {
    final code = _otpControllers.map((c) => c.text.trim()).join();
    if (code.length == 4) {
      _authBloc.add(SubmitVerificationCode(code));
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _resendTimer?.cancel();
    for (var c in _otpControllers) {
      c.removeListener(_onOtpChanged);
      c.dispose();
    }
    for (var n in _otpFocusNodes) {
      n.dispose();
    }
    _authBloc.close();
    super.dispose();
  }

  void _showCountryPicker(BuildContext context) {
    CountryPickerBottomSheet.show(context, (country) {
      _authBloc.add(
        CountryChanged(
            countryCode: country.code, dialCode: country.dialCode),
      );
      Navigator.pop(context);
    });
  }

  void _loadMockOtp() async {
    // Fetch the latest OTP from the running Rust backend
    final code = await ApiService.getLatestOtp();
    if (mounted) {
      setState(() {
        _mockOtp = code;
      });
    }
  }

  void _resetOtpFields() {
    for (var c in _otpControllers) {
      c.clear();
    }
    setState(() {
      _mockOtp = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return BlocProvider.value(
      value: _authBloc,
      child: Scaffold(
        // extendBodyBehindAppBar ensures background covers the status bar
        extendBodyBehindAppBar: true,
        backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F4FA),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.failure &&
                state.errorMessage != null) {
              setState(() {
                _errorMessage = state.errorMessage;
              });
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              });
            }
            if (state.status == AuthStatus.codeSent) {
              _loadMockOtp();
              _startResendTimer();
            }
            if (state.status == AuthStatus.success) {
              Navigator.of(context).pushAndRemoveUntil(
                FadeRoute(page: const ProfileSetupScreen()),
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            final showOtpHero = state.status == AuthStatus.codeSent;

            return Stack(
              children: [
                // ── Deep background ───────────────────────────
                Positioned.fill(
                  child: Container(
                    color: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F4FA),
                  ),
                ),

                // ── Ellipse 1 (Peach/Orange dot top left) ───────────
                Positioned(
                  top: size.height * 0.12,
                  left: size.width * 0.14,
                  child: Image.asset(
                    AppAssets.ellipse1,
                    width: 22,
                    height: 22,
                    errorBuilder: (ctx, err, stack) => const SizedBox(),
                  ),
                ),

                // ── Ellipse 2 (Green/Mint dot top right) ────────────
                Positioned(
                  top: size.height * 0.14,
                  right: size.width * 0.08,
                  child: Image.asset(
                    AppAssets.ellipse2,
                    width: 20,
                    height: 20,
                    errorBuilder: (ctx, err, stack) => const SizedBox(),
                  ),
                ),

                // ── Ellipse 3 (Cyan dot middle left) ────────────────
                Positioned(
                  top: size.height * 0.38,
                  left: size.width * 0.04,
                  child: Image.asset(
                    AppAssets.ellipse3,
                    width: 16,
                    height: 16,
                    errorBuilder: (ctx, err, stack) => const SizedBox(),
                  ),
                ),

                // ── Ellipse 4 (Cyan dot middle right) ───────────────
                Positioned(
                  top: size.height * 0.44,
                  right: size.width * 0.12,
                  child: Image.asset(
                    AppAssets.ellipse4,
                    width: 14,
                    height: 14,
                    errorBuilder: (ctx, err, stack) => const SizedBox(),
                  ),
                ),

                // ── Ellipse 5 (Small white dot) ─────────────────────
                Positioned(
                  top: size.height * 0.25,
                  left: size.width * 0.08,
                  child: Image.asset(
                    AppAssets.ellipse5,
                    width: 8,
                    height: 8,
                    errorBuilder: (ctx, err, stack) => const SizedBox(),
                  ),
                ),

                // ── PHONE ENTRY State: Avatar Cluster (Brought lower) 
                if (!showOtpHero)
                  Positioned(
                    top: size.height * 0.18,
                    left: 0,
                    right: 0,
                    child: const Center(child: AvatarCluster()),
                  ),

                // ── OTP/VERIFY State: Woman Background (bold, edge-to-edge)
                if (showOtpHero) ...[
                  // Wavy lines / ellipse decoration at low opacity
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.30,
                      child: Image.asset(
                        AppAssets.ellipse6,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const SizedBox(),
                      ),
                    ),
                  ),

                  // Woman background — fills from very top (behind status bar) to ~55% of screen height
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: size.height * 0.56,
                    child: Image.asset(
                      AppAssets.womanBackground,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context2, error, stack) => const SizedBox(),
                    ),
                  ),
                ],

                // ── Title Text ──
                // OTP state: title sits at ~61% height, just above the floating card
                // Phone state: sits at 42%, above the card
                Positioned(
                  top: showOtpHero ? size.height * 0.61 : size.height * 0.42,
                  left: size.width * 0.06,
                  right: size.width * 0.06,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      showOtpHero
                          ? "Let's get you\nverified"
                          : "Let's get you\nsigned in",
                      key: ValueKey(showOtpHero),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: size.width * 0.095,
                        fontWeight: FontWeight.w800,
                        // Always white in dark mode; in light mode use dark colour
                        // unless OTP hero is showing (image above makes it white)
                        color: (isDark || showOtpHero)
                            ? Colors.white
                            : const Color(0xFF16161B),
                        height: 1.15,
                      ),
                    ),
                  ),
                ),

                // ── Floating Bottom Card ─────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomCard(context, state, isDark, size),
                ),
                if (_errorMessage != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    right: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                              onPressed: () {
                                setState(() {
                                  _errorMessage = null;
                                });
                              },
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomCard(
      BuildContext context, AuthState state, bool isDark, Size size) {
    final showOtp = state.status == AuthStatus.codeSent;
    final cardTitle = showOtp ? "Check your messages" : "Enter your number";
    final cardSubtitle = "We'll send you a verification code.";

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : Colors.white,
        borderRadius: BorderRadius.circular(20), // More defined rectangular shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16), // Tighter padding to reduce height
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header row with back icon/bolt icon & close icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!showOtp)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C60FF).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt,
                    size: 16,
                    color: Color(0xFF7C60FF),
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    _resetOtpFields();
                    _authBloc.add(const ResetAuth());
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : Colors.black87,
                      size: 16,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Tighter gap

          // Title
          Text(
            cardTitle,
            style: GoogleFonts.outfit(
              fontSize: size.width * 0.054,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4), // Tighter gap

          // Subtitle
          if (showOtp)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text.rich(
                TextSpan(
                  text:
                      "We sent a 4-digit code to ${state.dialCode} ${state.phoneNumber} ",
                  style: GoogleFonts.inter(
                    fontSize: size.width * 0.033,
                    color: isDark ? Colors.white60 : AppColors.greyText,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(
                      text: "Edit",
                      style: GoogleFonts.inter(
                        fontSize: size.width * 0.033,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _resetOtpFields();
                          _authBloc.add(const ResetAuth());
                        },
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Text(
              cardSubtitle,
              style: GoogleFonts.inter(
                fontSize: size.width * 0.034,
                color: isDark ? Colors.white60 : AppColors.greyText,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16), // Tighter gap

          // Autofill Message Suggestion (SIMULATING iOS SMS Autofill)
          if (showOtp && _mockOtp != null) ...[
            GestureDetector(
              onTap: () {
                for (int i = 0; i < 4 && i < _mockOtp!.length; i++) {
                  _otpControllers[i].text = _mockOtp![i];
                }
                for (var fn in _otpFocusNodes) {
                  fn.unfocus();
                }
                _authBloc.add(SubmitVerificationCode(_mockOtp!));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C60FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF7C60FF).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sms_outlined,
                      size: 16,
                      color: Color(0xFF7C60FF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "From Messages: ",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Text(
                      _mockOtp!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7C60FF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "(Tap to Autofill)",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7C60FF).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Input field
          if (!showOtp)
            PhoneInputField(
              controller: _phoneController,
              flag: countries
                  .firstWhere((c) => c.code == state.countryCode)
                  .flag,
              dialCode: state.dialCode,
              onTapCountry: () => _showCountryPicker(context),
            )
          else
            OtpInputField(
              controllers: _otpControllers,
              focusNodes: _otpFocusNodes,
            ),
          const SizedBox(height: 16), // Tighter gap

          // Continue Button (Only shown on phone number screen)
          if (!showOtp)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: state.status == AuthStatus.loading
                    ? null
                    : () {
                        _authBloc.add(const SubmitPhoneNumber());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.status == AuthStatus.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Continue",
                        style: GoogleFonts.inter(
                          fontSize: size.width * 0.040,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

          // OTP Additional Info / Resend / Support (Only shown on OTP screen)
          if (showOtp) ...[
            if (_resendCountdown > 0)
              Text(
                "Resend code in 0:${_resendCountdown.toString().padLeft(2, '0')}",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white38 : Colors.grey[500],
                ),
              )
            else
              TextButton(
                onPressed: () {
                  _authBloc.add(const SubmitPhoneNumber());
                  _startResendTimer();
                },
                child: Text(
                  "Resend code",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7C60FF),
                  ),
                ),
              ),
            const SizedBox(height: 8), // Tighter gap
            Text.rich(
              TextSpan(
                text: "Having trouble? ",
                children: [
                  TextSpan(
                    text: "Contact support",
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = _contactSupport,
                  ),
                ],
              ),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.grey[500],
              ),
            ),
          ],

          const SizedBox(height: 12), // Tighter gap

          // Terms (Only shown on phone number screen)
          if (!showOtp)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: Text.rich(
                TextSpan(
                  text: "By continuing, you agree to our\n",
                  children: [
                    TextSpan(
                      text: "Terms of Service",
                      style: GoogleFonts.inter(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: GoogleFonts.inter(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const TextSpan(text: "."),
                  ],
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: size.width * 0.03,
                  color: isDark ? Colors.white.withValues(alpha: 0.45) : AppColors.greyText,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
