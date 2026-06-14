import 'package:equatable/equatable.dart';

abstract class JourneyEvent extends Equatable {
  const JourneyEvent();
  @override
  List<Object?> get props => [];
}

class StartJourney extends JourneyEvent {
  final String destination;
  const StartJourney(this.destination);
  @override
  List<Object?> get props => [destination];
}

class EndJourney extends JourneyEvent {
  const EndJourney();
}
