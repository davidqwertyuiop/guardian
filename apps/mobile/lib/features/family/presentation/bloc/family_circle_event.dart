import 'package:equatable/equatable.dart';

sealed class FamilyCircleEvent extends Equatable {
  const FamilyCircleEvent();

  @override
  List<Object?> get props => [];
}

class FamilyStarted extends FamilyCircleEvent {
  const FamilyStarted();
}

class FamilyCircleSelected extends FamilyCircleEvent {
  const FamilyCircleSelected(this.circle);
  final Map<String, dynamic> circle;

  @override
  List<Object?> get props => [circle];
}

class FamilyOverviewRequested extends FamilyCircleEvent {
  const FamilyOverviewRequested();
}

class FamilyInviteRequested extends FamilyCircleEvent {
  const FamilyInviteRequested();
}

class FamilyDetailsRequested extends FamilyCircleEvent {
  const FamilyDetailsRequested();
}

class FamilyDetailsRefreshRequested extends FamilyCircleEvent {
  const FamilyDetailsRefreshRequested();
}

class FamilyMemberExpanded extends FamilyCircleEvent {
  const FamilyMemberExpanded(this.memberId);
  final String? memberId;

  @override
  List<Object?> get props => [memberId];
}

class FamilyJoinSubmitted extends FamilyCircleEvent {
  const FamilyJoinSubmitted(this.codeOrLink);
  final String codeOrLink;

  @override
  List<Object?> get props => [codeOrLink];
}

class FamilyCreateSubmitted extends FamilyCircleEvent {
  const FamilyCreateSubmitted(this.name);
  final String name;

  @override
  List<Object?> get props => [name];
}

class FamilyLeaveSubmitted extends FamilyCircleEvent {
  const FamilyLeaveSubmitted(this.circleId);
  final String circleId;

  @override
  List<Object?> get props => [circleId];
}

class FamilyDeleteSubmitted extends FamilyCircleEvent {
  const FamilyDeleteSubmitted(this.circleId);
  final String circleId;

  @override
  List<Object?> get props => [circleId];
}

class FamilyRemoveMemberSubmitted extends FamilyCircleEvent {
  const FamilyRemoveMemberSubmitted(this.memberId);
  final String memberId;

  @override
  List<Object?> get props => [memberId];
}

class FamilyDeviceStatsChanged extends FamilyCircleEvent {
  const FamilyDeviceStatsChanged(this.batteryLevel, this.connectivityType);
  final int batteryLevel;
  final String connectivityType;

  @override
  List<Object?> get props => [batteryLevel, connectivityType];
}
