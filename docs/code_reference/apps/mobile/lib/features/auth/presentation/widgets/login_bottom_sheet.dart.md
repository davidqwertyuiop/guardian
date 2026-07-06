# login_bottom_sheet.dart

* **File Path:** `apps/mobile/lib/features/auth/presentation/widgets/login_bottom_sheet.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import 'package:guardian/export.dart';
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
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = context.read<AuthBloc>();
    _phoneController = TextEditingController(text: _authBloc.state.phoneNumber);
    _phoneController.addListener(() {
      final text = _phoneController.text;
      _authBloc.add(PhoneNumberChanged(text));

      final maxDigits = PhoneNumberUtils.getMaxDigits(_authBloc.state.dialCode);
      if (text.length == maxDigits && FocusScope.of(context).hasFocus) {
        FocusScope.of(context).unfocus();
      }
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
    return StreamBuilder<AuthState>(
      stream: _authBloc.stream,
      initialData: _authBloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _authBloc.state;
        final flag = IntlCountryData.fromCountryCodeAlpha2(
          state.countryCode,
        ).flag;
        final maxDigits = PhoneNumberUtils.getMaxDigits(state.dialCode);
        final isComplete = PhoneNumberUtils.isPhoneComplete(
          state.dialCode,
          state.phoneNumber,
        );
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
              SizedBox(height: AdaptiveLayout.h(context, 1)),
              Text(
                "Enter your number",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AdaptiveLayout.sp(context, 20),
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "We'll send you a verification code.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AdaptiveLayout.sp(context, 14),
                  color: AppColors.greyText,
                ),
              ),
              SizedBox(height: AdaptiveLayout.h(context, 24)),
              PhoneInputField(
                controller: _phoneController,
                flag: flag,
                dialCode: state.dialCode,
                maxDigits: maxDigits,
                onTapCountry: () => CountryPickerBottomSheet.show(context, (c) {
                  _authBloc.add(
                    CountryChanged(
                      countryCode: c.codeAlpha2,
                      dialCode: '+${c.telephoneCode}',
                    ),
                  );
                  // Clear the field when country changes so the old
                  // digits don't violate the new country's length rule.
                  _phoneController.clear();
                }),
              ),
              SizedBox(height: AdaptiveLayout.h(context, 20)),
              LoginContinueButton(
                isLoading: state.status == AuthStatus.loading,
                enabled: isComplete,
                onPressed: () => _authBloc.add(const SubmitPhoneNumber()),
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

```
