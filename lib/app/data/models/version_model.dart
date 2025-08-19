class ToolVersion {
  final String toolName;
  final String? detectedVersion;
  final String? preferredVersion;
  final String? currentVersion;
  final DateTime lastUpdated;
  final bool isUserDefined;

  ToolVersion({
    required this.toolName,
    this.detectedVersion,
    this.preferredVersion,
    this.currentVersion,
    required this.lastUpdated,
    this.isUserDefined = false,
  });

  ToolVersion copyWith({
    String? toolName,
    String? detectedVersion,
    String? preferredVersion,
    String? currentVersion,
    DateTime? lastUpdated,
    bool? isUserDefined,
  }) {
    return ToolVersion(
      toolName: toolName ?? this.toolName,
      detectedVersion: detectedVersion ?? this.detectedVersion,
      preferredVersion: preferredVersion ?? this.preferredVersion,
      currentVersion: currentVersion ?? this.currentVersion,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isUserDefined: isUserDefined ?? this.isUserDefined,
    );
  }

  // Get the version to use for testing (preferred over detected)
  String? get effectiveVersion => preferredVersion ?? detectedVersion;

  // Check if there's a version available
  bool get hasVersion => effectiveVersion != null;

  // Check if the version is user-defined
  bool get isCustomVersion => preferredVersion != null;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'toolName': toolName,
      'detectedVersion': detectedVersion,
      'preferredVersion': preferredVersion,
      'currentVersion': currentVersion,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isUserDefined': isUserDefined,
    };
  }

  // Create from JSON
  factory ToolVersion.fromJson(Map<String, dynamic> json) {
    return ToolVersion(
      toolName: json['toolName'] as String,
      detectedVersion: json['detectedVersion'] as String?,
      preferredVersion: json['preferredVersion'] as String?,
      currentVersion: json['currentVersion'] as String?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isUserDefined: json['isUserDefined'] as bool? ?? false,
    );
  }
}

class VersionTestResult {
  final String toolName;
  final String? version;
  final bool isAvailable;
  final String? errorMessage;
  final DateTime timestamp;

  VersionTestResult({
    required this.toolName,
    this.version,
    required this.isAvailable,
    this.errorMessage,
    required this.timestamp,
  });

  VersionTestResult copyWith({
    String? toolName,
    String? version,
    bool? isAvailable,
    String? errorMessage,
    DateTime? timestamp,
  }) {
    return VersionTestResult(
      toolName: toolName ?? this.toolName,
      version: version ?? this.version,
      isAvailable: isAvailable ?? this.isAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
