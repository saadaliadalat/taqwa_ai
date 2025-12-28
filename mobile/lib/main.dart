import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'config/env_config.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/connectivity_service.dart';
import 'providers/shared_providers.dart';
import 'app.dart';

/// Background message handler - must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message: ${message.messageId}');
}

void main() async {
  // Run the app in a zone to catch all errors
  runZonedGuarded(() async {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Set environment based on build mode
    if (kDebugMode) {
      EnvConfig.setEnvironment(Environment.dev);
    } else if (kProfileMode) {
      EnvConfig.setEnvironment(Environment.staging);
    } else {
      EnvConfig.setEnvironment(Environment.prod);
    }

    // Set up global error handling for Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (EnvConfig.isProduction) {
        // In production, you could send to crash reporting
        // CrashReporting.recordFlutterError(details);
      }
    };

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

    // Initialize Firebase with options
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      // Continue without Firebase in development
      if (!EnvConfig.isDevelopment) rethrow;
    }

    // Initialize Hive for local storage
    final hiveService = HiveService();
    await hiveService.init();

    // Initialize connectivity service
    final connectivityService = ConnectivityService();
    await connectivityService.init();

    // Initialize notification service (optional - don't crash if it fails)
    final notificationService = NotificationService();
    try {
      await notificationService.init();
    } catch (e) {
      debugPrint('Notification service init failed: $e');
    }

    // Run the app wrapped in ProviderScope with initialized services
    runApp(
      ProviderScope(
        overrides: [
          hiveServiceProvider.overrideWithValue(hiveService),
          connectivityServiceProvider.overrideWithValue(connectivityService),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
        child: const TaqwaAIApp(),
      ),
    );
  }, (error, stackTrace) {
    // Catch any errors not caught by Flutter framework
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stackTrace');
    if (EnvConfig.isProduction) {
      // In production, send to crash reporting
      // CrashReporting.recordError(error, stackTrace);
    }
  });
}
