import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Connectivity Service for monitoring network status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  /// Stream controller for connectivity state
  final _connectivityController = StreamController<bool>.broadcast();
  
  /// Current connectivity state
  bool _isConnected = true;
  
  /// Subscription to connectivity changes
  StreamSubscription<ConnectivityResult>? _subscription;

  /// Get current connectivity state
  bool get isConnected => _isConnected;

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialize connectivity monitoring
  Future<void> init() async {
    // Check initial connectivity
    await _checkConnectivity();
    
    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectivity(result);
    });
  }

  /// Check current connectivity
  Future<bool> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectivity(result);
      return _isConnected;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  /// Update connectivity state
  void _updateConnectivity(ConnectivityResult result) {
    final wasConnected = _isConnected;
    
    // Check if result indicates connectivity
    _isConnected = result != ConnectivityResult.none;
    
    // Notify listeners if state changed
    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
      debugPrint('Connectivity changed: $_isConnected');
    }
  }

  /// Force check connectivity
  Future<bool> checkConnectivity() async {
    return await _checkConnectivity();
  }

  /// Get detailed connectivity type
  Future<ConnectivityType> getConnectivityType() async {
    final result = await _connectivity.checkConnectivity();
    
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectivityType.wifi;
      case ConnectivityResult.mobile:
        return ConnectivityType.mobile;
      case ConnectivityResult.ethernet:
        return ConnectivityType.ethernet;
      default:
        return ConnectivityType.none;
    }
  }

  /// Dispose of resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}

/// Connectivity type enum
enum ConnectivityType {
  wifi,
  mobile,
  ethernet,
  none,
}
