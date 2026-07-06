part of '../sos_bottom_sheet.dart';

class SosFailureMessage extends StatelessWidget {
  final String message;

  const SosFailureMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}

class SosSheetCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const SosSheetCloseButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          size: 16,
          color: isDark ? Colors.white60 : Colors.black38,
        ),
      ),
    );
  }
}

class SosSheetActionButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const SosSheetActionButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading ? const SosButtonLoader() : SosButtonText(text),
      ),
    );
  }
}
