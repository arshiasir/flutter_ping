import 'dart:io';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import '../models/system_info_model.dart';

class AndroidService extends GetxService {
  static AndroidService get instance => Get.find<AndroidService>();

  Future<AndroidSdkInfo> getAndroidSdkInfo() async {
    try {
      final sdkRoot = _getAndroidSdkRoot();
      
      if (sdkRoot == null) {
        return AndroidSdkInfo(
          isConfigured: false,
          errorMessage: 'ANDROID_SDK_ROOT environment variable not set',
        );
      }

      final sdkDir = Directory(sdkRoot);
      if (!sdkDir.existsSync()) {
        return AndroidSdkInfo(
          sdkRoot: sdkRoot,
          isConfigured: false,
          errorMessage: 'Android SDK directory does not exist: $sdkRoot',
        );
      }

      final platforms = await _getInstalledPlatforms(sdkRoot);
      final buildTools = await _getInstalledBuildTools(sdkRoot);

      return AndroidSdkInfo(
        sdkRoot: sdkRoot,
        platforms: platforms,
        buildTools: buildTools,
        isConfigured: true,
      );
    } catch (e) {
      return AndroidSdkInfo(
        isConfigured: false,
        errorMessage: 'Error checking Android SDK: $e',
      );
    }
  }

  String? _getAndroidSdkRoot() {
    // Check various environment variables and common locations
    final envVars = [
      'ANDROID_SDK_ROOT',
      'ANDROID_HOME',
      'ANDROID_SDK_HOME',
    ];

    for (final envVar in envVars) {
      final value = Platform.environment[envVar];
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    // Check common installation locations
    final commonPaths = [
      if (Platform.isWindows) ...[
        r'C:\Users\%USERNAME%\AppData\Local\Android\Sdk',
        r'C:\Android\Sdk',
        r'C:\Program Files\Android\Sdk',
        r'C:\Program Files (x86)\Android\Sdk',
      ],
      if (Platform.isMacOS) ...[
        '${Platform.environment['HOME']}/Library/Android/sdk',
        '/Applications/Android Studio.app/Contents/plugins/android/lib/android.jar',
      ],
      if (Platform.isLinux) ...[
        '${Platform.environment['HOME']}/Android/Sdk',
        '/opt/android-sdk',
        '/usr/lib/android-sdk',
      ],
    ];

    for (final commonPath in commonPaths) {
      final expandedPath = commonPath.replaceAll('%USERNAME%', 
          Platform.environment['USERNAME'] ?? Platform.environment['USER'] ?? '');
      if (Directory(expandedPath).existsSync()) {
        return expandedPath;
      }
    }

    return null;
  }

  Future<List<String>> _getInstalledPlatforms(String sdkRoot) async {
    final platformsDir = Directory(path.join(sdkRoot, 'platforms'));
    
    if (!platformsDir.existsSync()) {
      return [];
    }

    try {
      final platforms = <String>[];
      await for (final entity in platformsDir.list()) {
        if (entity is Directory) {
          final dirName = path.basename(entity.path);
          if (dirName.startsWith('android-')) {
            platforms.add(dirName);
          }
        }
      }
      platforms.sort();
      return platforms;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> _getInstalledBuildTools(String sdkRoot) async {
    final buildToolsDir = Directory(path.join(sdkRoot, 'build-tools'));
    
    if (!buildToolsDir.existsSync()) {
      return [];
    }

    try {
      final buildTools = <String>[];
      await for (final entity in buildToolsDir.list()) {
        if (entity is Directory) {
          final dirName = path.basename(entity.path);
          buildTools.add(dirName);
        }
      }
      buildTools.sort((a, b) => _compareVersions(b, a)); // Sort descending
      return buildTools;
    } catch (e) {
      return [];
    }
  }

  int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.tryParse).where((v) => v != null).cast<int>().toList();
    final v2Parts = version2.split('.').map(int.tryParse).where((v) => v != null).cast<int>().toList();

    final maxLength = v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;
    
    for (int i = 0; i < maxLength; i++) {
      final v1 = i < v1Parts.length ? v1Parts[i] : 0;
      final v2 = i < v2Parts.length ? v2Parts[i] : 0;
      
      if (v1 != v2) {
        return v1.compareTo(v2);
      }
    }
    
    return 0;
  }

  Future<bool> checkAdbAvailable() async {
    try {
      final result = await Process.run('adb', ['version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getConnectedDevices() async {
    try {
      final result = await Process.run('adb', ['devices']);
      if (result.exitCode != 0) return [];

      final lines = result.stdout.toString().split('\n');
      final devices = <String>[];
      
      for (final line in lines.skip(1)) { // Skip header line
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && !trimmed.startsWith('*')) {
          final parts = trimmed.split('\t');
          if (parts.length >= 2 && parts[1] == 'device') {
            devices.add(parts[0]);
          }
        }
      }
      
      return devices;
    } catch (e) {
      return [];
    }
  }

  String getAndroidSdkStatusDescription(AndroidSdkInfo info) {
    if (!info.isConfigured) {
      return '''
Android SDK Configuration Issue:
${info.errorMessage ?? 'Unknown error'}

The Android SDK is required for:
• Building Android apps
• Running Android emulators
• Debugging on Android devices
• Using Android build tools

To fix this:
1. Install Android Studio or Android SDK
2. Set ANDROID_SDK_ROOT environment variable
3. Ensure SDK includes platforms and build-tools
''';
    }

    final buffer = StringBuffer();
    buffer.writeln('Android SDK Status: ✅ Configured');
    buffer.writeln('SDK Root: ${info.sdkRoot}');
    buffer.writeln('');
    
    if (info.platforms.isNotEmpty) {
      buffer.writeln('Installed Platforms (${info.platforms.length}):');
      for (final platform in info.platforms.take(5)) {
        buffer.writeln('  • $platform');
      }
      if (info.platforms.length > 5) {
        buffer.writeln('  • ... and ${info.platforms.length - 5} more');
      }
    } else {
      buffer.writeln('⚠️ No Android platforms found');
    }
    
    buffer.writeln('');
    
    if (info.buildTools.isNotEmpty) {
      buffer.writeln('Installed Build Tools (${info.buildTools.length}):');
      for (final tool in info.buildTools.take(3)) {
        buffer.writeln('  • $tool');
      }
      if (info.buildTools.length > 3) {
        buffer.writeln('  • ... and ${info.buildTools.length - 3} more');
      }
    } else {
      buffer.writeln('⚠️ No build tools found');
    }

    return buffer.toString();
  }
}
