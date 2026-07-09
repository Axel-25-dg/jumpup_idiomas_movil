class UserProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? nativeLanguage;
  final String? timezone;
  final List<int> languagesLearning; // IDs
  final List<int> languagesTeaching; // IDs

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.nativeLanguage,
    this.timezone,
    required this.languagesLearning,
    required this.languagesTeaching,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatarUrl: json['avatar_url'],
      nativeLanguage: json['native_language'],
      timezone: json['timezone'],
      languagesLearning: List<int>.from(json['languages_learning'] ?? []),
      languagesTeaching: List<int>.from(json['languages_teaching'] ?? []),
    );
  }
}
