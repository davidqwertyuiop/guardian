import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stdout.writeln('lib directory not found');
    return;
  }

  final blocs = ['AuthBloc', 'HomeBloc', 'JourneyBloc', 'SettingsBloc'];
  int modifiedCount = 0;

  for (final file in libDir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      String content = file.readAsStringSync();
      String original = content;

      for (final bloc in blocs) {
        // Handle locator<Bloc>() => context.read<Bloc>()
        content = content.replaceAll('locator<$bloc>()', 'context.read<$bloc>()');
      }

      if (content != original) {
        // If not already importing flutter_bloc, add it
        if (!content.contains('package:flutter_bloc/flutter_bloc.dart')) {
          content = "import 'package:flutter_bloc/flutter_bloc.dart';\n$content";
        }
        
        file.writeAsStringSync(content);
        modifiedCount++;
      }
    }
  }

  stdout.writeln('Modified $modifiedCount files.');
}
