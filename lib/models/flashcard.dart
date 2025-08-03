class Flashcard {
  final int id;
  final String collectionId;
  final String front;
  final String back;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Thêm các trường mới từ API response
  final String? pronunciation;
  final String? kanji;
  final Map<String, dynamic>? extraData;

  final MatchingOptions? matchingOptions;
  final TestOptions? testOptions;

  Flashcard({
    required this.id,
    required this.collectionId,
    required this.front,
    required this.back,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.pronunciation,
    this.kanji,
    this.extraData,

    this.matchingOptions,
    this.testOptions,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      collectionId: json['collection_id']?.toString() ?? '',
      front: json['front'] ?? '',
      back: json['back'] ?? '',
      image: json['image'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      pronunciation: json['pronunciation'],
      kanji: json['kanji'],
      extraData: json['extra_data'] as Map<String, dynamic>?,

      matchingOptions: json['matching_options'] != null
          ? MatchingOptions.fromJson(json['matching_options'])
          : null,
      testOptions: json['test_options'] != null
          ? TestOptions.fromJson(json['test_options'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection_id': collectionId,
      'front': front,
      'back': back,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'pronunciation': pronunciation,
      'kanji': kanji,
      'extra_data': extraData,

      'matching_options': matchingOptions?.toJson(),
      'test_options': testOptions?.toJson(),
    };
  }
}

class MatchingOptions {
  final List<String> options;
  final String correctAnswer;

  MatchingOptions({
    required this.options,
    required this.correctAnswer,
  });

  factory MatchingOptions.fromJson(Map<String, dynamic> json) {
    return MatchingOptions(
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correct_answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'options': options,
      'correct_answer': correctAnswer,
    };
  }
}

class TestOptions {
  final List<String> options;
  final int correctIndex;

  TestOptions({required this.options, required this.correctIndex});

  factory TestOptions.fromJson(Map<String, dynamic> json) {
    return TestOptions(
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correct_index'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'options': options,
      'correct_index': correctIndex,
    };
  }
}