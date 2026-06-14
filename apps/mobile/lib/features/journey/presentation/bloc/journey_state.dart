import 'package:equatable/equatable.dart';

enum JourneyStatus { idle, active, completed }

class JourneyState extends Equatable {
  final JourneyStatus status;
  final String? destination;

  const JourneyState({required this.status, this.destination});

  @override
  List<Object?> get props => [status, destination];
}
