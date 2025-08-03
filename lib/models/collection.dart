import 'package:MemoTakara/models/flashcard.dart';

class Collection {
  final int id;
  final String name;
  final String? description;
  final String? languageFront;
  final String? languageBack;
  final int privacy;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final bool canEdit;
  final List<Flashcard> flashcards;

  // Thêm các trường mới từ API response
  final int? totalCards;
  final String? averageRating;
  final int? totalRatings;
  final int? totalDuplicates;
  final String? difficultyLevel;
  final bool? isFeatured;

  Collection({
    required this.id,
    required this.name,
    this.description,
    this.languageFront,
    this.languageBack,
    required this.privacy,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,

    required this.canEdit,
    required this.flashcards,
    this.totalCards,
    this.averageRating,
    this.totalRatings,
    this.totalDuplicates,
    this.difficultyLevel,
    this.isFeatured,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      // Sửa lỗi: API trả về 'collection_name' không phải 'name'
      name: json['collection_name'] ?? json['name'] ?? '',
      description: json['description'],
      languageFront: json['language_front'],
      languageBack: json['language_back'],
      privacy: json['privacy'],
      userId: json['user_id'].toString(), // Convert to String
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),

      canEdit: json['can_edit'] ?? false,
      flashcards: (json['flashcards'] as List<dynamic>?)
          ?.map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],

      // Thêm các trường mới
      totalCards: json['total_cards'],
      averageRating: json['average_rating'],
      totalRatings: json['total_ratings'],
      totalDuplicates: json['total_duplicates'],
      difficultyLevel: json['difficulty_level'],
      isFeatured: json['is_featured'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection_name': name,
      'description': description,
      'language_front': languageFront,
      'language_back': languageBack,
      'privacy': privacy,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_cards': totalCards,
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'total_duplicates': totalDuplicates,
      'difficulty_level': difficultyLevel,
      'is_featured': isFeatured,
    };
  }
}