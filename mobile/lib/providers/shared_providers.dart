import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';
import '../services/connectivity_service.dart';
import '../services/notification_service.dart';

/// Service providers that need to be overridden with initialized instances
/// These are overridden in main.dart with properly initialized services

/// Hive service provider - overridden in main.dart
final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('hiveServiceProvider must be overridden in ProviderScope');
});

/// Connectivity service provider - overridden in main.dart  
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  throw UnimplementedError('connectivityServiceProvider must be overridden in ProviderScope');
});

/// Notification service provider - overridden in main.dart
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('notificationServiceProvider must be overridden in ProviderScope');
});
