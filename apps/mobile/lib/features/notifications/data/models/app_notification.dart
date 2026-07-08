import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.data,
    this.actorName,
    this.actorAvatarUrl,
  });

  final String id;
  final String kind;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? actorName;
  final String? actorAvatarUrl;
  final Map<String, dynamic> data;

  String? get route => data['route'] as String?;
  String? get circleId => data['circle_id']?.toString();

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      kind: kind,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
      data: data,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'info',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      isRead: json['is_read'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      actorName: json['actor_name']?.toString(),
      actorAvatarUrl: json['actor_avatar_url']?.toString(),
      data: (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }

  @override
  List<Object?> get props => [
    id,
    kind,
    title,
    body,
    isRead,
    createdAt,
    actorName,
    actorAvatarUrl,
    data,
  ];
}
