class Collection {
  final int id;
  final String title;
  final String description;
  final String? image;
  final int star;

  Collection({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.star,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      star: json['star'] ?? 0,
    );
  }
}
