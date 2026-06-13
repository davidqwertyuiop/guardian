class OnboardingState {
  final String username;
  final bool locationGranted;
  final bool notificationsGranted;
  final String circleName;
  final String circleCode;
  final bool isCircleCreated;

  const OnboardingState({
    this.username = '',
    this.locationGranted = false,
    this.notificationsGranted = false,
    this.circleName = '',
    this.circleCode = '',
    this.isCircleCreated = false,
  });

  OnboardingState copyWith({
    String? username,
    bool? locationGranted,
    bool? notificationsGranted,
    String? circleName,
    String? circleCode,
    bool? isCircleCreated,
  }) {
    return OnboardingState(
      username: username ?? this.username,
      locationGranted: locationGranted ?? this.locationGranted,
      notificationsGranted: notificationsGranted ?? this.notificationsGranted,
      circleName: circleName ?? this.circleName,
      circleCode: circleCode ?? this.circleCode,
      isCircleCreated: isCircleCreated ?? this.isCircleCreated,
    );
  }
}
