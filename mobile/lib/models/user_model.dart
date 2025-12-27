import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// User preferences for Islamic jurisprudence school
enum Madhhab {
  hanafi,
  maliki,
  shafii,
  hanbali,
  none, // For those who don't follow a specific madhhab
}

/// User app language preference
enum AppLanguage {
  english,
  arabic,
  urdu,
  turkish,
  indonesian,
  malay,
}

/// User model representing authenticated user data
@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String? email;
  
  @HiveField(2)
  final String? displayName;
  
  @HiveField(3)
  final bool isGuest;
  
  @HiveField(4)
  final String? photoUrl;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime lastActiveAt;
  
  @HiveField(7)
  final String madhhab;
  
  @HiveField(8)
  final String language;
  
  @HiveField(9)
  final bool notificationsEnabled;
  
  @HiveField(10)
  final bool dailyAyahEnabled;
  
  @HiveField(11)
  final String? dailyAyahTime;
  
  @HiveField(12)
  final bool darkModeEnabled;
  
  @HiveField(13)
  final int quranFontSize;
  
  @HiveField(14)
  final bool showTranslation;
  
  @HiveField(15)
  final String translationLanguage;
  
  @HiveField(16)
  final List<String> purposes;

  const UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.isGuest = false,
    this.photoUrl,
    required this.createdAt,
    required this.lastActiveAt,
    this.madhhab = 'none',
    this.language = 'english',
    this.notificationsEnabled = true,
    this.dailyAyahEnabled = true,
    this.dailyAyahTime = '08:00',
    this.darkModeEnabled = false,
    this.quranFontSize = 26,
    this.showTranslation = true,
    this.translationLanguage = 'en',
    this.purposes = const [],
  });

  /// Create from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return UserModel(
      id: docId,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      isGuest: data['isGuest'] as bool? ?? false,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      lastActiveAt: (data['lastActiveAt'] as dynamic)?.toDate() ?? DateTime.now(),
      madhhab: data['preferences']?['madhhab'] as String? ?? 'none',
      language: data['preferences']?['language'] as String? ?? 'english',
      notificationsEnabled: data['preferences']?['notificationsEnabled'] as bool? ?? true,
      dailyAyahEnabled: data['preferences']?['dailyAyahEnabled'] as bool? ?? true,
      dailyAyahTime: data['preferences']?['dailyAyahTime'] as String? ?? '08:00',
      darkModeEnabled: data['preferences']?['darkModeEnabled'] as bool? ?? false,
      quranFontSize: data['preferences']?['quranFontSize'] as int? ?? 26,
      showTranslation: data['preferences']?['showTranslation'] as bool? ?? true,
      translationLanguage: data['preferences']?['translationLanguage'] as String? ?? 'en',
      purposes: List<String>.from(data['purposes'] ?? []),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'isGuest': isGuest,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'lastActiveAt': lastActiveAt,
      'preferences': {
        'madhhab': madhhab,
        'language': language,
        'notificationsEnabled': notificationsEnabled,
        'dailyAyahEnabled': dailyAyahEnabled,
        'dailyAyahTime': dailyAyahTime,
        'darkModeEnabled': darkModeEnabled,
        'quranFontSize': quranFontSize,
        'showTranslation': showTranslation,
        'translationLanguage': translationLanguage,
      },
      'purposes': purposes,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isGuest,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? madhhab,
    String? language,
    bool? notificationsEnabled,
    bool? dailyAyahEnabled,
    String? dailyAyahTime,
    bool? darkModeEnabled,
    int? quranFontSize,
    bool? showTranslation,
    String? translationLanguage,
    List<String>? purposes,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isGuest: isGuest ?? this.isGuest,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      madhhab: madhhab ?? this.madhhab,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyAyahEnabled: dailyAyahEnabled ?? this.dailyAyahEnabled,
      dailyAyahTime: dailyAyahTime ?? this.dailyAyahTime,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      quranFontSize: quranFontSize ?? this.quranFontSize,
      showTranslation: showTranslation ?? this.showTranslation,
      translationLanguage: translationLanguage ?? this.translationLanguage,
      purposes: purposes ?? this.purposes,
    );
  }

  /// Create a guest user
  factory UserModel.guest() {
    final now = DateTime.now();
    return UserModel(
      id: 'guest_${now.millisecondsSinceEpoch}',
      isGuest: true,
      createdAt: now,
      lastActiveAt: now,
    );
  }
}
