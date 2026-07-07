import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';

// Modelo temporal para idiomas (GET /api/languages/)
class Language {
  final String code;
  final String name;
  final String flag;

  const Language({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Idiomas activos simulados - GET /api/languages/
  final List<Language> _languages = const [
    Language(code: 'en', name: 'Inglés', flag: '🇺🇸'),
    Language(code: 'fr', name: 'Francés', flag: '🇫🇷'),
    Language(code: 'de', name: 'Alemán', flag: '🇩🇪'),
    Language(code: 'it', name: 'Italiano', flag: '🇮🇹'),
    Language(code: 'pt', name: 'Portugués', flag: '🇧🇷'),
    Language(code: 'zh', name: 'Chino', flag: '🇨🇳'),
    Language(code: 'ja', name: 'Japonés', flag: '🇯🇵'),
    Language(code: 'ko', name: 'Coreano', flag: '🇰🇷'),
    Language(code: 'ru', name: 'Ruso', flag: '🇷🇺'),
    Language(code: 'ar', name: 'Árabe', flag: '🇸🇦'),
  ];

  final Set<String> _selectedLanguages = {};
  bool _isSaving = false;

  void _savePreferences() async {
    if (_selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un idioma')),
      );
      return;
    }
    setState(() => _isSaving = true);
    // Simulate PATCH /api/auth/profile/update-languages/
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSaving = false);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.twoFactor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Qué idiomas quieres aprender?'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Selecciona los idiomas que deseas aprender. Puedes cambiar esto después en tu perfil.',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = _selectedLanguages.contains(language.code);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedLanguages.remove(language.code);
                      } else {
                        _selectedLanguages.add(language.code);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(language.flag, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          language.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _savePreferences,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text(
                      'Continuar (${_selectedLanguages.length} seleccionado${_selectedLanguages.length == 1 ? '' : 's'})',
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
