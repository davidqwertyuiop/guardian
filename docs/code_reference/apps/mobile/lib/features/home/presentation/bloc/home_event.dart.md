# home_event.dart

* **File Path:** `apps/mobile/lib/features/home/presentation/bloc/home_event.dart`
* **Type:** `DART`

---

```dart
import 'package:equatable/equatable.dart';
import 'home_state.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class ChangeTab extends HomeEvent {
  final int index;
  const ChangeTab(this.index);

  @override
  List<Object?> get props => [index];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class ChangeMapState extends HomeEvent {
  final MapDisplayState mapState;
  const ChangeMapState(this.mapState);

  @override
  List<Object?> get props => [mapState];
}

class SelectCircle extends HomeEvent {
  final String circleId;
  const SelectCircle(this.circleId);

  @override
  List<Object?> get props => [circleId];
}

class LeaveCircle extends HomeEvent {
  final String circleId;
  const LeaveCircle(this.circleId);

  @override
  List<Object?> get props => [circleId];
}

class UpdateWeatherAndLocation extends HomeEvent {
  final double latitude;
  final double longitude;
  final String weatherGreeting;

  const UpdateWeatherAndLocation({
    required this.latitude,
    required this.longitude,
    required this.weatherGreeting,
  });

  @override
  List<Object?> get props => [latitude, longitude, weatherGreeting];
}

```
