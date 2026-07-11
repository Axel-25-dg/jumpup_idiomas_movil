// lib/presentation/screens/admin/languages_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/language_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Idiomas'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddEditDialog(context),
            tooltip: 'Agregar idioma',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: languagesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorView(error, notifier),
          data: (languages) {
            if (languages.isEmpty) {
              return EmptyState(
                title: 'No hay idiomas configurados',
                subtitle: 'Agrega tu primer idioma para comenzar',
                icon: Icons.translate_rounded,
                buttonText: 'Agregar idioma',
                onButtonPressed: () => _showAddEditDialog(context),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];
                return _LanguageCard(
                  language: language,
                  onEdit: () => _showAddEditDialog(
                    context,
                    language: language,
                  ),
                  onDelete: () => _confirmDelete(
                    context,
                    language.id,
                    notifier,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(Object error, LanguageNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar idiomas',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () => notifier.refresh(),
            icon: Icons.refresh_rounded,
          ),
        ],
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
        title: Text(language != null ? 'Editar idioma' : 'Agregar idioma'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandedTextField(
                controller: _nameController,
                label: 'Nombre del idioma',
                hint: 'Ej: Español, Inglés, Francés...',
                prefixIcon: Icons.language_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              BrandedTextField(
                controller: _codeController,
                label: 'Código ISO',
                hint: 'Ej: es, en, fr...',
                prefixIcon: Icons.code_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El código es obligatorio';
                  }
                  if (value.length != 2) {
                    return 'El código debe tener 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              BrandedTextField(
                controller: _flagUrlController,
                label: 'URL de la bandera (opcional)',
                hint: 'https://flagcdn.com/es.png',
                prefixIcon: Icons.image_rounded,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            label: language != null ? 'Actualizar' : 'Guardar',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final notifier = ref.read(languageNotifierProvider.notifier);

                if (language != null) {
                  notifier.editLanguage(
                    language.id,
                    _nameController.text,
                    _codeController.text,
                    flagIconUrl: _flagUrlController.text.isNotEmpty
                        ? _flagUrlController.text
                        : null,
                  );
                } else {
                  notifier.addLanguage(
                    _nameController.text,
                    _codeController.text,
                    flagIconUrl: _flagUrlController.text.isNotEmpty
                        ? _flagUrlController.text
                        : null,
                  );
                }
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    int languageId,
    LanguageNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar idioma'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este idioma?\n'
          'Esta acción no se puede deshacer y afectará a los cursos asociados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            label: 'Eliminar',
            onPressed: () {
              notifier.deleteLanguage(languageId);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.onEdit,
    required this.onDelete,
  });

  final Language language;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: language.flagIconUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    language.flagIconUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        language.code.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    language.code.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
        title: Text(
          language.name,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Código: ${language.code}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 20),
              onPressed: onEdit,
              color: AppColors.primary,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              onPressed: onDelete,
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}