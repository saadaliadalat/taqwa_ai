// Firebase configuration for tqwa-ai project
// Generated from Firebase Console

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCF8ktbd-G4FQNF-5dOxQke1jHa4q27cWo',
    appId: '1:352375214270:web:7e43833f24c2c38e3a0eef',
    messagingSenderId: '352375214270',
    projectId: 'tqwa-ai',
    authDomain: 'tqwa-ai.firebaseapp.com',
    storageBucket: 'tqwa-ai.firebasestorage.app',
    measurementId: 'G-HV7YN8PVQ3',
  );

  // For Android: Download google-services.json from Firebase Console
  // and place it in android/app/
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCF8ktbd-G4FQNF-5dOxQke1jHa4q27cWo',
    appId: '1:352375214270:android:ADD_ANDROID_APP_ID',
    messagingSenderId: '352375214270',
    projectId: 'tqwa-ai',
    storageBucket: 'tqwa-ai.firebasestorage.app',
  );

  // For iOS: Download GoogleService-Info.plist from Firebase Console
  // and place it in ios/Runner/
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCF8ktbd-G4FQNF-5dOxQke1jHa4q27cWo',
    appId: '1:352375214270:ios:ADD_IOS_APP_ID',
    messagingSenderId: '352375214270',
    projectId: 'tqwa-ai',
    storageBucket: 'tqwa-ai.firebasestorage.app',
    iosBundleId: 'com.taqwaai.mobile',
  );
}
