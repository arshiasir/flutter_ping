import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../models/url_model.dart';
import 'version_service.dart';

class NetworkService extends GetxService {
  static NetworkService get instance => Get.find<NetworkService>();

  late final Dio _dio;

  final List<NetworkCheckItem> _criticalUrls = [
    NetworkCheckItem(
      url:
          "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json",
      name: "Flutter SDK",
      description:
          "Flutter SDK releases repository - Required for Flutter updates and downloads",
    ),
    NetworkCheckItem(
      url:
          "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip",
      name: "Dart SDK",
      description: "Dart SDK archive - Core language runtime and compiler",
    ),
    NetworkCheckItem(
      url: "https://services.gradle.org/distributions/gradle-8.7-all.zip",
      name: "Gradle Wrapper",
      description:
          "Gradle build automation tool - Essential for Android builds",
    ),
    NetworkCheckItem(
      url:
          "https://dl.google.com/dl/android/maven2/com/android/tools/build/gradle/8.0.2/gradle-8.0.2.pom",
      name: "Android Gradle Plugin",
      description: "Android build tools - Required for Android app compilation",
    ),
    NetworkCheckItem(
      url:
          "https://dl.google.com/dl/android/maven2/androidx/core/core/1.10.1/core-1.10.1.pom",
      name: "Google Maven (AndroidX)",
      description:
          "AndroidX libraries repository - Modern Android support libraries",
    ),
    NetworkCheckItem(
      url:
          "https://repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.12.0/commons-lang3-3.12.0.pom",
      name: "Maven Central",
      description: "Central Maven repository - Java/Kotlin dependency source",
    ),
    NetworkCheckItem(
      url: "https://pub.dev/api/packages/provider",
      name: "pub.dev packages",
      description:
          "Dart/Flutter package repository - Essential for package management",
    ),
    NetworkCheckItem(
      url: "https://cdn.cocoapods.org/all_pods_versions_0_3_5.txt.gz",
      name: "CocoaPods",
      description:
          "iOS dependency manager - Required for iOS builds with native dependencies",
    ),
    NetworkCheckItem(
      url: "https://github.com/flutter/flutter",
      name: "GitHub",
      description:
          "Source code repository - Used for package downloads and version control",
    ),
    NetworkCheckItem(
      url: "https://marketplace.visualstudio.com/_apis/public/gallery",
      name: "VSCode Marketplace",
      description:
          "Visual Studio Code extensions - Development tools and Flutter support",
    ),
    NetworkCheckItem(
      url:
          "https://dl.google.com/android/repository/sys-img/android/sys-img2-33_r01.zip",
      name: "Android Emulator System Image",
      description:
          "Android emulator images - Required for device testing and debugging",
    ),
    NetworkCheckItem(
      url: "https://nodejs.org/dist/v20.6.0/node-v20.6.0-x64.msi",
      name: "Node.js",
      description:
          "JavaScript runtime - Used by various development tools and web builds",
    ),
    NetworkCheckItem(
      url: "https://pub.dev/packages/devtools",
      name: "Flutter DevTools",
      description:
          "Flutter debugging and profiling tools - Essential for development",
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );
  }

  List<NetworkCheckItem> get criticalUrls => List.unmodifiable(_criticalUrls);

  // Get URLs with version preferences applied
  List<NetworkCheckItem> getUrlsWithVersions() {
    try {
      final versionService = Get.find<VersionService>();
      final urls = <NetworkCheckItem>[];

      for (final item in _criticalUrls) {
        String url = item.url;

        // Apply version preferences for specific tools
        if (item.name.contains('Gradle') || item.url.contains('gradle')) {
          final gradleVersion = versionService.getToolVersion('gradle');
          if (gradleVersion?.effectiveVersion != null) {
            url = url.replaceAll(
              RegExp(r'gradle-\d+\.\d+(?:\.\d+)?'),
              'gradle-${gradleVersion!.effectiveVersion}',
            );
          }
        } else if (item.name.contains('Android Gradle Plugin') ||
            item.url.contains('gradle-8.0.2')) {
          final gradleVersion = versionService.getToolVersion('gradle');
          if (gradleVersion?.effectiveVersion != null) {
            // Map Gradle version to compatible Android Gradle Plugin version
            final pluginVersion = _getCompatiblePluginVersion(
              gradleVersion!.effectiveVersion!,
            );
            if (pluginVersion != null) {
              url = url.replaceAll('gradle-8.0.2', 'gradle-$pluginVersion');
            }
          }
        }

        urls.add(item.copyWith(url: url));
      }

      return urls;
    } catch (e) {
      // If version service is not available, return original URLs
      return _criticalUrls;
    }
  }

  // Get compatible Android Gradle Plugin version for a given Gradle version
  String? _getCompatiblePluginVersion(String gradleVersion) {
    final version = double.tryParse(gradleVersion.split('.').take(2).join('.'));
    if (version == null) return null;

    // Compatibility matrix (simplified)
    if (version >= 8.0 && version < 8.1) return '8.0.2';
    if (version >= 8.1 && version < 8.2) return '8.1.4';
    if (version >= 8.2 && version < 8.3) return '8.2.2';
    if (version >= 8.3 && version < 8.4) return '8.3.2';
    if (version >= 8.4 && version < 8.5) return '8.4.2';
    if (version >= 8.5 && version < 8.6) return '8.5.2';
    if (version >= 8.6 && version < 8.7) return '8.6.2';
    if (version >= 8.7 && version < 8.8) return '8.7.2';
    if (version >= 8.8 && version < 8.9) return '8.8.2';
    if (version >= 8.9 && version < 9.0) return '8.9.2';

    return null;
  }

  Future<NetworkCheckItem> checkUrl(NetworkCheckItem item) async {
    try {
      final response = await _dio.head(item.url);

      if (response.statusCode == 200) {
        return item.copyWith(
          status: CheckStatus.success,
          httpCode: response.statusCode,
        );
      } else {
        return item.copyWith(
          status: CheckStatus.warning,
          httpCode: response.statusCode,
          errorMessage: 'HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage;
      CheckStatus status = CheckStatus.failed;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage = 'Timeout - Check your internet connection';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Connection failed - Network unreachable';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'HTTP ${e.response?.statusCode ?? 'Error'}';
          status = CheckStatus.warning;
          break;
        default:
          errorMessage = e.message ?? 'Unknown network error';
      }

      return item.copyWith(
        status: status,
        httpCode: e.response?.statusCode,
        errorMessage: errorMessage,
      );
    } catch (e) {
      return item.copyWith(
        status: CheckStatus.failed,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  Future<List<NetworkCheckItem>> checkAllUrls({
    Function(NetworkCheckItem)? onProgress,
    List<NetworkCheckItem>? urls,
  }) async {
    final itemsToCheck = urls ?? _criticalUrls;
    final results = <NetworkCheckItem>[];

    for (final item in itemsToCheck) {
      onProgress?.call(item.copyWith(status: CheckStatus.running));
      final result = await checkUrl(item);
      results.add(result);
      onProgress?.call(result);
    }

    return results;
  }

  Future<bool> isNetworkAvailable() async {
    // Basic network availability check
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
