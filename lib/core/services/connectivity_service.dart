import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity service
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  
  bool _isConnected = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);

      // Listen for changes
      _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    } catch (e) {
      debugPrint('Failed to initialize connectivity: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = results.any((result) => 
      result != ConnectivityResult.none,
    );

    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
      
      if (_isConnected) {
        debugPrint('Connection restored');
      } else {
        debugPrint('Connection lost');
      }
    }
  }

  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Check if currently connected
  bool get isConnected => _isConnected;

  /// Check if currently on mobile data
  Future<bool> get isOnMobileData async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.mobile);
    } catch (e) {
      return false;
    }
  }

  /// Check if currently on WiFi
  Future<bool> get isOnWifi async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.wifi);
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
