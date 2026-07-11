import 'dart:io';

void main() {
  final file = File('lib/features/home/presentation/bloc/home_bloc.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    'if (newUri.path == currentUri.path) {',
    'if (newUri.pathSegments.isNotEmpty && currentUri.pathSegments.isNotEmpty && newUri.pathSegments.last == currentUri.pathSegments.last) {'
  );
  file.writeAsStringSync(content);
}
