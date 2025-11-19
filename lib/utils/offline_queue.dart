import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sync_operation.dart';
import 'constants.dart';

class OfflineQueue {
  static final OfflineQueue _instance = OfflineQueue._internal();
  factory OfflineQueue() => _instance;
  OfflineQueue._internal();

  List<SyncOperation> _operations = [];
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final operationsJson = prefs.getStringList(AppConstants.offlineQueueKey);
      
      if (operationsJson != null) {
        _operations = operationsJson.map((jsonString) {
          try {
            return SyncOperation.fromJson(json.decode(jsonString));
          } catch (e) {
            return null;
          }
        }).where((op) => op != null).cast<SyncOperation>().toList();
      }
      
      _initialized = true;
    } catch (e) {
      _operations = [];
      _initialized = true;
    }
  }

  Future<void> addOperation(SyncOperation operation) async {
    await _ensureInitialized();
    
    if (!operation.isValid()) {
      throw ArgumentError('Invalid operation: $operation');
    }

    _operations.add(operation);
    await _saveToStorage();
    
  }

  List<SyncOperation> getPendingOperations() {
    return List<SyncOperation>.from(_operations);
  }

  List<SyncOperation> getOperationsByType(String type) {
    return _operations.where((op) => op.type == type).toList();
  }

  Future<void> removeOperation(SyncOperation operation) async {
    await _ensureInitialized();
    _operations.remove(operation);
    await _saveToStorage();
  }

  Future<void> removeOperationById(String localId) async {
    await _ensureInitialized();
    _operations.removeWhere((op) => op.localId == localId);
    await _saveToStorage();
  }

  Future<void> clearOperations() async {
    await _ensureInitialized();
    _operations.clear();
    await _saveToStorage();
  }

  int get pendingCount => _operations.length;

  bool get hasPendingOperations => _operations.isNotEmpty;

  Map<String, int> getQueueStats() {
    final stats = <String, int>{};
    for (final op in _operations) {
      stats[op.type] = (stats[op.type] ?? 0) + 1;
    }
    return stats;
  }

  Future<void> cleanupOldOperations() async {
    await _ensureInitialized();
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
    
    final initialCount = _operations.length;
    _operations.removeWhere((op) => op.timestamp.isBefore(cutoffDate));
    
    if (_operations.length != initialCount) {
      await _saveToStorage();
    }
  }

  // Guardar en almacenamiento local
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final operationsJson = _operations.map((op) => json.encode(op.toJson())).toList();
      await prefs.setStringList(AppConstants.offlineQueueKey, operationsJson);
    // ignore: empty_catches
    } catch (e) {
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  @override
  String toString() {
    return 'OfflineQueue(operations: ${_operations.length})';
  }
}