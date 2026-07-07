part of 'family_circle_bloc.dart';

extension FamilyCircleLoadHandlers on FamilyCircleBloc {
  Future<void> _onStarted(
    FamilyStarted event,
    Emitter<FamilyCircleState> emit,
  ) async {
    emit(state.copyWith(status: FamilyStatus.loading, clearMessages: true));
    _startDeviceStreams();
    await _emitDeviceStats();
    try {
      final userId = await repository.currentUserId();
      final circles = await repository.circles();
      final members = <String, List<Map<String, dynamic>>>{};
      for (final circle in circles) {
        final id = circle['id'] as String;
        members[id] = await repository.members(id);
      }
      emit(
        state.copyWith(
          status: FamilyStatus.success,
          currentUserId: userId,
          circles: circles,
          membersByCircle: members,
          clearMessages: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FamilyStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCircleSelected(
    FamilyCircleSelected event,
    Emitter<FamilyCircleState> emit,
  ) async {
    final circle = event.circle;
    emit(
      state.copyWith(
        mode: FamilyViewMode.details,
        status: FamilyStatus.loading,
        selectedCircleId: circle['id'] as String?,
        selectedCircleName: circle['name'] as String?,
        selectedCircleOwnerId: circle['owner_id'] as String?,
        expandedMemberId: '',
        clearMessages: true,
      ),
    );
    await _loadSelectedDetails(emit);
    _startDetailsTimer();
  }

  Future<void> _onDetailsRefreshRequested(
    FamilyDetailsRefreshRequested event,
    Emitter<FamilyCircleState> emit,
  ) async {
    if (state.selectedCircleId == null) return;
    await _loadSelectedDetails(emit, showLoading: false);
  }

  Future<void> _loadSelectedDetails(
    Emitter<FamilyCircleState> emit, {
    bool showLoading = true,
  }) async {
    final circleId = state.selectedCircleId;
    if (circleId == null) return;
    try {
      final members = await repository.members(circleId);
      final locations = await repository.locations(circleId);
      final invite = await repository.invite(circleId);
      await repository.updateMyLocation(
        circleId,
        state.batteryLevel,
        state.connectivityType,
      );
      emit(
        state.copyWith(
          status: FamilyStatus.success,
          currentMembers: members,
          memberLocations: locations,
          inviteCode: invite['code'] as String?,
          inviteLink: invite['invite_link'] as String?,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: showLoading ? FamilyStatus.failure : state.status,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
