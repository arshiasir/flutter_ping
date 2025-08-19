enum CheckStatus {
  pending,
  running,
  success,
  failed,
  warning,
}

class CheckResult {
  final String name;
  final String description;
  final CheckStatus status;
  final String? details;
  final String? errorMessage;
  final DateTime timestamp;

  CheckResult({
    required this.name,
    required this.description,
    required this.status,
    this.details,
    this.errorMessage,
    required this.timestamp,
  });

  CheckResult copyWith({
    String? name,
    String? description,
    CheckStatus? status,
    String? details,
    String? errorMessage,
    DateTime? timestamp,
  }) {
    return CheckResult(
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      details: details ?? this.details,
      errorMessage: errorMessage ?? this.errorMessage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class NetworkCheckItem {
  final String url;
  final String name;
  final String description;
  final CheckStatus status;
  final int? httpCode;
  final String? errorMessage;

  NetworkCheckItem({
    required this.url,
    required this.name,
    required this.description,
    this.status = CheckStatus.pending,
    this.httpCode,
    this.errorMessage,
  });

  NetworkCheckItem copyWith({
    String? url,
    String? name,
    String? description,
    CheckStatus? status,
    int? httpCode,
    String? errorMessage,
  }) {
    return NetworkCheckItem(
      url: url ?? this.url,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      httpCode: httpCode ?? this.httpCode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}