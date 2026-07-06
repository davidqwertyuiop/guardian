import 'package:intl/intl.dart';

class SosBroadcastEntry {
  final String name;
  final String location;
  final String date;
  final String time;
  final String? avatarUrl;

  const SosBroadcastEntry({
    required this.name,
    required this.location,
    required this.date,
    required this.time,
    this.avatarUrl,
  });

  factory SosBroadcastEntry.fromJson(dynamic value) {
    final json = value is Map ? value : const {};
    final createdAt = json['created_at'] as String?;

    return SosBroadcastEntry(
      name:
          json['name'] as String? ??
          json['user_name'] as String? ??
          'Unknown Member',
      location:
          json['address'] as String? ??
          json['last_known_location'] as String? ??
          'Unknown Location',
      date: _dateText(createdAt),
      time: _timeText(createdAt),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  static String _dateText(String? createdAt) {
    final dateTime = _parseCreatedAt(createdAt);
    if (dateTime == null) return 'Unknown';
    return DateFormat('MM/dd/yyyy').format(dateTime);
  }

  static String _timeText(String? createdAt) {
    final dateTime = _parseCreatedAt(createdAt);
    if (dateTime == null) return 'Unknown';
    return DateFormat('h:mma').format(dateTime);
  }

  static DateTime? _parseCreatedAt(String? createdAt) {
    if (createdAt == null) return null;
    try {
      return DateTime.parse(createdAt).toLocal();
    } catch (_) {
      return null;
    }
  }
}
