import 'dart:io';

void main() {
  final file = File('lib/features/location/presentation/screens/live_map_screen.dart');
  String content = file.readAsStringSync();

  // Fix import
  final importTarget = "import 'package:guardian/features/location/presentation/widgets/live_map/heading_out_bottom_sheet.dart';";
  final importReplacement = "$importTarget\nimport 'package:guardian/features/location/presentation/widgets/live_map/member_avatar_row.dart';";
  if (!content.contains("member_avatar_row.dart")) {
    content = content.replaceFirst(importTarget, importReplacement);
  }

  // Fix withOpacity
  content = content.replaceAll("withOpacity(0.15)", "withValues(alpha: 0.15)");

  file.writeAsStringSync(content);
}
