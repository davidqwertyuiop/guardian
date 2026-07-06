# settings_state.dart

* **File Path:** `apps/mobile/lib/features/settings/presentation/bloc/settings_state.dart`
* **Type:** `DART`

---

```dart
import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  final List<dynamic> sessions;
  final SettingsStatus status;
  final String errorMessage;

  const SettingsState({
    this.sessions = const [],
    this.status = SettingsStatus.initial,
    this.errorMessage = '',
  });

  SettingsState copyWith({
    List<dynamic>? sessions,
    SettingsStatus? status,
    String? errorMessage,
  }) {
    return SettingsState(
      sessions: sessions ?? this.sessions,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [sessions, status, errorMessage];
}

```
