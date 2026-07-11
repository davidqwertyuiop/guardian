import 'package:guardian/export.dart';

void main() {
  final rawUrl = 'https://guardian.shadowchat.xyz/api/v1/auth/avatar/e2559458-1754-4794-a010-1490f1ab527c?v=1783783435';
  final parsed = Uri.tryParse(rawUrl)!;
  final params = Map<String, String>.from(parsed.queryParameters);
  params['v'] = '1783783435918';
  final finalUrl = parsed.replace(queryParameters: params).toString();
  
  final newUri = Uri.tryParse(rawUrl)!;
  final currentUri = Uri.tryParse(finalUrl)!;
  log('newUri.path: ${newUri.path}');
  log('currentUri.path: ${currentUri.path}');
  log('Equal? ${newUri.path == currentUri.path}');
}
