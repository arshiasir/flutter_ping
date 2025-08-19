import 'package:get/get.dart';
import 'package:process_run/process_run.dart';
import '../models/system_info_model.dart';
import '../models/url_model.dart';

class FlutterService extends GetxService {
  static FlutterService get instance => Get.find<FlutterService>();
  
  final Shell __shell = Shell();

  Future<FlutterInfo> getFlutterVersion() async {
    try {
      final result = await _shell.run('flutter --version');
      
      if (result.isNotEmpty && result.first.exitCode == 0) {
        final output = result.first.stdout.toString();
        return _parseFlutterVersion(output);
      } else {
        return FlutterInfo(
          isInstalled: false,
          errorMessage: 'Flutter command failed: ${result.isNotEmpty ? result.first.stderr : 'No output'}',
        );
      }
    } catch (e) {
      return FlutterInfo(
        isInstalled: false,
        errorMessage: 'Flutter not found: $e',
      );
    }
  }

  FlutterInfo _parseFlutterVersion(String output) {
    final lines = output.split('\n');
    String? version, channel, framework, engine, dartVersion;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Flutter ')) {
        // Parse: Flutter 3.16.0 • channel stable • https://github.com/flutter/flutter.git
        final parts = trimmed.split(' • ');
        if (parts.isNotEmpty) {
          version = parts[0].replaceFirst('Flutter ', '');
        }
        if (parts.length > 1) {
          channel = parts[1].replaceFirst('channel ', '');
        }
      } else if (trimmed.startsWith('Framework •')) {
        framework = trimmed.replaceFirst('Framework • revision ', '');
      } else if (trimmed.startsWith('Engine •')) {
        engine = trimmed.replaceFirst('Engine • revision ', '');
      } else if (trimmed.startsWith('Tools •')) {
        dartVersion = trimmed.replaceFirst('Tools • Dart ', '').split(' ').first;
      }
    }

    return FlutterInfo(
      version: version,
      channel: channel,
      framework: framework,
      engine: engine,
      dartVersion: dartVersion,
      isInstalled: true,
    );
  }

  Future<FlutterDoctorResult> runFlutterDoctor() async {
    try {
      final result = await _shell.run('flutter doctor -v');
      final output = result.first.stdout.toString();
      
      final issues = _parseDoctorOutput(output);
      final isHealthy = issues.where((issue) => issue.severity == 'error').isEmpty;
      
      return FlutterDoctorResult(
        isHealthy: isHealthy,
        issues: issues,
        rawOutput: output,
      );
    } catch (e) {
      return FlutterDoctorResult(
        isHealthy: false,
        issues: [],
        rawOutput: '',
        errorMessage: 'Failed to run flutter doctor: $e',
      );
    }
  }

  List<DoctorIssue> _parseDoctorOutput(String output) {
    final issues = <DoctorIssue>[];
    final lines = output.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.startsWith('[✓]')) {
        // Success case - can be ignored or marked as info
        continue;
      } else if (line.startsWith('[✗]')) {
        // Error case
        final title = line.replaceFirst('[✗] ', '');
        final details = <String>[];
        
        // Collect details from following lines
        for (int j = i + 1; j < lines.length && j < i + 10; j++) {
          final detailLine = lines[j].trim();
          if (detailLine.startsWith('[') || detailLine.isEmpty) break;
          if (detailLine.startsWith('•') || detailLine.startsWith('!')) {
            details.add(detailLine);
          }
        }
        
        issues.add(DoctorIssue(
          category: 'Error',
          title: title,
          description: 'This component has critical issues that need to be resolved.',
          severity: 'error',
          details: details,
        ));
      } else if (line.startsWith('[!]')) {
        // Warning case
        final title = line.replaceFirst('[!] ', '');
        final details = <String>[];
        
        for (int j = i + 1; j < lines.length && j < i + 10; j++) {
          final detailLine = lines[j].trim();
          if (detailLine.startsWith('[') || detailLine.isEmpty) break;
          if (detailLine.startsWith('•') || detailLine.startsWith('!')) {
            details.add(detailLine);
          }
        }
        
        issues.add(DoctorIssue(
          category: 'Warning',
          title: title,
          description: 'This component has warnings that should be addressed.',
          severity: 'warning',
          details: details,
        ));
      }
    }
    
    return issues;
  }

  Future<CheckResult> checkForUpdates() async {
    try {
      final result = await _shell.run('flutter upgrade --dry-run');
      final output = result.first.stdout.toString();
      
      if (output.contains('Flutter is already up to date')) {
        return CheckResult(
          name: 'Flutter Updates',
          description: 'Check for available Flutter updates',
          status: CheckStatus.success,
          details: 'Flutter is up to date',
          timestamp: DateTime.now(),
        );
      } else if (output.contains('A new version of Flutter is available')) {
        return CheckResult(
          name: 'Flutter Updates',
          description: 'Check for available Flutter updates',
          status: CheckStatus.warning,
          details: 'Updates are available:\n$output',
          timestamp: DateTime.now(),
        );
      } else {
        return CheckResult(
          name: 'Flutter Updates',
          description: 'Check for available Flutter updates',
          status: CheckStatus.success,
          details: output,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      return CheckResult(
        name: 'Flutter Updates',
        description: 'Check for available Flutter updates',
        status: CheckStatus.failed,
        errorMessage: 'Failed to check for updates: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  Future<List<PubPackageInfo>> checkPubOutdated() async {
    try {
      final result = await _shell.run('flutter pub outdated --json');
      
      if (result.isEmpty || result.first.exitCode != 0) {
        // Try without --json flag
        final fallbackResult = await _shell.run('flutter pub outdated');
        return _parsePubOutdatedText(fallbackResult.first.stdout.toString());
      }
      
      // Parse JSON output if available
      return _parsePubOutdatedJson(result.first.stdout.toString());
    } catch (e) {
      return [];
    }
  }

  List<PubPackageInfo> _parsePubOutdatedJson(String jsonOutput) {
    // This would require JSON parsing, for now return empty list
    // In a real implementation, you'd parse the JSON structure
    return [];
  }

  List<PubPackageInfo> _parsePubOutdatedText(String textOutput) {
    final packages = <PubPackageInfo>[];
    final lines = textOutput.split('\n');
    
    for (final line in lines) {
      // Parse lines like: "package_name  1.0.0  1.1.0  1.1.0"
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length >= 3 && !parts[0].startsWith('Package') && parts[0].isNotEmpty) {
        packages.add(PubPackageInfo(
          name: parts[0],
          currentVersion: parts[1],
          latestVersion: parts.length > 2 ? parts[2] : null,
          isOutdated: parts.length > 2 && parts[1] != parts[2],
        ));
      }
    }
    
    return packages;
  }
}
