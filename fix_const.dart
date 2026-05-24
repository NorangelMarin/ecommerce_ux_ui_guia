import 'dart:io';

void main() async {
  while (true) {
    print("Running flutter analyze...");
    final result = await Process.run('flutter.bat', ['analyze', '--no-fatal-warnings', '--no-fatal-infos'], runInShell: true);
    final output = result.stdout.toString();
    
    final fixes = await fixErrors(output);
    if (fixes == 0) {
      print("No more const errors found!");
      break;
    }
    print("Made $fixes fixes. Re-analyzing...");
  }
}

Future<int> fixErrors(String output) async {
  int fixesMade = 0;
  final lines = output.split('\n');
  
  for (final line in lines) {
    // Look for error lines about constants
    if ((line.contains('error •') || line.contains('error -')) && (line.contains('const') || line.contains('Arguments of a constant') || line.contains('non_constant') || line.contains('invalid_constant'))) {
      final parts = line.contains('error -') ? line.split('-') : line.split('•');
      if (parts.length >= 3) {
        final fileInfo = parts[2].trim();
        final fileParts = fileInfo.split(':');
        
        if (fileParts.length >= 3) {
          // Join in case path has a drive letter with colon, but parts[2] usually doesn't have the drive letter in `flutter analyze` output unless it's an absolute path.
          // Usually output is like: lib\widgets\custom_drawer.dart:12:30
          final filepath = fileParts[0];
          final lineNum = int.tryParse(fileParts[1]);
          
          if (lineNum != null && lineNum > 0) {
            final file = File(filepath);
            if (await file.exists()) {
              final content = await file.readAsLines();
              final targetIndex = lineNum - 1;
              
              if (targetIndex < content.length) {
                final originalLine = content[targetIndex];
                if (originalLine.contains('const ')) {
                  content[targetIndex] = originalLine.replaceFirst('const ', '');
                  await file.writeAsString('${content.join('\n')}\n');
                  fixesMade++;
                  print('Fixed const in \$filepath:\$lineNum');
                }
              }
            }
          }
        }
      }
    }
  }
  return fixesMade;
}
