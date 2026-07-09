// language_model.dart
class Language {
  final int id;
  final String name;
  final String code;
  final String flagIconUrl;

  Language(
      {required this.id,
      required this.name,
      required this.code,
      required this.flagIconUrl});

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        name: json['name']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        flagIconUrl: json['flag_icon_url']?.toString() ?? '',
      );
}
