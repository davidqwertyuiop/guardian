import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSessions extends SettingsEvent {
  const LoadSessions();
}

class LoadSettingsProfile extends SettingsEvent {
  const LoadSettingsProfile();
}

class UpdateSettingsPreferences extends SettingsEvent {
  const UpdateSettingsPreferences({
    required this.locationEnabled,
    required this.notifySos,
    required this.notifyBroadcast,
    required this.notifyNewMember,
    this.locationPausedUntil,
  });

  final bool locationEnabled;
  final bool notifySos;
  final bool notifyBroadcast;
  final bool notifyNewMember;
  final DateTime? locationPausedUntil;

  @override
  List<Object?> get props => [
        locationEnabled,
        notifySos,
        notifyBroadcast,
        notifyNewMember,
        locationPausedUntil,
      ];
}

class DeleteAccountRequested extends SettingsEvent {
  const DeleteAccountRequested();
}

class RevokeSession extends SettingsEvent {
  final String tokenHash;
  const RevokeSession(this.tokenHash);

  @override
  List<Object?> get props => [tokenHash];
}

class UploadAvatarRequested extends SettingsEvent {
  final File imageFile;
  const UploadAvatarRequested(this.imageFile);

  @override
  List<Object?> get props => [imageFile.path];
}

