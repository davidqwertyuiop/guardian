import 'package:equatable/equatable.dart';

enum JourneyStatus { idle, loading, active, completed, failure }

class JourneyState extends Equatable {
  final JourneyStatus status;
  final String? destination;
  final String? errorMessage;

  const JourneyState({
    required this.status,
    this.destination,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, destination, errorMessage];
}
