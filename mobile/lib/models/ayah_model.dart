import 'package:hive/hive.dart';

part 'ayah_model.g.dart';

/// Ayah (Verse) model for the Quran
@HiveType(typeId: 6)
class AyahModel {
  @HiveField(0)
  final int number;
  
  @HiveField(1)
  final int numberInSurah;
  
  @HiveField(2)
  final int surahNumber;
  
  @HiveField(3)
  final String text;
  
  @HiveField(4)
  final String? translation;
  
  @HiveField(5)
  final String? translationLanguage;
  
  @HiveField(6)
  final String? tafsir;
  
  @HiveField(7)
  final int juz;
  
  @HiveField(8)
  final int page;
  
  @HiveField(9)
  final int hizbQuarter;
  
  @HiveField(10)
  final bool sajda;

  const AyahModel({
    required this.number,
    required this.numberInSurah,
    required this.surahNumber,
    required this.text,
    this.translation,
    this.translationLanguage,
    this.tafsir,
    this.juz = 1,
    this.page = 1,
    this.hizbQuarter = 1,
    this.sajda = false,
  });

  /// Create from API response
  factory AyahModel.fromApi(Map<String, dynamic> json, {String? translationText}) {
    return AyahModel(
      number: json['number'] as int? ?? 0,
      numberInSurah: json['numberInSurah'] as int? ?? json['ayah'] as int? ?? 0,
      surahNumber: json['surah']?['number'] as int? ?? json['surahNumber'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      translation: translationText ?? json['translation'] as String?,
      juz: json['juz'] as int? ?? 1,
      page: json['page'] as int? ?? 1,
      hizbQuarter: json['hizbQuarter'] as int? ?? 1,
      sajda: json['sajda'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'numberInSurah': numberInSurah,
      'surahNumber': surahNumber,
      'text': text,
      if (translation != null) 'translation': translation,
      if (translationLanguage != null) 'translationLanguage': translationLanguage,
      if (tafsir != null) 'tafsir': tafsir,
      'juz': juz,
      'page': page,
      'hizbQuarter': hizbQuarter,
      'sajda': sajda,
    };
  }

  /// Copy with updated fields
  AyahModel copyWith({
    int? number,
    int? numberInSurah,
    int? surahNumber,
    String? text,
    String? translation,
    String? translationLanguage,
    String? tafsir,
    int? juz,
    int? page,
    int? hizbQuarter,
    bool? sajda,
  }) {
    return AyahModel(
      number: number ?? this.number,
      numberInSurah: numberInSurah ?? this.numberInSurah,
      surahNumber: surahNumber ?? this.surahNumber,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      translationLanguage: translationLanguage ?? this.translationLanguage,
      tafsir: tafsir ?? this.tafsir,
      juz: juz ?? this.juz,
      page: page ?? this.page,
      hizbQuarter: hizbQuarter ?? this.hizbQuarter,
      sajda: sajda ?? this.sajda,
    );
  }

  /// Get formatted reference
  String get reference => '$surahNumber:$numberInSurah';
  
  /// Check if has translation
  bool get hasTranslation => translation != null && translation!.isNotEmpty;
  
  /// Check if has tafsir
  bool get hasTafsir => tafsir != null && tafsir!.isNotEmpty;
}
