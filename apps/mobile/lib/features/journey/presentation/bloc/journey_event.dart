import 'package:equatable/equatable.dart';

abstract class JourneyEvent extends Equatable {
  const JourneyEvent();
  @override
  List<Object?> get props => [];
}

class StartJourney extends JourneyEvent {
  final String circleId;
  final String destination;
  final String duration;

  const StartJourney({
    required this.circleId,
    required this.destination,
    required this.duration,
  });

  @override
  List<Object?> get props => [circleId, destination, duration];
}

class EndJourney extends JourneyEvent {
  final bool arrived;
  const EndJourney({this.arrived = true});

  @override
  List<Object?> get props => [arrived];
}
