import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/core/services/api_service.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSessions>(_onLoadSessions);
    on<RevokeSession>(_onRevokeSession);
  }

  Future<void> _onLoadSessions(LoadSessions event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final list = await ApiService.getSessions();
      emit(state.copyWith(
        sessions: list,
        status: SettingsStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRevokeSession(RevokeSession event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      await ApiService.revokeSession(event.tokenHash);
      final list = await ApiService.getSessions();
      emit(state.copyWith(
        sessions: list,
        status: SettingsStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
