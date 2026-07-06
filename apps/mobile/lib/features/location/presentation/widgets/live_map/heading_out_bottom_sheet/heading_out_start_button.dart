part of '../heading_out_bottom_sheet.dart';

class HeadingOutStartButton extends StatelessWidget {
  final bool isDark;
  final String selectedCircleId;
  final void Function(String selectedCircleId) onStart;

  const HeadingOutStartButton({super.key, 
    required this.isDark,
    required this.selectedCircleId,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JourneyBloc, JourneyState>(
      builder: (context, journeyState) {
        final isLoading = journeyState.status == JourneyStatus.loading;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: isLoading ? null : () => onStart(selectedCircleId),
            child: isLoading
                ? const _StartButtonLoader()
                : const _StartButtonText(),
          ),
        );
      },
    );
  }
}

class _StartButtonLoader extends StatelessWidget {
  const _StartButtonLoader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
    );
  }
}

class _StartButtonText extends StatelessWidget {
  const _StartButtonText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Start broadcasting",
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
