import 'package:flutter_bloc/flutter_bloc.dart';
import 'journey_event.dart';
import 'journey_state.dart';

class JourneyBloc extends Bloc<JourneyEvent, JourneyState> {
  JourneyBloc() : super(const JourneyState(status: JourneyStatus.idle)) {
    on<StartJourney>((event, emit) {
      emit(JourneyState(status: JourneyStatus.active, destination: event.destination));
    });
    on<EndJourney>((event, emit) {
      emit(const JourneyState(status: JourneyStatus.completed));
    });
  }
}
