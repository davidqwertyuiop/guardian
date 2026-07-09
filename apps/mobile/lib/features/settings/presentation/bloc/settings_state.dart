import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  final List<dynamic> sessions;
  final SettingsStatus status;
  final String errorMessage;
  final bool locationEnabled;
  final bool notifySos;
  final bool notifyBroadcast;
  final bool notifyNewMember;
  final bool accountDeleted;
  final bool avatarUploading;
  final String newAvatarUrl;
  final String phone;
  final String currentRefreshToken;

  const SettingsState({
    this.sessions = const [],
    this.status = SettingsStatus.initial,
    this.errorMessage = '',
    this.locationEnabled = true,
    this.notifySos = true,
    this.notifyBroadcast = true,
    this.notifyNewMember = true,
    this.accountDeleted = false,
    this.avatarUploading = false,
    this.newAvatarUrl = '',
    this.phone = '',
    this.currentRefreshToken = '',
  });

  SettingsState copyWith({
    List<dynamic>? sessions,
    SettingsStatus? status,
    String? errorMessage,
    bool? locationEnabled,
    bool? notifySos,
    bool? notifyBroadcast,
    bool? notifyNewMember,
    bool? accountDeleted,
    bool? avatarUploading,
    String? newAvatarUrl,
    String? phone,
    String? currentRefreshToken,
  }) {
    return SettingsState(
      sessions: sessions ?? this.sessions,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      notifySos: notifySos ?? this.notifySos,
      notifyBroadcast: notifyBroadcast ?? this.notifyBroadcast,
      notifyNewMember: notifyNewMember ?? this.notifyNewMember,
      accountDeleted: accountDeleted ?? this.accountDeleted,
      avatarUploading: avatarUploading ?? this.avatarUploading,
      newAvatarUrl: newAvatarUrl ?? this.newAvatarUrl,
      phone: phone ?? this.phone,
      currentRefreshToken: currentRefreshToken ?? this.currentRefreshToken,
    );
  }

  @override
  List<Object?> get props => [
    sessions,
    status,
    errorMessage,
    locationEnabled,
    notifySos,
    notifyBroadcast,
    notifyNewMember,
    accountDeleted,
    avatarUploading,
    newAvatarUrl,
    phone,
    currentRefreshToken,
  ];
}
