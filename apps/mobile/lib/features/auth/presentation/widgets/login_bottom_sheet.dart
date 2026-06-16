import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_country_data/intl_country_data.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'phone_input_field.dart';
import 'country_picker_bottom_sheet.dart';
import 'login_bottom_sheet_widgets.dart';

class LoginBottomSheet extends StatefulWidget {
  const LoginBottomSheet({super.key});

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AuthBloc>();
    _phoneController = TextEditingController(text: bloc.state.phoneNumber);
    _phoneController.addListener(() {
      bloc.add(PhoneNumberChanged(_phoneController.text));
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final flag = IntlCountryData.fromCountryCodeAlpha2(state.countryCode).flag;
        return Container(
          margin: EdgeInsets.all(AdaptiveLayout.padding(context, 16)),
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
              const LoginBottomSheetHeader(),
              SizedBox(height: AdaptiveLayout.h(context, 20)),
              Text("Enter your number",
                  style: GoogleFonts.outfit(
                      fontSize: AdaptiveLayout.sp(context, 20),
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 4),
              Text("We'll send you a verification code.",
                  style: GoogleFonts.inter(fontSize: AdaptiveLayout.sp(context, 14), color: AppColors.greyText)),
              SizedBox(height: AdaptiveLayout.h(context, 24)),
              PhoneInputField(
                controller: _phoneController,
                flag: flag,
                dialCode: state.dialCode,
                onTapCountry: () => CountryPickerBottomSheet.show(context, (c) {
                  context.read<AuthBloc>().add(CountryChanged(countryCode: c.codeAlpha2, dialCode: '+${c.telephoneCode}'));
                }),
              ),
              SizedBox(height: AdaptiveLayout.h(context, 20)),
              LoginContinueButton(
                isLoading: state.status == AuthStatus.loading,
                enabled: state.phoneNumber.isNotEmpty,
                onPressed: () => context.read<AuthBloc>().add(const SubmitPhoneNumber()),
              ),
              SizedBox(height: AdaptiveLayout.h(context, 16)),
              const LoginBottomSheetTerms(),
            ],
          ),
        );
      },
    );
  }
}
