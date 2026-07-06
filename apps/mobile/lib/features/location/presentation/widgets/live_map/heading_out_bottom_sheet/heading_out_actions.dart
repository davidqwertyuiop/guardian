part of '../heading_out_bottom_sheet.dart';

extension _HeadingOutActions on _HeadingOutBottomSheetState {
  void handleJourneyState(BuildContext context, JourneyState journeyState) {
    if (journeyState.status == JourneyStatus.active) {
      Navigator.pop(context);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => YouAreLiveBottomSheet(
          destination: journeyState.destination ?? "unknown location",
        ),
      );
    } else if (journeyState.status == JourneyStatus.failure) {
      toastification.show(
        context: context,
        title: Text(journeyState.errorMessage ?? 'Failed to start broadcast.'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  void updateDestination(String? value) {
    if (value == null) return;
    refresh(() => _selectedDestination = value);
  }

  void updateDuration(String? value) {
    if (value == null) return;
    refresh(() => _selectedDuration = value);
  }

  void startBroadcast(String selectedCircleId) {
    final destination = _selectedDestination == 'Custom'
        ? _customDestController.text
        : _selectedDestination;
    final duration = _selectedDuration == 'Custom'
        ? _customDurController.text
        : _selectedDuration;

    if (selectedCircleId.isEmpty) {
      toastification.show(
        context: context,
        title: const Text('Please select a circle to broadcast to.'),
        type: ToastificationType.warning,
      );
      return;
    }

    context.read<JourneyBloc>().add(
      StartJourney(
        circleId: selectedCircleId,
        destination: destination.isEmpty ? "unknown location" : destination,
        duration: duration.isEmpty ? "30 Mins" : duration,
      ),
    );
  }
}
