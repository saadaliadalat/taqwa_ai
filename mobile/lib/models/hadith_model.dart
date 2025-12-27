import 'package:hive/hive.dart';

part 'hadith_model.g.dart';

/// Hadith collection enum
enum HadithCollection {
  bukhari,
  muslim,
  tirmidhi,
  abuDawud,
  nasai,
  ibnMajah,
}

/// Hadith grade enum
enum HadithGrade {
  sahih,
  hasan,
  daif,
  maudu,
  unknown,
}

/// Hadith model
@HiveType(typeId: 7)
class HadithModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String collection;
  
  @HiveField(2)
  final String hadithNumber;
  
  @HiveField(3)
  final String arabicText;
  
  @HiveField(4)
  final String translation;
  
  @HiveField(5)
  final String? narrator;
  
  @HiveField(6)
  final String? chapter;
  
  @HiveField(7)
  final String? book;
  
  @HiveField(8)
  final String? grade;
  
  @HiveField(9)
  final String? gradeSource;

  const HadithModel({
    required this.id,
    required this.collection,
    required this.hadithNumber,
    required this.arabicText,
    required this.translation,
    this.narrator,
    this.chapter,
    this.book,
    this.grade,
    this.gradeSource,
  });

  /// Create from API response
  factory HadithModel.fromApi(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      collection: json['collection'] as String? ?? json['book'] as String? ?? '',
      hadithNumber: json['hadithNumber']?.toString() ?? json['number']?.toString() ?? '',
      arabicText: json['arabicText'] as String? ?? json['arabic'] as String? ?? '',
      translation: json['translation'] as String? ?? json['text'] as String? ?? '',
      narrator: json['narrator'] as String?,
      chapter: json['chapter'] as String?,
      book: json['bookName'] as String?,
      grade: json['grade'] as String?,
      gradeSource: json['gradeSource'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection': collection,
      'hadithNumber': hadithNumber,
      'arabicText': arabicText,
      'translation': translation,
      if (narrator != null) 'narrator': narrator,
      if (chapter != null) 'chapter': chapter,
      if (book != null) 'book': book,
      if (grade != null) 'grade': grade,
      if (gradeSource != null) 'gradeSource': gradeSource,
    };
  }

  /// Copy with updated fields
  HadithModel copyWith({
    String? id,
    String? collection,
    String? hadithNumber,
    String? arabicText,
    String? translation,
    String? narrator,
    String? chapter,
    String? book,
    String? grade,
    String? gradeSource,
  }) {
    return HadithModel(
      id: id ?? this.id,
      collection: collection ?? this.collection,
      hadithNumber: hadithNumber ?? this.hadithNumber,
      arabicText: arabicText ?? this.arabicText,
      translation: translation ?? this.translation,
      narrator: narrator ?? this.narrator,
      chapter: chapter ?? this.chapter,
      book: book ?? this.book,
      grade: grade ?? this.grade,
      gradeSource: gradeSource ?? this.gradeSource,
    );
  }

  /// Get formatted reference
  String get reference => '$collection $hadithNumber';
  
  /// Get collection display name
  String get collectionDisplayName {
    switch (collection.toLowerCase()) {
      case 'bukhari':
        return 'Sahih Bukhari';
      case 'muslim':
        return 'Sahih Muslim';
      case 'tirmidhi':
        return 'Jami\' at-Tirmidhi';
      case 'abudawud':
        return 'Sunan Abu Dawud';
      case 'nasai':
        return 'Sunan an-Nasa\'i';
      case 'ibnmajah':
        return 'Sunan Ibn Majah';
      default:
        return collection;
    }
  }

  /// Get grade color for UI
  String get gradeColor {
    switch (grade?.toLowerCase()) {
      case 'sahih':
        return '#2E6B4F'; // Green
      case 'hasan':
        return '#1F7A5A'; // Primary green
      case 'daif':
        return '#B8860B'; // Warning amber
      case 'maudu':
        return '#8B2E2E'; // Error red
      default:
        return '#6B6B6B'; // Gray
    }
  }
}
