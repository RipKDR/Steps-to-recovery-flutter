import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'logger_service.dart';

/// Network connectivity service
class ConnectivityService {
  static final Connectivity _plugin = Connectivity();
  static final ConnectivityService _instance = ConnectivityService._(
    checkConnectivity: () => _plugin.checkConnectivity(),
    onConnectivityChanged: _plugin.onConnectivityChanged,
  );

  factory ConnectivityService() => _instance;

  ConnectivityService._({
    required Future<List<ConnectivityResult>> Function() checkConnectivity,
    required Stream<List<ConnectivityResult>> onConnectivityChanged,
  })  : _checkConnectivity = checkConnectivity,
        _onConnectivityChanged = onConnectivityChanged;

  final Future<List<ConnectivityResult>> Function() _checkConnectivity;
  final Stream<List<ConnectivityResult>> _onConnectivityChanged;

  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  bool _isConnected = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      final results = await _checkConnectivity();
      _updateConnectionStatus(results);

      _subscription =
          _onConnectivityChanged.listen(_updateConnectionStatus);
    } catch (e, stackTrace) {
      LoggerService().error(
        'Failed to initialize connectivity',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);

      if (_isConnected) {
        LoggerService().debug('Connection restored');
      } else {
        LoggerService().debug('Connection lost');
      }
    }
  }

  /// For tests: push connectivity results without going through the plugin.
  @visibleForTesting
  void applyConnectivityResultsForTest(List<ConnectivityResult> results) {
    _updateConnectionStatus(results);
  }

  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Check if currently connected
  bool get isConnected => _isConnected;

  /// Check if currently on mobile data
  Future<bool> get isOnMobileData async {
    try {
      final results = await _checkConnectivity();
      return results.contains(ConnectivityResult.mobile);
    } catch (e) {
      return false;
    }
  }

  /// Check if currently on WiFi
  Future<bool> get isOnWifi async {
    try {
      final results = await _checkConnectivity();
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

/// Builds a non-singleton [ConnectivityService] for tests with fake streams.
@visibleForTesting
ConnectivityService createConnectivityServiceForTesting({
  required Future<List<ConnectivityResult>> Function() checkConnectivity,
  required Stream<List<ConnectivityResult>> onConnectivityChanged,
}) {
  return ConnectivityService._(
    checkConnectivity: checkConnectivity,
    onConnectivityChanged: onConnectivityChanged,
  );
}
