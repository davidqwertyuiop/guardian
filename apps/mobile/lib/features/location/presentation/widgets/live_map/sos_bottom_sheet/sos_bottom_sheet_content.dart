part of '../sos_bottom_sheet.dart';

extension _SosBottomSheetContent on _SosBottomSheetState {
  Widget buildSheetContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.78;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: buildSheetDecoration(isDark),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: SosSheetCloseButton(onTap: closeSheet),
                  ),
                  SosSheetIcon(status: _status),
                  const SizedBox(height: 18),
                  SosSheetHeader(title: titleText, subtitle: subtitleText),
                  if (_status == SosSheetStatus.active)
                    SosActiveDetails(address: _address, isDark: isDark),
                  if (_status == SosSheetStatus.failure &&
                      _errorMessage != null)
                    SosFailureMessage(message: _errorMessage!),
                  const SizedBox(height: 20),
                  SosSheetActionButton(
                    text: buttonText,
                    isLoading: _isResolving,
                    onPressed: buttonAction,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration buildSheetDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFFFF8FB),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.10),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
