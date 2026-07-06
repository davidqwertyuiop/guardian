import 'package:equatable/equatable.dart';

enum JourneyStatus { idle, loading, active, completed, failure }

class JourneyState extends Equatable {
  final JourneyStatus status;
  final String? destination;
  final String? errorMessage;
  final DateTime? startTime;
  final int? durationMinutes;
  final String? circleId;

  const JourneyState({
    required this.status,
    this.destination,
    this.errorMessage,
    this.startTime,
    this.durationMinutes,
    this.circleId,
  });

  @override
  List<Object?> get props => [
        status,
        destination,
        errorMessage,
        startTime,
        durationMinutes,
        circleId,
      ];
}
