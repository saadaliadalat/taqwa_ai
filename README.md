# Taqwa AI - Firebase Backend

A production-ready Firebase backend for the Taqwa AI Islamic assistant mobile app. This backend provides AI-powered Islamic Q&A, Quran and Hadith references, favorites management, and push notifications.

## 🌟 Features

- **AI-Powered Q&A**: Intelligent Islamic question answering using Groq LLaMA-3.1-70B
- **Quran Integration**: Verse search and retrieval via AlQuran Cloud API
- **Hadith Integration**: Authentic hadith search via Sunnah.com API
- **Islamic Guardrails**: Ethical filtering for all AI responses
- **Push Notifications**: Daily Quran verses and Hadith reminders via FCM
- **Offline Support**: Sync endpoints designed for Flutter Hive integration
- **Secure Authentication**: Firebase Auth with email/password and anonymous login

## 📁 Project Structure

```
taqwa_ai/
├── functions/
│   ├── index.js              # Main Cloud Functions entry point
│   ├── auth.middleware.js    # Firebase Auth token validation
│   ├── ai.handler.js         # AI orchestration with Groq
│   ├── quran.service.js      # AlQuran Cloud API integration
│   ├── hadith.service.js     # Sunnah.com API integration
│   ├── notifications.js      # FCM push notifications
│   ├── ethics.guard.js       # Islamic ethical guardrails
│   ├── firestore.models.js   # Firestore document helpers
│   ├── package.json          # Node.js dependencies
│   └── utils/
│       └── rateLimiter.js    # Rate limiting utility
├── firebase.json             # Firebase configuration
├── firestore.rules           # Firestore security rules
├── firestore.indexes.json    # Firestore indexes
├── .env.example              # Environment variables template
└── README.md                 # This file
```

## 🚀 Setup Instructions

### Prerequisites

