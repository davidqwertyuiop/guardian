# you_are_live_bottom_sheet.dart

* **File Path:** `apps/mobile/lib/features/location/presentation/widgets/live_map/you_are_live_bottom_sheet.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class YouAreLiveBottomSheet extends StatelessWidget {
  final String destination;
  final bool isConfirmStop;

  const YouAreLiveBottomSheet({
    super.key,
    required this.destination,
    this.isConfirmStop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgBoxColor = isDark ? const Color(0xFF1E1E24) : Colors.white;

    Widget content = BlocListener<HomeBloc, HomeState>(
      listener: (context, homeState) {
        if (!isConfirmStop) {
          // If we successfully left the circle, pop this bottom sheet
          if (homeState.status == HomeStatus.success && homeState.circleId.isEmpty) {
            Navigator.pop(context);
            toastification.show(
              context: context,
              title: const Text('Successfully left the circle.'),
              type: ToastificationType.success,
              autoCloseDuration: const Duration(seconds: 3),
            );
          } else if (homeState.status == HomeStatus.failure) {
            toastification.show(
              context: context,
              title: Text(homeState.errorMessage.isNotEmpty
                  ? homeState.errorMessage
                  : 'Failed to leave circle.'),
              type: ToastificationType.error,
              autoCloseDuration: const Duration(seconds: 3),
            );
          }
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          final isLeavingLoading = homeState.status == HomeStatus.loading;

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 24,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgBoxColor,
                borderRadius: BorderRadius.circular(32),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : const Color(0xFFF2F2F7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Icon
                      isConfirmStop
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF0F5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Color(0xFFFF4081),
                                size: 32,
                              ),
                            )
                          : Image.asset(
                              'assets/icons/youareliveicon.png',
                              width: 64,
                              height: 64,
                            ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        isConfirmStop ? "Stop broadcasting?" : "You're live",
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          isConfirmStop
                              ? "Your circle will be notified that your broadcast has ended."
                              : "Your circle has been notified. They can see you heading ${destination.toLowerCase()}. Tap the banner at the top to stop early.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            height: 1.5,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: Platform.isIOS ? 42 : 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFF0F5),
                                  foregroundColor: const Color(0xFFFF4081),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Platform.isIOS ? 100 : 16),
                                  ),
                                ),
                                onPressed: () {
                                  if (isConfirmStop) {
                                    context.read<JourneyBloc>().add(const EndJourney());
                                    Navigator.pop(context);
                                  } else {
                                    if (isLeavingLoading) return;
                                    if (homeState.circleId.isNotEmpty) {
                                      context.read<HomeBloc>().add(LeaveCircle(homeState.circleId));
                                    } else {
                                      toastification.show(
                                        context: context,
                                        title: const Text('No active circle to leave.'),
                                        type: ToastificationType.warning,
                                      );
                                    }
                                  }
                                },
                                child: (!isConfirmStop && isLeavingLoading)
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFFFF4081),
                                        ),
                                      )
                                    : Text(
                                        isConfirmStop ? "Yes, stop" : "Leave circle",
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10), // gap: 10px
                          Expanded(
                            child: SizedBox(
                              height: Platform.isIOS ? 42 : 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? Colors.white : Colors.black,
                                  foregroundColor: isDark ? Colors.black : Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Platform.isIOS ? 100 : 16),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  isConfirmStop ? "Keep going" : "Stay",
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    return content;
  }
}

```
