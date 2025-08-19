class FlutterInfo {
  final String? version;
  final String? channel;
  final String? framework;
  final String? engine;
  final String? dartVersion;
  final bool isInstalled;
  final String? errorMessage;

  FlutterInfo({
    this.version,
    this.channel,
    this.framework,
    this.engine,
    this.dartVersion,
    this.isInstalled = false,
    this.errorMessage,
  });

  FlutterInfo copyWith({
    String? version,
    String? channel,
    String? framework,
    String? engine,
    String? dartVersion,
    bool? isInstalled,
    String? errorMessage,
  }) {
    return FlutterInfo(
      version: version ?? this.version,
      channel: channel ?? this.channel,
      framework: framework ?? this.framework,
      engine: engine ?? this.engine,
      dartVersion: dartVersion ?? this.dartVersion,
      isInstalled: isInstalled ?? this.isInstalled,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AndroidSdkInfo {
  final String? sdkRoot;
  final List<String> platforms;
  final List<String> buildTools;
  final bool isConfigured;
  final String? errorMessage;

  AndroidSdkInfo({
    this.sdkRoot,
    this.platforms = const [],
    this.buildTools = const [],
    this.isConfigured = false,
    this.errorMessage,
  });

  AndroidSdkInfo copyWith({
    String? sdkRoot,
    List<String>? platforms,
    List<String>? buildTools,
    bool? isConfigured,
    String? errorMessage,
  }) {
    return AndroidSdkInfo(
      sdkRoot: sdkRoot ?? this.sdkRoot,
      platforms: platforms ?? this.platforms,
      buildTools: buildTools ?? this.buildTools,
      isConfigured: isConfigured ?? this.isConfigured,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DoctorIssue {
  final String category;
  final String title;
  final String description;
  final String severity; // 'info', 'warning', 'error'
  final List<String> details;

  DoctorIssue({
    required this.category,
    required this.title,
    required this.description,
    required this.severity,
    this.details = const [],
  });
}

class FlutterDoctorResult {
  final bool isHealthy;
  final List<DoctorIssue> issues;
  final String rawOutput;
  final String? errorMessage;

  FlutterDoctorResult({
    required this.isHealthy,
    required this.issues,
    required this.rawOutput,
    this.errorMessage,
  });
}

class PubPackageInfo {
  final String name;
  final String currentVersion;
  final String? latestVersion;
  final bool isOutdated;

  PubPackageInfo({
    required this.name,
    required this.currentVersion,
    this.latestVersion,
    this.isOutdated = false,
  });
}
