# Taqwa AI Mobile

A Flutter mobile application for Taqwa AI - Your trusted Islamic AI companion for Quran, Hadith, and spiritual guidance.

## Features

- 🤖 **AI-Powered Q&A** - Ask Islamic questions and get authentic, sourced answers
- 📖 **Quran Reader** - Read the Holy Quran with translations and tafsir
- 📜 **Hadith Library** - Browse authenticated Hadith collections
- ⭐ **Favorites** - Save verses, hadith, and AI responses
- 🌙 **Daily Ayah** - Receive a daily verse for reflection
- 🕌 **Madhhab Support** - Get answers tailored to your school of thought
- 🌐 **Offline Support** - Access saved content without internet
- 🔔 **Push Notifications** - Daily reminders and updates

## Getting Started

### Prerequisites

- Flutter SDK 3.38+
- Dart 3.0+
- Firebase account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/taqwa_ai.git
cd taqwa_ai/mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase (see [FIREBASE_SETUP.md](FIREBASE_SETUP.md)):
```bash
flutterfire configure
```

4. Generate Hive adapters:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

5. Run the app:
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## Project Structure

```
lib/
├── config/           # Environment configuration
├── models/           # Data models with Hive support
├── providers/        # Riverpod state management
├── screens/          # UI screens
│   ├── onboarding/   # Welcome & setup flow
│   ├── home/         # Home screen
│   ├── ask_ai/       # AI chat interface
│   ├── quran/        # Quran reader
│   ├── favorites/    # Saved items
│   └── profile/      # Settings & profile
├── services/         # API, Auth, Storage services
├── theme/            # Design system
├── utils/            # Helpers & utilities
└── widgets/          # Reusable components
```

## Tech Stack

- **Framework**: Flutter 3.38+
- **State Management**: Riverpod
- **Local Storage**: Hive
- **Backend**: Firebase (Auth, Firestore, Messaging)
- **UI**: Material 3 with custom Islamic theme

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for build and deployment instructions.

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Quran.com API](https://quran.com/api) for Quran data
- [sunnah.com](https://sunnah.com/api) for Hadith data
- Islamic scholars who reviewed our AI guardrails
