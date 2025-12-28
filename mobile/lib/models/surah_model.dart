import 'package:hive/hive.dart';

part 'surah_model.g.dart';

/// Surah (Chapter) model for the Quran
@HiveType(typeId: 5)
class SurahModel {
  @HiveField(0)
  final int number;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String englishName;
  
  @HiveField(3)
  final String englishNameTranslation;
  
  @HiveField(4)
  final int numberOfAyahs;
  
  @HiveField(5)
  final String revelationType;
  
  @HiveField(6)
  final int juz;
  
  @HiveField(7)
  final int page;

  const SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    this.juz = 1,
    this.page = 1,
  });

  /// Create from API response
  factory SurahModel.fromApi(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      numberOfAyahs: json['numberOfAyahs'] as int,
      revelationType: json['revelationType'] as String,
    );
  }

  /// Create from AlQuran.cloud API response
  factory SurahModel.fromAlQuranCloud(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      numberOfAyahs: json['numberOfAyahs'] as int,
      revelationType: json['revelationType'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'numberOfAyahs': numberOfAyahs,
      'revelationType': revelationType,
      'juz': juz,
      'page': page,
    };
  }

  /// Get formatted name with number
  String get displayName => '$number. $englishName';
  
  /// Check if Makki or Madani
  bool get isMakki => revelationType.toLowerCase() == 'meccan';
  bool get isMadani => revelationType.toLowerCase() == 'medinan';
}

