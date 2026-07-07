part of 'family_circle_bloc.dart';

extension FamilyCircleActionHandlers on FamilyCircleBloc {
  Future<void> _onJoinSubmitted(
    FamilyJoinSubmitted event,
    Emitter<FamilyCircleState> emit,
  ) async {
    await _runAction(
      emit,
      () => repository.joinCircle(event.codeOrLink),
      'Circle joined.',
    );
  }

  Future<void> _onCreateSubmitted(
    FamilyCreateSubmitted event,
    Emitter<FamilyCircleState> emit,
  ) async {
    await _runAction(emit, () async {
      await repository.createCircle(event.name);
    }, 'Circle created.');
  }

  Future<void> _onLeaveSubmitted(
    FamilyLeaveSubmitted event,
    Emitter<FamilyCircleState> emit,
  ) async {
    await _runAction(
      emit,
      () => repository.leaveCircle(event.circleId),
      'Successfully left circle.',
      resetToOverview: true,
    );
  }

  Future<void> _onDeleteSubmitted(
    FamilyDeleteSubmitted event,
    Emitter<FamilyCircleState> emit,
  ) async {
    await _runAction(
      emit,
      () => repository.deleteCircle(event.circleId),
      'Circle successfully deleted.',
      resetToOverview: true,
    );
  }

  Future<void> _onRemoveMemberSubmitted(
    FamilyRemoveMemberSubmitted event,
    Emitter<FamilyCircleState> emit,
  ) async {
    final circleId = state.selectedCircleId;
    if (circleId == null) return;
    await _runAction(
      emit,
      () => repository.removeMember(circleId, event.memberId),
      'Member removed from circle.',
      refreshDetails: true,
    );
  }

  Future<void> _runAction(
    Emitter<FamilyCircleState> emit,
    Future<void> Function() action,
    String message, {
    bool resetToOverview = false,
    bool refreshDetails = false,
  }) async {
    emit(
      state.copyWith(status: FamilyStatus.actionLoading, clearMessages: true),
    );
    try {
      await action();
      if (resetToOverview) add(const FamilyOverviewRequested());
      add(const FamilyStarted());
      if (refreshDetails) add(const FamilyDetailsRefreshRequested());
      emit(
        state.copyWith(status: FamilyStatus.success, actionMessage: message),
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
}
