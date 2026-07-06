# journey_bloc.dart

* **File Path:** `apps/mobile/lib/features/journey/presentation/bloc/journey_bloc.dart`
* **Type:** `DART`

---

```dart
import 'package:bloc/bloc.dart';
import 'package:guardian/core/services/api_service.dart';
import 'journey_event.dart';
import 'journey_state.dart';

class JourneyBloc extends Bloc<JourneyEvent, JourneyState> {
  JourneyBloc() : super(const JourneyState(status: JourneyStatus.idle)) {
    on<StartJourney>((event, emit) async {
      emit(const JourneyState(status: JourneyStatus.loading));
      try {
        final success = await ApiService.startJourney(
          circleId: event.circleId,
          destination: event.destination,
          duration: event.duration,
        );
        if (success) {
          final int durMinutes = _parseDuration(event.duration);
          emit(
            JourneyState(
              status: JourneyStatus.active,
              destination: event.destination,
              circleId: event.circleId,
              startTime: DateTime.now(),
              durationMinutes: durMinutes,
            ),
          );
        } else {
          emit(
            const JourneyState(
              status: JourneyStatus.failure,
              errorMessage: 'Failed to start broadcast.',
            ),
          );
        }
      } catch (e) {
        emit(
          JourneyState(
            status: JourneyStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    on<EndJourney>((event, emit) {
      emit(const JourneyState(status: JourneyStatus.completed));
    });
  }

  int _parseDuration(String duration) {
    final clean = duration.toLowerCase().trim();
    final digitsOnly = clean.replaceAll(RegExp(r'[^0-9]'), '');
    final val = int.tryParse(digitsOnly);

    if (val != null) {
      if (clean.contains('min')) return val;
      if (clean.contains('hr') || clean.contains('hour')) return val * 60;
      return val;
    }
    return 30;
  }
}

```
