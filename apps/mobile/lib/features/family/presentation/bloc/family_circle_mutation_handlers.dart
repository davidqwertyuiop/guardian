part of 'family_circle_bloc.dart';

extension FamilyCircleMutationHandlers on FamilyCircleBloc {
  void _onOverviewRequested(
    FamilyOverviewRequested event,
    Emitter<FamilyCircleState> emit,
  ) {
    _detailsTimer?.cancel();
    emit(
      state.copyWith(
        mode: FamilyViewMode.overview,
        currentMembers: const [],
        memberLocations: const {},
        clearSelection: true,
        clearMessages: true,
      ),
    );
  }

  void _onInviteRequested(
    FamilyInviteRequested event,
    Emitter<FamilyCircleState> emit,
  ) {
    emit(state.copyWith(mode: FamilyViewMode.invite, clearMessages: true));
  }

  void _onDetailsRequested(
    FamilyDetailsRequested event,
    Emitter<FamilyCircleState> emit,
  ) {
    emit(state.copyWith(mode: FamilyViewMode.details, clearMessages: true));
  }

  void _onMemberExpanded(
    FamilyMemberExpanded event,
    Emitter<FamilyCircleState> emit,
  ) {
    emit(state.copyWith(expandedMemberId: event.memberId ?? ''));
  }

  void _onDeviceStatsChanged(
    FamilyDeviceStatsChanged event,
    Emitter<FamilyCircleState> emit,
  ) {
    emit(
      state.copyWith(
        batteryLevel: event.batteryLevel,
        connectivityType: event.connectivityType,
      ),
    );
  }
}
