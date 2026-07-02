import 'package:equatable/equatable.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final int currentIndex;
  final String userName;
  final String avatarUrl;
  final String circleName;
  final String circleId;
  final List<dynamic> members;
  final HomeStatus status;
  final String errorMessage;

  const HomeState({
    this.currentIndex = 0,
    this.userName = '',
    this.avatarUrl = '',
    this.circleName = '',
    this.circleId = '',
    this.members = const [],
    this.status = HomeStatus.initial,
    this.errorMessage = '',
  });

  HomeState copyWith({
    int? currentIndex,
    String? userName,
    String? avatarUrl,
    String? circleName,
    String? circleId,
    List<dynamic>? members,
    HomeStatus? status,
    String? errorMessage,
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      circleName: circleName ?? this.circleName,
      circleId: circleId ?? this.circleId,
      members: members ?? this.members,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
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
    status,
    errorMessage,
  ];
}
