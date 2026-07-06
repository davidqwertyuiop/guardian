part of '../heading_out_bottom_sheet.dart';

extension _HeadingOutContent on _HeadingOutBottomSheetState {
  Widget buildSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgBoxColor = isDark ? const Color(0xFF1E1E24) : Colors.white;
    final borderColor = isDark ? Colors.white24 : const Color(0xFFE5E5EA);

    return BlocListener<JourneyBloc, JourneyState>(
      listener: handleJourneyState,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          final selectedCircleId = homeState.circleId;
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgBoxColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeadingOutHeader(isDark: isDark, textColor: textColor),
                    const SizedBox(height: 32),
                    buildDestinationSection(isDark, textColor, borderColor),
                    const SizedBox(height: 24),
                    buildDurationSection(isDark, textColor, borderColor),
                    const SizedBox(height: 24),
                    HeadingOutNotice(isDark: isDark),
                    const SizedBox(height: 16),
                    HeadingOutCircleSelector(
                      homeState: homeState,
                      selectedCircleId: selectedCircleId,
                    ),
                    const SizedBox(height: 32),
                    HeadingOutStartButton(
                      isDark: isDark,
                      selectedCircleId: selectedCircleId,
                      onStart: startBroadcast,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
