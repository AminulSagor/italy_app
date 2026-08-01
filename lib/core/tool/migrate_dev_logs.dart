import 'dart:io';

void main() {
  final Directory libDirectory = Directory('lib');
  final File pubspecFile = File('pubspec.yaml');

  if (!libDirectory.existsSync() || !pubspecFile.existsSync()) {
    stderr.writeln('Run this command from the Flutter project root.');
    exitCode = 1;
    return;
  }

  final String pubspec = pubspecFile.readAsStringSync();

  final RegExpMatch? packageMatch = RegExp(
    r'^name:\s*([a-zA-Z0-9_]+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec);

  if (packageMatch == null) {
    stderr.writeln('Could not read the package name from pubspec.yaml.');
    exitCode = 1;
    return;
  }

  final String packageName = packageMatch.group(1)!;

  final String loggerImport =
      "import 'package:$packageName/core/utils/app_logger.dart';";

  int changedFiles = 0;
  int changedCalls = 0;

  for (final FileSystemEntity entity
  in libDirectory.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }

    final String normalizedPath =
    entity.path.replaceAll('\\', '/');

    if (normalizedPath.endsWith(
      'lib/core/utils/app_logger.dart',
    )) {
      continue;
    }

    final String original = entity.readAsStringSync();

    final RegExp devLogPattern = RegExp(
      r'\bdev\.log\s*\(',
    );

    final int callCount =
        devLogPattern.allMatches(original).length;

    if (callCount == 0) {
      continue;
    }

    String updated = original.replaceAll(
      devLogPattern,
      'AppLogger.log(',
    );

    if (!updated.contains(loggerImport)) {
      final List<String> lines = updated.split('\n');

      int importPosition = 0;

      for (int index = 0; index < lines.length; index++) {
        if (lines[index].trimLeft().startsWith('import ')) {
          importPosition = index + 1;
        }
      }

      lines.insert(importPosition, loggerImport);
      updated = lines.join('\n');
    }

    // Remove dart:developer import when nothing else uses dev.
    if (!updated.contains('dev.')) {
      updated = updated.replaceAll(
        RegExp(
          r'''^import\s+['"]dart:developer['"]\s+as\s+dev\s*;\r?\n?''',
          multiLine: true,
        ),
        '',
      );
    }

    entity.writeAsStringSync(updated);

    changedFiles++;
    changedCalls += callCount;
  }

  stdout.writeln(
    'Updated $changedCalls dev.log calls in $changedFiles files.',
  );
}