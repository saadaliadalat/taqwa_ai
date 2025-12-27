import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/connectivity_service.dart';
import 'app.dart';

/// Background message handler - must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
  debugPrint('Background message: ${message.messageId}');
}

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Hive for local storage
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize connectivity service
  final connectivityService = ConnectivityService();
  await connectivityService.init();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();

  // Run the app wrapped in ProviderScope
  runApp(
    ProviderScope(
      overrides: [
        // Provide initialized services
        hiveServiceOverride.overrideWithValue(hiveService),
        connectivityServiceOverride.overrideWithValue(connectivityService),
        notificationServiceOverride.overrideWithValue(notificationService),
      ],
      child: const TaqwaAIApp(),
    ),
  );
}

// Provider overrides for initialized services
final hiveServiceOverride = Provider<HiveService>((ref) => throw UnimplementedError());
final connectivityServiceOverride = Provider<ConnectivityService>((ref) => throw UnimplementedError());
final notificationServiceOverride = Provider<NotificationService>((ref) => throw UnimplementedError());
