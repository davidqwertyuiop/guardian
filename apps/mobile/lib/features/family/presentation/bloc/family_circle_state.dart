enum FamilyViewMode { overview, details, invite }

enum FamilyStatus { initial, loading, success, failure, actionLoading }

class FamilyCircleState {
  const FamilyCircleState({
    this.mode = FamilyViewMode.overview,
    this.status = FamilyStatus.initial,
    this.circles = const [],
    this.membersByCircle = const {},
    this.currentMembers = const [],
    this.memberLocations = const {},
    this.currentUserId = '',
    this.selectedCircleId,
    this.selectedCircleName,
    this.selectedCircleOwnerId,
    this.expandedMemberId,
    this.inviteCode,
    this.inviteLink,
    this.batteryLevel = 100,
    this.connectivityType = 'Cellular',
    this.errorMessage,
    this.actionMessage,
  });

  final FamilyViewMode mode;
  final FamilyStatus status;
  final List<Map<String, dynamic>> circles;
  final Map<String, List<Map<String, dynamic>>> membersByCircle;
  final List<Map<String, dynamic>> currentMembers;
  final Map<String, Map<String, dynamic>> memberLocations;
  final String currentUserId;
  final String? selectedCircleId;
  final String? selectedCircleName;
  final String? selectedCircleOwnerId;
  final String? expandedMemberId;
  final String? inviteCode;
  final String? inviteLink;
  final int batteryLevel;
  final String connectivityType;
  final String? errorMessage;
  final String? actionMessage;

  bool get isOwner =>
      selectedCircleOwnerId != null && selectedCircleOwnerId == currentUserId;

  FamilyCircleState copyWith({
    FamilyViewMode? mode,
    FamilyStatus? status,
    List<Map<String, dynamic>>? circles,
    Map<String, List<Map<String, dynamic>>>? membersByCircle,
    List<Map<String, dynamic>>? currentMembers,
    Map<String, Map<String, dynamic>>? memberLocations,
    String? currentUserId,
    String? selectedCircleId,
    String? selectedCircleName,
    String? selectedCircleOwnerId,
    String? expandedMemberId,
    String? inviteCode,
    String? inviteLink,
    int? batteryLevel,
    String? connectivityType,
    String? errorMessage,
    String? actionMessage,
    bool clearSelection = false,
    bool clearMessages = false,
  }) {
    return FamilyCircleState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      circles: circles ?? this.circles,
      membersByCircle: membersByCircle ?? this.membersByCircle,
      currentMembers: currentMembers ?? this.currentMembers,
      memberLocations: memberLocations ?? this.memberLocations,
      currentUserId: currentUserId ?? this.currentUserId,
      selectedCircleId: clearSelection
          ? null
          : selectedCircleId ?? this.selectedCircleId,
      selectedCircleName: clearSelection
          ? null
          : selectedCircleName ?? this.selectedCircleName,
      selectedCircleOwnerId: clearSelection
          ? null
          : selectedCircleOwnerId ?? this.selectedCircleOwnerId,
      expandedMemberId: clearSelection
          ? null
          : expandedMemberId ?? this.expandedMemberId,
      inviteCode: clearSelection ? null : inviteCode ?? this.inviteCode,
      inviteLink: clearSelection ? null : inviteLink ?? this.inviteLink,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      connectivityType: connectivityType ?? this.connectivityType,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearMessages ? null : actionMessage ?? this.actionMessage,
    );
  }
}
