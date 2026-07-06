# settings_event.dart

* **File Path:** `apps/mobile/lib/features/settings/presentation/bloc/settings_event.dart`
* **Type:** `DART`

---

```dart
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSessions extends SettingsEvent {
  const LoadSessions();
}

class RevokeSession extends SettingsEvent {
  final String tokenHash;
  const RevokeSession(this.tokenHash);

  @override
  List<Object?> get props => [tokenHash];
}

```
