// course_model.dart
class Course {
  final int id;
  final int languageId;
  final String languageName;
  final String title;
  final String description;
  final String difficultyLevel;
  final String imageUrl;

  Course({required this.id, required this.languageId, required this.languageName, 
          required this.title, required this.description, required this.difficultyLevel, required this.imageUrl});

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'],
    languageId: json['language'],
    languageName: json['language_name'],
    title: json['title'],
    description: json['description'],
    difficultyLevel: json['difficulty_level'],
    imageUrl: json['image_url'] ?? '',
  );
}