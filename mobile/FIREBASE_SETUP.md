# Taqwa AI Mobile - Firebase Setup Guide

This guide walks you through setting up Firebase for the Taqwa AI mobile app.

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed
- [Firebase CLI](https://firebase.google.com/docs/cli) installed
- A Firebase account

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it `taqwa-ai` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Click "Create project"

## Step 2: Install FlutterFire CLI

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login
```

## Step 3: Configure Firebase for Flutter

From the `mobile` directory, run:

```bash
# This will generate firebase_options.dart automatically
flutterfire configure --project=taqwa-ai
```

Select the platforms you want to support:
- ✅ Android
- ✅ iOS  
- ✅ Web

## Step 4: Enable Firebase Services

### Authentication
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable these providers:
   - Email/Password
   - Anonymous (for guest mode)
   - Google Sign-In (optional)

### Firestore Database
1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Choose "Start in production mode"
4. Select a location close to your users

### Cloud Messaging (Push Notifications)
1. Go to Firebase Console → Cloud Messaging
2. Enable Cloud Messaging
3. For iOS, upload APNs certificates

## Step 5: Configure Platform-Specific Files

### Android (`android/app/`)
The `google-services.json` file should be automatically placed here by FlutterFire CLI.

### iOS (`ios/Runner/`)
The `GoogleService-Info.plist` file should be automatically placed here by FlutterFire CLI.

### Web
Update `web/firebase-messaging-sw.js` with your actual Firebase config:

```javascript
firebase.initializeApp({
  apiKey: 'YOUR-ACTUAL-API-KEY',
  appId: 'YOUR-ACTUAL-APP-ID',
  messagingSenderId: 'YOUR-SENDER-ID',
  projectId: 'taqwa-ai',
  authDomain: 'taqwa-ai.firebaseapp.com',
  storageBucket: 'taqwa-ai.appspot.com',
});
```

## Step 6: Deploy Firestore Rules

```bash
# From the project root
firebase deploy --only firestore:rules
```

## Step 7: Test the Configuration

```bash
# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios
```

## Environment Variables

For production, set these environment variables in your CI/CD:

```bash
FIREBASE_PROJECT_ID=taqwa-ai
FIREBASE_API_KEY=your-api-key
TAQWA_API_URL=https://your-backend-url.com
```

## Troubleshooting

### "API key not valid" Error
- Ensure you've run `flutterfire configure` successfully
- Check that `firebase_options.dart` has real values (not placeholders)
- For Android, verify `google-services.json` is in `android/app/`

### Push Notifications Not Working
- For iOS, ensure APNs certificates are uploaded in Firebase Console
- Check that `firebase-messaging-sw.js` has correct config values
- Verify notification permissions are granted

### Firestore "Permission Denied"
- Check Firestore security rules
- Ensure user is authenticated before database operations
