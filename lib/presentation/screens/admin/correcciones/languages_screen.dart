import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/language_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class LanguagesScreen extends ConsumerStatefulWidget {
  const LanguagesScreen({super.key});

  @override
  ConsumerState<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends ConsumerState<LanguagesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _flagUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _flagUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languagesAsync = ref.watch(languageNotifierProvider);
    final notifier = ref.read(languageNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        title: const Text('Language Assets',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF00E5FF)),
            onPressed: () => _showAddEditDialog(context),
            tooltip: 'Add Language',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              ),
            ),
          ),
          RefreshIndicator(
            color: const Color(0xFF7C4DFF),
            onRefresh: () => notifier.refresh(),
            child: languagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
              error: (error, stack) => _buildErrorView(error, notifier),
              data: (languages) {
                if (languages.isEmpty) {
                  return EmptyState(
                    title: 'No languages configured',
                    subtitle: 'Add your first language to start localizing content',
                    icon: Icons.translate_rounded,
                    buttonText: 'Add Language',
                    onButtonPressed: () => _showAddEditDialog(context),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    return _LanguageCard(
                      language: language,
                      onEdit: () => _showAddEditDialog(context, language: language),
                      onDelete: () => _confirmDelete(context, language.id, notifier),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Object error, LanguageNotifier notifier) {
    return Center(
      child: GlassContainer(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF5252)),
            const SizedBox(height: 16),
            const Text('Sync Error', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(error.toString(), style: const TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Retry', onPressed: () => notifier.refresh(), icon: Icons.refresh_rounded),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {Language? language}) {
    if (language != null) {
      _nameController.text = language.name;
      _codeController.text = language.code;
      _flagUrlController.text = language.flagIconUrl;
    } else {
      _nameController.clear();
      _codeController.clear();
      _flagUrlController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(language != null ? 'Edit Language' : 'New Language', style: const TextStyle(color: Colors.white)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandedTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'English, Spanish, French...',
                prefixIcon: Icons.language_rounded,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              BrandedTextField(
                controller: _codeController,
                label: 'ISO Code',
                hint: 'en, es, fr...',
                prefixIcon: Icons.code_rounded,
                validator: (v) => (v?.length ?? 0) != 2 ? 'Must be 2 chars' : null,
              ),
              const SizedBox(height: 16),
              BrandedTextField(
                controller: _flagUrlController,
                label: 'Flag URL (Optional)',
                hint: 'https://flagcdn.com/us.png',
                prefixIcon: Icons.image_rounded,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          PrimaryButton(
            label: language != null ? 'Update' : 'Save',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final notifier = ref.read(languageNotifierProvider.notifier);
                if (language != null) {
                  notifier.editLanguage(language.id, _nameController.text, _codeController.text, flagIconUrl: _flagUrlController.text);
                } else {
                  notifier.addLanguage(_nameController.text, _codeController.text, flagIconUrl: _flagUrlController.text);
                }
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, LanguageNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Language', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure? This will affect all courses linked to this language.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5252), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () { notifier.deleteLanguage(id); Navigator.pop(ctx); },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.language, required this.onEdit, required this.onDelete});
  final Language language;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          onTap: onEdit,
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: const Color(0xFF7C4DFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
            child: language.flagIconUrl.isNotEmpty
                ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(language.flagIconUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.language, color: Color(0xFF7C4DFF))))
                : const Icon(Icons.language, color: Color(0xFF7C4DFF)),
          ),
          title: Text(language.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text('Code: ${language.code.toUpperCase()}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF5252), size: 22),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