/// List of all 114 Surahs
class SurahList {
  static const List<SurahModel> surahs = [
    SurahModel(number: 1, name: 'الفاتحة', englishName: 'Al-Fatihah', englishNameTranslation: 'The Opening', numberOfAyahs: 7, revelationType: 'Meccan'),
    SurahModel(number: 2, name: 'البقرة', englishName: 'Al-Baqarah', englishNameTranslation: 'The Cow', numberOfAyahs: 286, revelationType: 'Medinan'),
    SurahModel(number: 3, name: 'آل عمران', englishName: 'Aal-E-Imran', englishNameTranslation: 'The Family of Imran', numberOfAyahs: 200, revelationType: 'Medinan'),
    SurahModel(number: 4, name: 'النساء', englishName: 'An-Nisa', englishNameTranslation: 'The Women', numberOfAyahs: 176, revelationType: 'Medinan'),
    SurahModel(number: 5, name: 'المائدة', englishName: 'Al-Ma\'idah', englishNameTranslation: 'The Table Spread', numberOfAyahs: 120, revelationType: 'Medinan'),
    SurahModel(number: 6, name: 'الأنعام', englishName: 'Al-An\'am', englishNameTranslation: 'The Cattle', numberOfAyahs: 165, revelationType: 'Meccan'),
    SurahModel(number: 7, name: 'الأعراف', englishName: 'Al-A\'raf', englishNameTranslation: 'The Heights', numberOfAyahs: 206, revelationType: 'Meccan'),
    SurahModel(number: 8, name: 'الأنفال', englishName: 'Al-Anfal', englishNameTranslation: 'The Spoils of War', numberOfAyahs: 75, revelationType: 'Medinan'),
    SurahModel(number: 9, name: 'التوبة', englishName: 'At-Tawbah', englishNameTranslation: 'The Repentance', numberOfAyahs: 129, revelationType: 'Medinan'),
    SurahModel(number: 10, name: 'يونس', englishName: 'Yunus', englishNameTranslation: 'Jonah', numberOfAyahs: 109, revelationType: 'Meccan'),
    SurahModel(number: 11, name: 'هود', englishName: 'Hud', englishNameTranslation: 'Hud', numberOfAyahs: 123, revelationType: 'Meccan'),
    SurahModel(number: 12, name: 'يوسف', englishName: 'Yusuf', englishNameTranslation: 'Joseph', numberOfAyahs: 111, revelationType: 'Meccan'),
    SurahModel(number: 13, name: 'الرعد', englishName: 'Ar-Ra\'d', englishNameTranslation: 'The Thunder', numberOfAyahs: 43, revelationType: 'Medinan'),
    SurahModel(number: 14, name: 'ابراهيم', englishName: 'Ibrahim', englishNameTranslation: 'Abraham', numberOfAyahs: 52, revelationType: 'Meccan'),
    SurahModel(number: 15, name: 'الحجر', englishName: 'Al-Hijr', englishNameTranslation: 'The Rocky Tract', numberOfAyahs: 99, revelationType: 'Meccan'),
    SurahModel(number: 16, name: 'النحل', englishName: 'An-Nahl', englishNameTranslation: 'The Bee', numberOfAyahs: 128, revelationType: 'Meccan'),
    SurahModel(number: 17, name: 'الإسراء', englishName: 'Al-Isra', englishNameTranslation: 'The Night Journey', numberOfAyahs: 111, revelationType: 'Meccan'),
    SurahModel(number: 18, name: 'الكهف', englishName: 'Al-Kahf', englishNameTranslation: 'The Cave', numberOfAyahs: 110, revelationType: 'Meccan'),
    SurahModel(number: 19, name: 'مريم', englishName: 'Maryam', englishNameTranslation: 'Mary', numberOfAyahs: 98, revelationType: 'Meccan'),
    SurahModel(number: 20, name: 'طه', englishName: 'Taha', englishNameTranslation: 'Ta-Ha', numberOfAyahs: 135, revelationType: 'Meccan'),
    SurahModel(number: 21, name: 'الأنبياء', englishName: 'Al-Anbiya', englishNameTranslation: 'The Prophets', numberOfAyahs: 112, revelationType: 'Meccan'),
    SurahModel(number: 22, name: 'الحج', englishName: 'Al-Hajj', englishNameTranslation: 'The Pilgrimage', numberOfAyahs: 78, revelationType: 'Medinan'),
    SurahModel(number: 23, name: 'المؤمنون', englishName: 'Al-Mu\'minun', englishNameTranslation: 'The Believers', numberOfAyahs: 118, revelationType: 'Meccan'),
    SurahModel(number: 24, name: 'النور', englishName: 'An-Nur', englishNameTranslation: 'The Light', numberOfAyahs: 64, revelationType: 'Medinan'),
    SurahModel(number: 25, name: 'الفرقان', englishName: 'Al-Furqan', englishNameTranslation: 'The Criterion', numberOfAyahs: 77, revelationType: 'Meccan'),
    SurahModel(number: 26, name: 'الشعراء', englishName: 'Ash-Shu\'ara', englishNameTranslation: 'The Poets', numberOfAyahs: 227, revelationType: 'Meccan'),
    SurahModel(number: 27, name: 'النمل', englishName: 'An-Naml', englishNameTranslation: 'The Ant', numberOfAyahs: 93, revelationType: 'Meccan'),
    SurahModel(number: 28, name: 'القصص', englishName: 'Al-Qasas', englishNameTranslation: 'The Stories', numberOfAyahs: 88, revelationType: 'Meccan'),
    SurahModel(number: 29, name: 'العنكبوت', englishName: 'Al-Ankabut', englishNameTranslation: 'The Spider', numberOfAyahs: 69, revelationType: 'Meccan'),
    SurahModel(number: 30, name: 'الروم', englishName: 'Ar-Rum', englishNameTranslation: 'The Romans', numberOfAyahs: 60, revelationType: 'Meccan'),
    SurahModel(number: 31, name: 'لقمان', englishName: 'Luqman', englishNameTranslation: 'Luqman', numberOfAyahs: 34, revelationType: 'Meccan'),
    SurahModel(number: 32, name: 'السجدة', englishName: 'As-Sajdah', englishNameTranslation: 'The Prostration', numberOfAyahs: 30, revelationType: 'Meccan'),
    SurahModel(number: 33, name: 'الأحزاب', englishName: 'Al-Ahzab', englishNameTranslation: 'The Combined Forces', numberOfAyahs: 73, revelationType: 'Medinan'),
    SurahModel(number: 34, name: 'سبإ', englishName: 'Saba', englishNameTranslation: 'Sheba', numberOfAyahs: 54, revelationType: 'Meccan'),
    SurahModel(number: 35, name: 'فاطر', englishName: 'Fatir', englishNameTranslation: 'The Originator', numberOfAyahs: 45, revelationType: 'Meccan'),
    SurahModel(number: 36, name: 'يس', englishName: 'Ya-Sin', englishNameTranslation: 'Ya Sin', numberOfAyahs: 83, revelationType: 'Meccan'),
    SurahModel(number: 37, name: 'الصافات', englishName: 'As-Saffat', englishNameTranslation: 'Those Ranged in Ranks', numberOfAyahs: 182, revelationType: 'Meccan'),
    SurahModel(number: 38, name: 'ص', englishName: 'Sad', englishNameTranslation: 'Sad', numberOfAyahs: 88, revelationType: 'Meccan'),
    SurahModel(number: 39, name: 'الزمر', englishName: 'Az-Zumar', englishNameTranslation: 'The Groups', numberOfAyahs: 75, revelationType: 'Meccan'),
    SurahModel(number: 40, name: 'غافر', englishName: 'Ghafir', englishNameTranslation: 'The Forgiver', numberOfAyahs: 85, revelationType: 'Meccan'),
    SurahModel(number: 41, name: 'فصلت', englishName: 'Fussilat', englishNameTranslation: 'Explained in Detail', numberOfAyahs: 54, revelationType: 'Meccan'),
    SurahModel(number: 42, name: 'الشورى', englishName: 'Ash-Shura', englishNameTranslation: 'The Consultation', numberOfAyahs: 53, revelationType: 'Meccan'),
    SurahModel(number: 43, name: 'الزخرف', englishName: 'Az-Zukhruf', englishNameTranslation: 'The Gold Adornments', numberOfAyahs: 89, revelationType: 'Meccan'),
    SurahModel(number: 44, name: 'الدخان', englishName: 'Ad-Dukhan', englishNameTranslation: 'The Smoke', numberOfAyahs: 59, revelationType: 'Meccan'),
    SurahModel(number: 45, name: 'الجاثية', englishName: 'Al-Jathiyah', englishNameTranslation: 'The Kneeling', numberOfAyahs: 37, revelationType: 'Meccan'),
    SurahModel(number: 46, name: 'الأحقاف', englishName: 'Al-Ahqaf', englishNameTranslation: 'The Wind-Curved Sandhills', numberOfAyahs: 35, revelationType: 'Meccan'),
    SurahModel(number: 47, name: 'محمد', englishName: 'Muhammad', englishNameTranslation: 'Muhammad', numberOfAyahs: 38, revelationType: 'Medinan'),
    SurahModel(number: 48, name: 'الفتح', englishName: 'Al-Fath', englishNameTranslation: 'The Victory', numberOfAyahs: 29, revelationType: 'Medinan'),
    SurahModel(number: 49, name: 'الحجرات', englishName: 'Al-Hujurat', englishNameTranslation: 'The Rooms', numberOfAyahs: 18, revelationType: 'Medinan'),
    SurahModel(number: 50, name: 'ق', englishName: 'Qaf', englishNameTranslation: 'Qaf', numberOfAyahs: 45, revelationType: 'Meccan'),
    SurahModel(number: 51, name: 'الذاريات', englishName: 'Adh-Dhariyat', englishNameTranslation: 'The Winnowing Winds', numberOfAyahs: 60, revelationType: 'Meccan'),
    SurahModel(number: 52, name: 'الطور', englishName: 'At-Tur', englishNameTranslation: 'The Mount', numberOfAyahs: 49, revelationType: 'Meccan'),
    SurahModel(number: 53, name: 'النجم', englishName: 'An-Najm', englishNameTranslation: 'The Star', numberOfAyahs: 62, revelationType: 'Meccan'),
    SurahModel(number: 54, name: 'القمر', englishName: 'Al-Qamar', englishNameTranslation: 'The Moon', numberOfAyahs: 55, revelationType: 'Meccan'),
    SurahModel(number: 55, name: 'الرحمن', englishName: 'Ar-Rahman', englishNameTranslation: 'The Most Merciful', numberOfAyahs: 78, revelationType: 'Medinan'),
    SurahModel(number: 56, name: 'الواقعة', englishName: 'Al-Waqi\'ah', englishNameTranslation: 'The Event', numberOfAyahs: 96, revelationType: 'Meccan'),
    SurahModel(number: 57, name: 'الحديد', englishName: 'Al-Hadid', englishNameTranslation: 'The Iron', numberOfAyahs: 29, revelationType: 'Medinan'),
    SurahModel(number: 58, name: 'المجادلة', englishName: 'Al-Mujadilah', englishNameTranslation: 'The Pleading Woman', numberOfAyahs: 22, revelationType: 'Medinan'),
    SurahModel(number: 59, name: 'الحشر', englishName: 'Al-Hashr', englishNameTranslation: 'The Exile', numberOfAyahs: 24, revelationType: 'Medinan'),
    SurahModel(number: 60, name: 'الممتحنة', englishName: 'Al-Mumtahanah', englishNameTranslation: 'She that is to be Examined', numberOfAyahs: 13, revelationType: 'Medinan'),
    SurahModel(number: 61, name: 'الصف', englishName: 'As-Saff', englishNameTranslation: 'The Ranks', numberOfAyahs: 14, revelationType: 'Medinan'),
    SurahModel(number: 62, name: 'الجمعة', englishName: 'Al-Jumu\'ah', englishNameTranslation: 'Friday', numberOfAyahs: 11, revelationType: 'Medinan'),
    SurahModel(number: 63, name: 'المنافقون', englishName: 'Al-Munafiqun', englishNameTranslation: 'The Hypocrites', numberOfAyahs: 11, revelationType: 'Medinan'),
    SurahModel(number: 64, name: 'التغابن', englishName: 'At-Taghabun', englishNameTranslation: 'Mutual Disillusion', numberOfAyahs: 18, revelationType: 'Medinan'),
    SurahModel(number: 65, name: 'الطلاق', englishName: 'At-Talaq', englishNameTranslation: 'Divorce', numberOfAyahs: 12, revelationType: 'Medinan'),
    SurahModel(number: 66, name: 'التحريم', englishName: 'At-Tahrim', englishNameTranslation: 'The Prohibition', numberOfAyahs: 12, revelationType: 'Medinan'),
    SurahModel(number: 67, name: 'الملك', englishName: 'Al-Mulk', englishNameTranslation: 'The Sovereignty', numberOfAyahs: 30, revelationType: 'Meccan'),
    SurahModel(number: 68, name: 'القلم', englishName: 'Al-Qalam', englishNameTranslation: 'The Pen', numberOfAyahs: 52, revelationType: 'Meccan'),
    SurahModel(number: 69, name: 'الحاقة', englishName: 'Al-Haqqah', englishNameTranslation: 'The Reality', numberOfAyahs: 52, revelationType: 'Meccan'),
    SurahModel(number: 70, name: 'المعارج', englishName: 'Al-Ma\'arij', englishNameTranslation: 'The Ascending Stairways', numberOfAyahs: 44, revelationType: 'Meccan'),
    SurahModel(number: 71, name: 'نوح', englishName: 'Nuh', englishNameTranslation: 'Noah', numberOfAyahs: 28, revelationType: 'Meccan'),
    SurahModel(number: 72, name: 'الجن', englishName: 'Al-Jinn', englishNameTranslation: 'The Jinn', numberOfAyahs: 28, revelationType: 'Meccan'),
    SurahModel(number: 73, name: 'المزمل', englishName: 'Al-Muzzammil', englishNameTranslation: 'The Enshrouded One', numberOfAyahs: 20, revelationType: 'Meccan'),
    SurahModel(number: 74, name: 'المدثر', englishName: 'Al-Muddaththir', englishNameTranslation: 'The Cloaked One', numberOfAyahs: 56, revelationType: 'Meccan'),
    SurahModel(number: 75, name: 'القيامة', englishName: 'Al-Qiyamah', englishNameTranslation: 'The Resurrection', numberOfAyahs: 40, revelationType: 'Meccan'),
    SurahModel(number: 76, name: 'الانسان', englishName: 'Al-Insan', englishNameTranslation: 'Man', numberOfAyahs: 31, revelationType: 'Medinan'),
    SurahModel(number: 77, name: 'المرسلات', englishName: 'Al-Mursalat', englishNameTranslation: 'Those Sent Forth', numberOfAyahs: 50, revelationType: 'Meccan'),
    SurahModel(number: 78, name: 'النبإ', englishName: 'An-Naba', englishNameTranslation: 'The Announcement', numberOfAyahs: 40, revelationType: 'Meccan'),
    SurahModel(number: 79, name: 'النازعات', englishName: 'An-Nazi\'at', englishNameTranslation: 'Those Who Drag Forth', numberOfAyahs: 46, revelationType: 'Meccan'),
    SurahModel(number: 80, name: 'عبس', englishName: 'Abasa', englishNameTranslation: 'He Frowned', numberOfAyahs: 42, revelationType: 'Meccan'),
    SurahModel(number: 81, name: 'التكوير', englishName: 'At-Takwir', englishNameTranslation: 'The Overthrowing', numberOfAyahs: 29, revelationType: 'Meccan'),
    SurahModel(number: 82, name: 'الإنفطار', englishName: 'Al-Infitar', englishNameTranslation: 'The Cleaving', numberOfAyahs: 19, revelationType: 'Meccan'),
    SurahModel(number: 83, name: 'المطففين', englishName: 'Al-Mutaffifin', englishNameTranslation: 'The Defrauding', numberOfAyahs: 36, revelationType: 'Meccan'),
    SurahModel(number: 84, name: 'الإنشقاق', englishName: 'Al-Inshiqaq', englishNameTranslation: 'The Splitting Open', numberOfAyahs: 25, revelationType: 'Meccan'),
    SurahModel(number: 85, name: 'البروج', englishName: 'Al-Buruj', englishNameTranslation: 'The Mansions of the Stars', numberOfAyahs: 22, revelationType: 'Meccan'),
    SurahModel(number: 86, name: 'الطارق', englishName: 'At-Tariq', englishNameTranslation: 'The Nightcommer', numberOfAyahs: 17, revelationType: 'Meccan'),
    SurahModel(number: 87, name: 'الأعلى', englishName: 'Al-A\'la', englishNameTranslation: 'The Most High', numberOfAyahs: 19, revelationType: 'Meccan'),
    SurahModel(number: 88, name: 'الغاشية', englishName: 'Al-Ghashiyah', englishNameTranslation: 'The Overwhelming', numberOfAyahs: 26, revelationType: 'Meccan'),
    SurahModel(number: 89, name: 'الفجر', englishName: 'Al-Fajr', englishNameTranslation: 'The Dawn', numberOfAyahs: 30, revelationType: 'Meccan'),
    SurahModel(number: 90, name: 'البلد', englishName: 'Al-Balad', englishNameTranslation: 'The City', numberOfAyahs: 20, revelationType: 'Meccan'),
    SurahModel(number: 91, name: 'الشمس', englishName: 'Ash-Shams', englishNameTranslation: 'The Sun', numberOfAyahs: 15, revelationType: 'Meccan'),
    SurahModel(number: 92, name: 'الليل', englishName: 'Al-Layl', englishNameTranslation: 'The Night', numberOfAyahs: 21, revelationType: 'Meccan'),
    SurahModel(number: 93, name: 'الضحى', englishName: 'Ad-Duhaa', englishNameTranslation: 'The Morning Hours', numberOfAyahs: 11, revelationType: 'Meccan'),
    SurahModel(number: 94, name: 'الشرح', englishName: 'Ash-Sharh', englishNameTranslation: 'The Relief', numberOfAyahs: 8, revelationType: 'Meccan'),
    SurahModel(number: 95, name: 'التين', englishName: 'At-Tin', englishNameTranslation: 'The Fig', numberOfAyahs: 8, revelationType: 'Meccan'),
    SurahModel(number: 96, name: 'العلق', englishName: 'Al-Alaq', englishNameTranslation: 'The Clot', numberOfAyahs: 19, revelationType: 'Meccan'),
    SurahModel(number: 97, name: 'القدر', englishName: 'Al-Qadr', englishNameTranslation: 'The Power', numberOfAyahs: 5, revelationType: 'Meccan'),
    SurahModel(number: 98, name: 'البينة', englishName: 'Al-Bayyinah', englishNameTranslation: 'The Clear Proof', numberOfAyahs: 8, revelationType: 'Medinan'),
    SurahModel(number: 99, name: 'الزلزلة', englishName: 'Az-Zalzalah', englishNameTranslation: 'The Earthquake', numberOfAyahs: 8, revelationType: 'Medinan'),
    SurahModel(number: 100, name: 'العاديات', englishName: 'Al-Adiyat', englishNameTranslation: 'The Coursers', numberOfAyahs: 11, revelationType: 'Meccan'),
    SurahModel(number: 101, name: 'القارعة', englishName: 'Al-Qari\'ah', englishNameTranslation: 'The Calamity', numberOfAyahs: 11, revelationType: 'Meccan'),
    SurahModel(number: 102, name: 'التكاثر', englishName: 'At-Takathur', englishNameTranslation: 'Competition', numberOfAyahs: 8, revelationType: 'Meccan'),
    SurahModel(number: 103, name: 'العصر', englishName: 'Al-Asr', englishNameTranslation: 'The Declining Day', numberOfAyahs: 3, revelationType: 'Meccan'),
    SurahModel(number: 104, name: 'الهمزة', englishName: 'Al-Humazah', englishNameTranslation: 'The Traducer', numberOfAyahs: 9, revelationType: 'Meccan'),
    SurahModel(number: 105, name: 'الفيل', englishName: 'Al-Fil', englishNameTranslation: 'The Elephant', numberOfAyahs: 5, revelationType: 'Meccan'),
    SurahModel(number: 106, name: 'قريش', englishName: 'Quraysh', englishNameTranslation: 'Quraysh', numberOfAyahs: 4, revelationType: 'Meccan'),
    SurahModel(number: 107, name: 'الماعون', englishName: 'Al-Ma\'un', englishNameTranslation: 'Small Kindnesses', numberOfAyahs: 7, revelationType: 'Meccan'),
    SurahModel(number: 108, name: 'الكوثر', englishName: 'Al-Kawthar', englishNameTranslation: 'Abundance', numberOfAyahs: 3, revelationType: 'Meccan'),
    SurahModel(number: 109, name: 'الكافرون', englishName: 'Al-Kafirun', englishNameTranslation: 'The Disbelievers', numberOfAyahs: 6, revelationType: 'Meccan'),
    SurahModel(number: 110, name: 'النصر', englishName: 'An-Nasr', englishNameTranslation: 'The Divine Support', numberOfAyahs: 3, revelationType: 'Medinan'),
    SurahModel(number: 111, name: 'المسد', englishName: 'Al-Masad', englishNameTranslation: 'The Palm Fiber', numberOfAyahs: 5, revelationType: 'Meccan'),
    SurahModel(number: 112, name: 'الإخلاص', englishName: 'Al-Ikhlas', englishNameTranslation: 'Sincerity', numberOfAyahs: 4, revelationType: 'Meccan'),
    SurahModel(number: 113, name: 'الفلق', englishName: 'Al-Falaq', englishNameTranslation: 'The Daybreak', numberOfAyahs: 5, revelationType: 'Meccan'),
    SurahModel(number: 114, name: 'الناس', englishName: 'An-Nas', englishNameTranslation: 'Mankind', numberOfAyahs: 6, revelationType: 'Meccan'),
  ];
}
