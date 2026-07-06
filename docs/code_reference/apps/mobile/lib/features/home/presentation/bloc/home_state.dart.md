# home_state.dart

* **File Path:** `apps/mobile/lib/features/home/presentation/bloc/home_state.dart`
* **Type:** `DART`

---

```dart
import 'package:equatable/equatable.dart';

enum HomeStatus { initial, loading, success, failure }

enum MapDisplayState { compact, expanded, full }

class HomeState extends Equatable {
  final int currentIndex;
  final String userName;
  final String avatarUrl;
  final String circleName;
  final String circleId;
  final List<dynamic> members;
  final List<dynamic> sosBroadcasts;
  final HomeStatus status;
  final String errorMessage;
  final String weatherGreeting;
  final double userLatitude;
  final double userLongitude;
  final MapDisplayState mapDisplayState;
  final List<dynamic> circles;

  const HomeState({
    this.currentIndex = 0,
    this.userName = '',
    this.avatarUrl = '',
    this.circleName = '',
    this.circleId = '',
    this.members = const [],
    this.sosBroadcasts = const [],
    this.status = HomeStatus.initial,
    this.errorMessage = '',
    this.weatherGreeting = "Lovely weather we're having today...",
    this.userLatitude = 9.0578,
    this.userLongitude = 7.4951,
    this.mapDisplayState = MapDisplayState.compact,
    this.circles = const [],
  });

  HomeState copyWith({
    int? currentIndex,
    String? userName,
    String? avatarUrl,
    String? circleName,
    String? circleId,
    List<dynamic>? members,
    List<dynamic>? sosBroadcasts,
    HomeStatus? status,
    String? errorMessage,
    String? weatherGreeting,
    double? userLatitude,
    double? userLongitude,
    MapDisplayState? mapDisplayState,
    List<dynamic>? circles,
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      circleName: circleName ?? this.circleName,
      circleId: circleId ?? this.circleId,
      members: members ?? this.members,
      sosBroadcasts: sosBroadcasts ?? this.sosBroadcasts,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      weatherGreeting: weatherGreeting ?? this.weatherGreeting,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      mapDisplayState: mapDisplayState ?? this.mapDisplayState,
      circles: circles ?? this.circles,
    );
  }

  @override
  List<Object?> get props => [
    currentIndex,
    userName,
    avatarUrl,
    circleName,
    circleId,
    members,
    sosBroadcasts,
    status,
    errorMessage,
    weatherGreeting,
    userLatitude,
    userLongitude,
    mapDisplayState,
    circles,
  ];
}

```
