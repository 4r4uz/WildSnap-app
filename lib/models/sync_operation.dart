class SyncOperation {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? localId;
  final int retryCount;

  SyncOperation({
    required this.type,
    required this.data,
    required this.timestamp,
    this.localId,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'localId': localId,
      'retryCount': retryCount,
    };
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      type: json['type'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
      localId: json['localId'],
      retryCount: json['retryCount'] ?? 0,
    );
  }

  SyncOperation copyWithRetry() {
    return SyncOperation(
      type: type,
      data: data,
      timestamp: timestamp,
      localId: localId,
      retryCount: retryCount + 1,
    );
  }

  bool isValid() {
    return type.isNotEmpty && data.isNotEmpty;
  }

  @override
  String toString() {
    return 'SyncOperation(type: $type, localId: $localId, retryCount: $retryCount)';
  }
}