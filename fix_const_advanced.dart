import 'dart:io';

void main() async {
  while (true) {
    print("Running flutter analyze...");
    final result = await Process.run('flutter.bat', ['analyze', '--no-fatal-warnings', '--no-fatal-infos'], runInShell: true);
    final output = '${result.stdout}\\n${result.stderr}';
    
    int fixes = await fixErrors(output);
    if (fixes == 0) {
      print("No more const errors found!");
      break;
    }
    print("Made \$fixes fixes. Re-analyzing...");
  }
}

Future<int> fixErrors(String output) async {
  int fixesMade = 0;
  final lines = output.split('\\n');
  
  for (final line in lines) {
    if (line.contains('invalid_constant') || line.contains('const_eval_method_invocation')) {
      final parts = line.split('-');
      if (parts.length >= 2) {
        final fileInfo = parts[parts.length - 2].trim();
        final fileParts = fileInfo.split(':');
        if (fileParts.length >= 3) {
          // If windows path has colon (C:), join it back
          String filepath = fileParts[0];
          int lineIndex = 1;
          if (filepath.length == 1 && fileParts.length >= 4) {
             filepath = '${fileParts[0]}:${fileParts[1]}';
             lineIndex = 2;
          }
          final lineNumStr = fileParts[lineIndex];
          final lineNum = int.tryParse(lineNumStr);
          
          if (lineNum != null && lineNum > 0) {
            final file = File(filepath);
            print("Checking file: \$filepath - exists? \${await file.exists()}");
            if (await file.exists()) {
              final content = await file.readAsLines();
              final targetIndex = lineNum - 1;
              
              if (targetIndex < content.length) {
                // Search up to 5 lines up
                for (int i = targetIndex; i >= 0 && i >= targetIndex - 5; i--) {
                   if (content[i].contains('const ')) {
                       content[i] = content[i].replaceFirst('const ', '');
                       await file.writeAsString('${content.join('\\n')}\\n');
                       fixesMade++;
                       print('Fixed const in \$filepath:\${i+1}');
                       break; // move to next error
                   }
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
