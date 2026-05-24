import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true);
  for (var entity in files) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();
      if (content.contains('const ')) {
        content = content.replaceAll('const ', '');
        entity.writeAsStringSync(content);
        print('Cleaned \${entity.path}');
      }
    }
  }
}
