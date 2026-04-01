import 'dart:io';

class CoverageGateException implements Exception {
  CoverageGateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CoverageOptions {
  CoverageOptions({required this.filePath, required this.minimumPercent});

  final String filePath;
  final double minimumPercent;
}

class CoverageSummary {
  CoverageSummary({required this.coveredLines, required this.totalLines});

  final int coveredLines;
  final int totalLines;

  double get percent =>
      totalLines == 0 ? 100.0 : (coveredLines / totalLines) * 100.0;
}

Future<void> main(List<String> args) async {
  try {
    final options = _parseArgs(args);
    final summary = await _readCoverageSummary(options.filePath);
    final percent = summary.percent;
    final formattedPercent = percent.toStringAsFixed(2);

    stdout.writeln(
      'Coverage: ${summary.coveredLines}/${summary.totalLines} lines ($formattedPercent%)',
    );

    if (percent < options.minimumPercent) {
      stderr.writeln(
        'Coverage gate failed: $formattedPercent% is below the minimum ${options.minimumPercent.toStringAsFixed(2)}%',
      );
      exitCode = 1;
    }
  } on CoverageGateException catch (error) {
    stderr.writeln('Error: ${error.message}');
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln('Error: ${error.message}');
    exitCode = 1;
  }
}

CoverageOptions _parseArgs(List<String> args) {
  var filePath = 'coverage/lcov.info';
  var minimumPercent = 0.0;

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];

    if (arg == '--help' || arg == '-h') {
      stdout.writeln(_usage());
      exit(0);
    }

    if (arg == '--file') {
      if (i + 1 >= args.length) {
        throw CoverageGateException('Missing value for --file.');
      }
      filePath = args[++i];
      continue;
    }

    if (arg.startsWith('--file=')) {
      filePath = arg.substring('--file='.length);
      continue;
    }

    if (arg == '--min') {
      if (i + 1 >= args.length) {
        throw CoverageGateException('Missing value for --min.');
      }
      minimumPercent = _parsePercent(args[++i]);
      continue;
    }

    if (arg.startsWith('--min=')) {
      minimumPercent = _parsePercent(arg.substring('--min='.length));
      continue;
    }

    throw CoverageGateException('Unknown argument: $arg');
  }

  if (filePath.trim().isEmpty) {
    throw CoverageGateException('Coverage file path cannot be empty.');
  }

  if (minimumPercent < 0) {
    throw CoverageGateException('Minimum coverage must be zero or greater.');
  }

  return CoverageOptions(filePath: filePath, minimumPercent: minimumPercent);
}

double _parsePercent(String value) {
  final parsed = double.tryParse(value);
  if (parsed == null) {
    throw CoverageGateException('Invalid coverage threshold: $value');
  }
  return parsed;
}

Future<CoverageSummary> _readCoverageSummary(String filePath) async {
  final file = File(filePath);

  final exists = await file.exists();
  if (!exists) {
    throw CoverageGateException('Coverage file not found: $filePath');
  }

  final stat = await file.stat();
  if (stat.type == FileSystemEntityType.directory) {
    throw CoverageGateException('Coverage file is a directory: $filePath');
  }

  final content = await file.readAsString();
  return _parseLcov(content, filePath);
}

CoverageSummary _parseLcov(String content, String filePath) {
  final lines = content.split(RegExp(r'\r?\n'));
  var totalLines = 0;
  var coveredLines = 0;
  var sawCoverageData = false;

  int? recordLf;
  int? recordLh;
  final recordHits = <int, int>{};
  var recordHasCoverageData = false;

  void flushRecord() {
    if (!recordHasCoverageData) {
      recordLf = null;
      recordLh = null;
      recordHits.clear();
      return;
    }

    sawCoverageData = true;

    if (recordLf != null && recordLh != null) {
      totalLines += recordLf!;
      coveredLines += recordLh!;
    } else if (recordLf == null && recordLh == null) {
      totalLines += recordHits.length;
      coveredLines += recordHits.values.where((hits) => hits > 0).length;
    } else if (recordHits.isNotEmpty) {
      totalLines += recordHits.length;
      coveredLines += recordHits.values.where((hits) => hits > 0).length;
    } else {
      throw CoverageGateException('Incomplete LCOV record found in $filePath.');
    }

    recordLf = null;
    recordLh = null;
    recordHits.clear();
    recordHasCoverageData = false;
  }

  for (var index = 0; index < lines.length; index++) {
    final rawLine = lines[index];
    final line = rawLine.trim();

    if (line.isEmpty) {
      continue;
    }

    if (line == 'end_of_record') {
      flushRecord();
      continue;
    }

    if (line.startsWith('SF:')) {
      if (recordHasCoverageData) {
        flushRecord();
      }
      continue;
    }

    if (line.startsWith('LF:')) {
      recordLf = _parseSingleIntField(line, 'LF', filePath, index + 1);
      recordHasCoverageData = true;
      continue;
    }

    if (line.startsWith('LH:')) {
      recordLh = _parseSingleIntField(line, 'LH', filePath, index + 1);
      recordHasCoverageData = true;
      continue;
    }

    if (line.startsWith('DA:')) {
      final data = line.substring(3).split(',');
      if (data.length < 2) {
        throw CoverageGateException(
          'Invalid DA line in $filePath at line ${index + 1}: $rawLine',
        );
      }

      final lineNumber = int.tryParse(data[0].trim());
      final hits = int.tryParse(data[1].trim());
      if (lineNumber == null || hits == null || lineNumber <= 0 || hits < 0) {
        throw CoverageGateException(
          'Invalid DA line in $filePath at line ${index + 1}: $rawLine',
        );
      }

      final existingHits = recordHits[lineNumber];
      if (existingHits == null || hits > existingHits) {
        recordHits[lineNumber] = hits;
      }

      recordHasCoverageData = true;
    }
  }

  flushRecord();

  if (!sawCoverageData) {
    throw CoverageGateException(
      'No LCOV line coverage data found in $filePath.',
    );
  }

  return CoverageSummary(coveredLines: coveredLines, totalLines: totalLines);
}

int _parseSingleIntField(
  String line,
  String field,
  String filePath,
  int lineNumber,
) {
  final value = line.substring(field.length + 1).trim();
  final parsed = int.tryParse(value);
  if (parsed == null || parsed < 0) {
    throw CoverageGateException(
      'Invalid $field line in $filePath at line $lineNumber: $line',
    );
  }
  return parsed;
}

String _usage() {
  return [
    'Usage:',
    '  dart run tool/coverage_gate.dart --file coverage/lcov.info --min 20',
    '',
    'Options:',
    '  --file   Path to the LCOV file. Default: coverage/lcov.info',
    '  --min    Minimum line coverage percent. Default: 0',
  ].join('\n');
}
