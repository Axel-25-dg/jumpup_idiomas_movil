import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';

class UserProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String? avatar; // File field
  final String? avatarUrl; // URL field
  final String? nativeLanguage;
  final String? timezone;
  final List<int> languagesLearning; // IDs
  final List<Language> languagesLearningDetails;
  final List<int> languagesTeaching; // IDs
  final List<Language> languagesTeachingDetails;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.avatarUrl,
    this.nativeLanguage,
    this.timezone,
    required this.languagesLearning,
    required this.languagesLearningDetails,
    required this.languagesTeaching,
    required this.languagesTeachingDetails,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Parse languages_learning_details
    List<Language> learningDetails = [];
    if (json['languages_learning_details'] is List) {
      learningDetails = (json['languages_learning_details'] as List)
          .map((item) => Language.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Parse languages_teaching_details
    List<Language> teachingDetails = [];
    if (json['languages_teaching_details'] is List) {
      teachingDetails = (json['languages_teaching_details'] as List)
          .map((item) => Language.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return UserProfile(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      nativeLanguage: json['native_language'] as String?,
      timezone: json['timezone'] as String?,
      languagesLearning: List<int>.from(json['languages_learning'] ?? []),
      languagesLearningDetails: learningDetails,
      languagesTeaching: List<int>.from(json['languages_teaching'] ?? []),
      languagesTeachingDetails: teachingDetails,
    );
  }
}
