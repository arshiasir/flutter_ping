import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/version_model.dart';

class VersionService extends GetxService {
  static VersionService get instance => Get.find<VersionService>();
  
  static const String _preferencesKey = 'tool_versions';
  late final SharedPreferences _prefs;
  
  // Observable state for tool versions
  final RxMap<String, ToolVersion> _toolVersions = <String, ToolVersion>{}.obs;
  
  // Getter for tool versions
  Map<String, ToolVersion> get toolVersions => Map.unmodifiable(_toolVersions);
  
  @override
  void onInit() async {
    super.onInit();
    await _initializePreferences();
    await _loadStoredVersions();
  }
  
  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  Future<void> _loadStoredVersions() async {
    final storedData = _prefs.getString(_preferencesKey);
    if (storedData != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(storedData);
        for (final json in jsonList) {
          final toolVersion = ToolVersion.fromJson(json);
          _toolVersions[toolVersion.toolName] = toolVersion;
        }
      } catch (e) {
        // If parsing fails, clear stored data
        await _prefs.remove(_preferencesKey);
      }
    }
  }
  
  Future<void> _saveVersions() async {
    final versionsList = _toolVersions.values.map((v) => v.toJson()).toList();
    final jsonData = jsonEncode(versionsList);
    await _prefs.setString(_preferencesKey, jsonData);
  }
  
  // Detect version of a tool from the system
  Future<ToolVersion> detectToolVersion(String toolName) async {
    String? detectedVersion;
    String? errorMessage;
    
    try {
      switch (toolName.toLowerCase()) {
        case 'gradle':
          detectedVersion = await _detectGradleVersion();
          break;
        case 'java':
          detectedVersion = await _detectJavaVersion();
          break;
        case 'kotlin':
          detectedVersion = await _detectKotlinVersion();
          break;
        case 'android':
          detectedVersion = await _detectAndroidVersion();
          break;
        case 'flutter':
          detectedVersion = await _detectFlutterVersion();
          break;
        case 'dart':
          detectedVersion = await _detectDartVersion();
          break;
        default:
          errorMessage = 'Tool detection not implemented for: $toolName';
      }
    } catch (e) {
      errorMessage = 'Error detecting version: $e';
    }
    
    final toolVersion = ToolVersion(
      toolName: toolName,
      detectedVersion: detectedVersion,
      lastUpdated: DateTime.now(),
    );
    
    // Update stored version
    _toolVersions[toolName] = toolVersion;
    await _saveVersions();
    
    return toolVersion;
  }
  
  // Set a user-preferred version for a tool
  Future<ToolVersion> setPreferredVersion(String toolName, String version) async {
    final existing = _toolVersions[toolName];
    
    final toolVersion = ToolVersion(
      toolName: toolName,
      detectedVersion: existing?.detectedVersion,
      preferredVersion: version,
      lastUpdated: DateTime.now(),
      isUserDefined: true,
    );
    
    _toolVersions[toolName] = toolVersion;
    await _saveVersions();
    
    return toolVersion;
  }
  
  // Clear user preference and use detected version
  Future<ToolVersion> clearPreferredVersion(String toolName) async {
    final existing = _toolVersions[toolName];
    
    final toolVersion = ToolVersion(
      toolName: toolName,
      detectedVersion: existing?.detectedVersion,
      lastUpdated: DateTime.now(),
      isUserDefined: false,
    );
    
    _toolVersions[toolName] = toolVersion;
    await _saveVersions();
    
    return toolVersion;
  }
  
  // Get the effective version for a tool (preferred over detected)
  ToolVersion? getToolVersion(String toolName) {
    return _toolVersions[toolName];
  }
  
  // Test a specific version of a tool
  Future<VersionTestResult> testToolVersion(String toolName, String version) async {
    try {
      bool isAvailable = false;
      String? errorMessage;
      
      switch (toolName.toLowerCase()) {
        case 'gradle':
          isAvailable = await _testGradleVersion(version);
          break;
        case 'java':
          isAvailable = await _testJavaVersion(version);
          break;
        case 'kotlin':
          isAvailable = await _testKotlinVersion(version);
          break;
        case 'android':
          isAvailable = await _testAndroidVersion(version);
          break;
        case 'flutter':
          isAvailable = await _testFlutterVersion(version);
          break;
        case 'dart':
          isAvailable = await _testDartVersion(version);
          break;
        default:
          errorMessage = 'Version testing not implemented for: $toolName';
      }
      
      if (!isAvailable && errorMessage == null) {
        errorMessage = 'Version $version is not available for $toolName';
      }
      
      return VersionTestResult(
        toolName: toolName,
        version: version,
        isAvailable: isAvailable,
        errorMessage: errorMessage,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return VersionTestResult(
        toolName: toolName,
        version: version,
        isAvailable: false,
        errorMessage: 'Error testing version: $e',
        timestamp: DateTime.now(),
      );
    }
  }
  
  // Private methods for version detection
  Future<String?> _detectGradleVersion() async {
    try {
      final result = await Process.run('gradle', ['--version']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        // Parse Gradle version from output
        final match = RegExp(r'Gradle\s+(\d+\.\d+(?:\.\d+)?)').firstMatch(output);
        return match?.group(1);
      }
    } catch (e) {
      // Gradle not found in PATH
    }
    
    // Try to detect from gradle wrapper
    try {
      if (File('gradle/wrapper/gradle-wrapper.properties').existsSync()) {
        final content = await File('gradle/wrapper/gradle-wrapper.properties').readAsString();
        final match = RegExp(r'distributionUrl.*gradle-(\d+\.\d+(?:\.\d+)?)').firstMatch(content);
        return match?.group(1);
      }
    } catch (e) {
      // Error reading gradle wrapper
    }
    
    return null;
  }
  
  Future<String?> _detectJavaVersion() async {
    try {
      final result = await Process.run('java', ['-version']);
      if (result.exitCode == 0) {
        final output = result.stderr.toString(); // Java version is printed to stderr
        final match = RegExp(r'"(\d+\.\d+(?:\.\d+)?)"').firstMatch(output);
        return match?.group(1);
      }
    } catch (e) {
      // Java not found in PATH
    }
    return null;
  }
  
  Future<String?> _detectKotlinVersion() async {
    try {
      final result = await Process.run('kotlin', ['-version']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final match = RegExp(r'(\d+\.\d+(?:\.\d+)?)').firstMatch(output);
        return match?.group(1);
      }
    } catch (e) {
      // Kotlin not found in PATH
    }
    return null;
  }
  
  Future<String?> _detectAndroidVersion() async {
    try {
      final result = await Process.run('adb', ['version']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final match = RegExp(r'Android Debug Bridge version (\d+\.\d+(?:\.\d+)?)').firstMatch(output);
        return match?.group(1);
      }
    } catch (e) {
      // ADB not found in PATH
    }
    return null;
  }
  
  Future<String?> _detectFlutterVersion() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final match = RegExp(r'Flutter\s+(\d+\.\d+(?:\.\d+)?)').firstMatch(output);
        return match?.group(1);
      }
    } catch (e) {
      // Flutter not found in PATH
    }
    return null;
  }
  
  Future<String?> _detectDartVersion() async {
    try {
      final result = await Process.run('dart', ['--version']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final match = RegExp(r'Dart VM version: (\d+\.\d+(?:\.\d+)?)').firstMatch(output);
        return match?.group(1);
      }
    } catch (e) {
      // Dart not found in PATH
    }
    return null;
  }
  
  // Private methods for version testing
  Future<bool> _testGradleVersion(String version) async {
    try {
      // Test if Gradle version is available for download
      final url = 'https://services.gradle.org/distributions/gradle-$version-all.zip';
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      client.close();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> _testJavaVersion(String version) async {
    try {
      final result = await Process.run('java', ['-version']);
      if (result.exitCode == 0) {
        final output = result.stderr.toString();
        return output.contains(version);
      }
    } catch (e) {
      // Java not found
    }
    return false;
  }
  
  Future<bool> _testKotlinVersion(String version) async {
    try {
      final result = await Process.run('kotlin', ['-version']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        return output.contains(version);
      }
    } catch (e) {
      // Kotlin not found
    }
    return false;
  }
  
  Future<bool> _testAndroidVersion(String version) async {
    try {
      final result = await Process.run('adb', ['version']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        return output.contains(version);
      }
    } catch (e) {
      // ADB not found
    }
    return false;
  }
  
  Future<bool> _testFlutterVersion(String version) async {
    try {
      final result = await Process.run('flutter', ['--version']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        return output.contains(version);
      }
    } catch (e) {
      // Flutter not found
    }
    return false;
  }
  
  Future<bool> _testDartVersion(String version) async {
    try {
      final result = await Process.run('dart', ['--version']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        return output.contains(version);
      }
    } catch (e) {
      // Dart not found
    }
    return false;
  }
  
  // Refresh all tool versions
  Future<void> refreshAllVersions() async {
    final toolNames = ['gradle', 'java', 'kotlin', 'android', 'flutter', 'dart'];
    
    for (final toolName in toolNames) {
      await detectToolVersion(toolName);
    }
  }
  
  // Clear all stored versions
  Future<void> clearAllVersions() async {
    _toolVersions.clear();
    await _prefs.remove(_preferencesKey);
  }
}
