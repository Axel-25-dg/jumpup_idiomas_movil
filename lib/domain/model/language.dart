class LanguageModel {
  final String code;     // e.g. 'en', 'fr'
  final String name;     // e.g. 'Inglés'
  final String flag;     // e.g. '🇺🇸'
  final bool isActive;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.flag,
    this.isActive = true,
  });
}
