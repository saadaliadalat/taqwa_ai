# Taqwa AI Mobile - Deployment Guide

## Build Commands

### Web Build
```bash
# Production build for web
flutter build web --release --web-renderer html

# With base href for subdirectory hosting
flutter build web --release --base-href /app/
```

Build output: `build/web/`

### Android Build
```bash
# APK for testing
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

Build output:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### iOS Build
```bash
# Build for iOS
flutter build ios --release

# Then open Xcode and archive
open ios/Runner.xcworkspace
```

## Deployment Targets

### Firebase Hosting (Web)

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
firebase login
```

2. Initialize hosting:
```bash
firebase init hosting
# Select build/web as public directory
# Configure as single-page app: Yes
```

3. Deploy:
```bash
flutter build web --release
firebase deploy --only hosting
```

### Google Play Store (Android)

1. Create keystore:
```bash
keytool -genkey -v -keystore ~/taqwa-ai-release.keystore -alias taqwa-ai -keyalg RSA -keysize 2048 -validity 10000
```

2. Configure in `android/key.properties`:
```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=taqwa-ai
storeFile=/path/to/taqwa-ai-release.keystore
```

3. Build and upload:
```bash
flutter build appbundle --release
# Upload AAB to Play Console
```

### Apple App Store (iOS)

1. Configure signing in Xcode
2. Archive and upload via Xcode or:
```bash
flutter build ipa --release
# Upload using Transporter app
```

## Environment-Specific Builds

### Development
```bash
flutter run -d chrome --dart-define=ENV=dev
```

### Staging
```bash
flutter build web --dart-define=ENV=staging
```

### Production
```bash
flutter build web --dart-define=ENV=prod --release
```

## CI/CD with GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Firebase

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.0'
          
      - name: Install dependencies
        run: |
          cd mobile
          flutter pub get
          
      - name: Build web
        run: |
          cd mobile
          flutter build web --release
          
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: taqwa-ai
```

## Performance Optimization

### Web
- Use `--web-renderer html` for broader compatibility
- Enable tree shaking: `flutter build web --release`
- Consider deferred loading for large components

### Mobile
- Enable ProGuard for Android (`android/app/build.gradle`)
- Strip debug symbols in release builds
- Use `--obfuscate` for additional protection

```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info/
```