- Node.js 18+ installed
- Firebase CLI installed (`npm install -g firebase-tools`)
- Firebase project created at [Firebase Console](https://console.firebase.google.com)
- Groq API key from [Groq Console](https://console.groq.com)
- Sunnah.com API key from [Sunnah API](https://sunnah.com/developers)

### Step 1: Clone and Install

```bash
cd taqwa_ai
cd functions
npm install
```

### Step 2: Firebase Setup

```bash
# Login to Firebase
firebase login

# Initialize Firebase (select your project)
firebase init

# Select:
# - Firestore
# - Functions
# - Emulators (optional, for local testing)
```

### Step 3: Configure Environment Variables

1. Copy the environment template:
```bash
cp .env.example .env
```

2. Edit `.env` with your actual values:
```
GROQ_API_KEY=your_groq_api_key_here
SUNNAH_API_KEY=your_sunnah_api_key_here
```

3. Set Firebase Functions config:
```bash
firebase functions:config:set groq.api_key="YOUR_GROQ_API_KEY"
firebase functions:config:set sunnah.api_key="YOUR_SUNNAH_API_KEY"
```

### Step 4: Deploy

```bash
# Deploy everything
firebase deploy

# Or deploy specific components
firebase deploy --only functions
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

## 🔐 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `GROQ_API_KEY` | Groq API key for LLaMA-3.1-70B | Yes |
| `SUNNAH_API_KEY` | Sunnah.com API key for Hadith | Yes |
| `RATE_LIMIT_MAX_REQUESTS` | Max requests per minute (default: 30) | No |
| `RATE_LIMIT_WINDOW_MS` | Rate limit window in ms (default: 60000) | No |

## 📡 API Endpoints

### Base URL
```
https://<region>-<project-id>.cloudfunctions.net/api
```

### Authentication
All protected endpoints require Firebase Auth token in header:
```
Authorization: Bearer <firebase_id_token>
```

### AI Q&A

#### Ask Question
```http
POST /api/ask
Content-Type: application/json
Authorization: Bearer <token>

{
  "question": "What does Islam say about patience?"
}
```

**Response:**
```json
{
  "success": true,
  "answer": "Islam emphasizes patience (sabr) as a virtue...",
  "sources": ["Quran", "Hadith", "AI"],
  "references": {
    "quran": [
      { "surah": 2, "surahName": "Al-Baqarah", "ayah": 153, "text": "..." }
    ],
    "hadith": [
      { "collection": "Sahih al-Bukhari", "number": "123", "text": "..." }
    ]
  }
}
```

### Quran

#### Get Random Verse
```http
GET /api/quran/random
```

#### Get Specific Verse
```http
GET /api/quran/2/255
```

#### Search Quran
```http
GET /api/quran/search?q=patience
```

### Hadith

#### Get Random Hadith
```http
GET /api/hadith/random?collection=bukhari
```

#### Get Specific Hadith
```http
GET /api/hadith/bukhari/1
```

#### Get Collections
```http
GET /api/hadith/collections
```

### Favorites

#### Save Favorite
```http
POST /api/favorites
Authorization: Bearer <token>

{
  "type": "quran",
  "referenceId": "2:255",
  "text": "Ayat al-Kursi text..."
}
```

#### Get Favorites
```http
GET /api/favorites?type=quran
Authorization: Bearer <token>
```

#### Delete Favorite
```http
DELETE /api/favorites/<itemId>
Authorization: Bearer <token>
```

### User Profile

#### Create/Update Profile
```http
POST /api/user/profile
Authorization: Bearer <token>

{
  "name": "User Name",
  "notificationPreferences": {
    "dailyVerse": true,
    "hadithReminder": true
  }
}
```

#### Update Notifications
```http
PUT /api/user/notifications
Authorization: Bearer <token>

{
  "dailyVerse": true,
  "hadithReminder": false,
  "fcmToken": "<fcm_device_token>"
}
```

### Sync (Offline Support)

#### Get Sync Data
```http
GET /api/sync?since=1703756400000
Authorization: Bearer <token>
```

### FCM Registration

#### Register Token
```http
POST /api/fcm/register
Authorization: Bearer <token>

{
  "token": "<fcm_device_token>"
}
```

## 📱 Flutter Integration

### Firebase Setup in Flutter

1. Add Firebase packages to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_messaging: ^14.7.10
  http: ^1.1.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

2. Initialize Firebase:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  runApp(MyApp());
}
```

### API Service Example

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaqwaApiService {
  static const String baseUrl = 'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/api';
  
  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.getIdToken();
  }

  Future<Map<String, dynamic>> askQuestion(String question) async {
    final token = await _getToken();
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/ask'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'question': question}),
    );
    
    return jsonDecode(response.body);
  }
  
  Future<Map<String, dynamic>> getRandomVerse() async {
    final response = await http.get(Uri.parse('$baseUrl/api/quran/random'));
    return jsonDecode(response.body);
  }
}
```

### Hive Offline Sync Strategy

```dart
import 'package:hive/hive.dart';

class OfflineSyncService {
  late Box<dynamic> conversationsBox;
  late Box<dynamic> favoritesBox;
  late Box<dynamic> syncMetaBox;
  
  Future<void> init() async {
    conversationsBox = await Hive.openBox('conversations');
    favoritesBox = await Hive.openBox('favorites');
    syncMetaBox = await Hive.openBox('syncMeta');
  }
  
  Future<void> syncWithServer(TaqwaApiService api) async {
    final lastSync = syncMetaBox.get('lastSync', defaultValue: 0) as int;
    
    try {
      final syncData = await api.getSyncData(since: lastSync);
      
      // Update local storage
      for (final conv in syncData['conversations']) {
        await conversationsBox.put(conv['id'], conv);
      }
      
      for (final fav in syncData['favorites']) {
        await favoritesBox.put(fav['id'], fav);
      }
      
      // Update sync timestamp
      await syncMetaBox.put('lastSync', syncData['syncTimestamp']);
    } catch (e) {
      // Continue with offline data
      print('Sync failed, using offline data: $e');
    }
  }
  
  // Get data with offline fallback
  List<dynamic> getConversations() {
    return conversationsBox.values.toList();
  }
  
  List<dynamic> getFavorites() {
    return favoritesBox.values.toList();
  }
}
```

### Offline-First Pattern

1. **Read from local first**: Always return cached data immediately
2. **Sync in background**: Fetch updates when online
3. **Conflict resolution**: Server timestamp wins (last-write-wins)
4. **Queue pending actions**: Store unsent requests locally
5. **Retry on connectivity**: Use `connectivity_plus` to detect network

## 🔒 Security

### Firestore Rules

The included security rules enforce:
- User can only access their own data
- Field validation on document creation
- Immutable fields (createdAt)
- Required fields validation

### Rate Limiting

- Default: 30 requests per minute per user
- Configurable via environment variables
- Stored in Firestore for persistence

### API Key Security

- All API keys stored in environment variables
- Never exposed to client
- Firebase Functions config for production

## 📅 Scheduled Functions

| Function | Schedule | Description |
|----------|----------|-------------|
| `sendDailyVerse` | 6:00 AM UTC | Daily Quran verse notification |
| `sendHadithReminder` | 12:00 PM UTC | Daily Hadith reminder |
| `cleanupRateLimits` | 3:00 AM UTC | Clean expired rate limit records |

## 🧪 Local Development

### Using Firebase Emulators

```bash
# Start emulators
firebase emulators:start

# In another terminal, run functions locally
cd functions
npm run serve
```

### Testing Endpoints

```bash
# Test health check
curl http://localhost:5001/PROJECT_ID/REGION/api/health

# Test ask endpoint (requires token)
curl -X POST http://localhost:5001/PROJECT_ID/REGION/api/api/ask \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"question": "What is Islam?"}'
```

## 🚦 Deployment Checklist

- [ ] Firebase project created
- [ ] Groq API key configured
- [ ] Sunnah.com API key configured
- [ ] Firestore security rules deployed
- [ ] Firestore indexes deployed
- [ ] Cloud Functions deployed
- [ ] FCM configured in Firebase Console
- [ ] Flutter app configured with Firebase

## 📚 External APIs

### AlQuran Cloud API
- **URL**: https://alquran.cloud/api
- **Auth**: None required (public API)
- **Rate Limit**: Reasonable use

### Sunnah.com API
- **URL**: https://api.sunnah.com
- **Auth**: API key in header (`X-API-Key`)
- **Sign Up**: https://sunnah.com/developers

### Groq API
- **URL**: https://api.groq.com
- **Model**: llama-3.1-70b-versatile
- **Sign Up**: https://console.groq.com

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

MIT License - see LICENSE file for details.

## 🙏 Acknowledgements

- AlQuran Cloud for Quran API
- Sunnah.com for Hadith API
- Groq for AI inference
- Firebase for backend infrastructure

---

Built with ❤️ for the Muslim Ummah
