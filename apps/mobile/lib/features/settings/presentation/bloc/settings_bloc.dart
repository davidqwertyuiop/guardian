import 'package:guardian/export.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSessions>(_onLoadSessions);
    on<RevokeSession>(_onRevokeSession);
    on<LoadSettingsProfile>(_onLoadProfile);
    on<UpdateSettingsPreferences>(_onUpdatePreferences);
    on<DeleteAccountRequested>(_onDeleteAccount);
    on<UploadAvatarRequested>(_onUploadAvatar);
  }

  Future<void> _onLoadSessions(
    LoadSessions event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final list = await ApiService.getSessions();
      final currentToken = await TokenManager().getRefreshToken();
      emit(state.copyWith(
        sessions: list,
        currentRefreshToken: currentToken ?? '',
        status: SettingsStatus.success,
      ));
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRevokeSession(
    RevokeSession event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      await ApiService.revokeSession(event.tokenHash);
      final list = await ApiService.getSessions();
      final currentToken = await TokenManager().getRefreshToken();
      emit(state.copyWith(
        sessions: list,
        currentRefreshToken: currentToken ?? '',
        status: SettingsStatus.success,
      ));
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadProfile(
    LoadSettingsProfile event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final profile = await ApiService.getMe();
      emit(
        state.copyWith(
          locationEnabled: profile['location_enabled'] == true,
          notifySos: profile['notify_sos'] != false,
          notifyBroadcast: profile['notify_broadcast'] != false,
          notifyNewMember: profile['notify_new_member'] != false,
          phone: profile['phone'] as String? ?? '',
        ),
      );
    } catch (_) {}
  }

  Future<void> _onUpdatePreferences(
    UpdateSettingsPreferences event,
    Emitter<SettingsState> emit,
  ) async {
    emit(
      state.copyWith(
        locationEnabled: event.locationEnabled,
        notifySos: event.notifySos,
        notifyBroadcast: event.notifyBroadcast,
        notifyNewMember: event.notifyNewMember,
      ),
    );
    await ApiService.updatePreferences(
      event.locationEnabled,
      event.notifySos,
      event.notifyBroadcast,
      event.notifyNewMember,
      event.locationPausedUntil,
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccountRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    await ApiService.deleteAccount();
    await TokenManager().clearTokens();
    emit(state.copyWith(status: SettingsStatus.success, accountDeleted: true));
  }

  Future<void> _onUploadAvatar(
    UploadAvatarRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(avatarUploading: true));
    try {
      final url = await ApiService.uploadAvatar(event.imageFile);
      emit(state.copyWith(avatarUploading: false, newAvatarUrl: url));
    } catch (e) {
      emit(
        state.copyWith(
          avatarUploading: false,
          status: SettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

