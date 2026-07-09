// language_model.dart
class Language {
  final int id;
  final String name;
  final String code;
  final String flagIconUrl;

  Language({required this.id, required this.name, required this.code, required this.flagIconUrl});

  factory Language.fromJson(Map<String, dynamic> json) => Language(
    id: json['id'],
    name: json['name'],
    code: json['code'],
    flagIconUrl: json['flag_icon_url'] ?? '',
  );
}