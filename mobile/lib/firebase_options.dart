// File generated for testing purposes
// Replace with actual Firebase configuration from FlutterFire CLI
// Run: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'config/env_config.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
/// 
/// IMPORTANT: Replace these placeholder values with your actual Firebase config.
/// Generate using: `flutterfire configure`
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'run flutterfire configure to generate.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'run flutterfire configure to generate.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'run flutterfire configure to generate.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Get project ID based on environment
  static String get _projectId {
    switch (EnvConfig.environment) {
      case Environment.dev:
        return 'taqwa-ai-dev';
      case Environment.staging:
        return 'taqwa-ai-staging';
      case Environment.prod:
        return 'taqwa-ai';
    }
  }

  // ============================================================
  // PLACEHOLDER VALUES - REPLACE WITH YOUR FIREBASE PROJECT CONFIG
  // Run `flutterfire configure` to generate these automatically
  // ============================================================
  
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR-WEB-API-KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'taqwa-ai',
    authDomain: 'taqwa-ai.firebaseapp.com',
    storageBucket: 'taqwa-ai.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-ANDROID-API-KEY',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'taqwa-ai',
    storageBucket: 'taqwa-ai.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'taqwa-ai',
    storageBucket: 'taqwa-ai.appspot.com',
    iosBundleId: 'com.taqwaai.mobile',
  );
}
