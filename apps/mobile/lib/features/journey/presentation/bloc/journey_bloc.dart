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
          emit(
            JourneyState(
              status: JourneyStatus.active,
              destination: event.destination,
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
}
