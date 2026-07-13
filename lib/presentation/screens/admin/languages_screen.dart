import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';
import 'package:jumpup_app/presentation/providers/language_provider.dart';
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
      body: Stack(
        children: [
          // Fondos decorativos
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                    blurRadius: 100,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                    blurRadius: 80,
                  )
                ],
              ),
            ),
          ),

          RefreshIndicator(
            onRefresh: () => notifier.refresh(),
            color: const Color(0xFF7C4DFF),
            backgroundColor: const Color(0xFF1E1E2A),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    title: const Text(
                      'Idiomas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1E1E2A),
                            const Color(0xFF0F0E1A).withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add_rounded, color: Color(0xFF00E5FF)),
                      onPressed: () => _showAddEditDialog(context),
                      tooltip: 'Agregar idioma',
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                      onPressed: () => notifier.refresh(),
                      tooltip: 'Refrescar',
                    ),
                  ],
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  sliver: languagesAsync.when(
                    loading: () => const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                    ),
                    error: (error, stack) => SliverFillRemaining(
                      child: _buildErrorView(error, notifier),
                    ),
                    data: (languages) {
                      if (languages.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyState(
                            title: 'No hay idiomas configurados',
                            subtitle: 'Agrega tu primer idioma para comenzar',
                            icon: Icons.translate_rounded,
                            buttonText: 'Agregar idioma',
                            onButtonPressed: () => _showAddEditDialog(context),
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final language = languages[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _LanguageCard(
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
                              ),
                            );
                          },
                          childCount: languages.length,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Object error, LanguageNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF5252)),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar idiomas',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
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
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2A),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            language != null ? 'Editar idioma' : 'Agregar idioma',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Form(
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
                    // ✅ TextFormField para código ISO con inputFormatters
                    TextFormField(
                      controller: _codeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Código ISO',
                        labelStyle: const TextStyle(color: Colors.white54),
                        hintText: 'Ej: es, en, fr...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.code_rounded, color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF7C4DFF)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFF5252)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2),
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z]'),
                        ),
                        // ✅ Convertir a minúsculas automáticamente
                        TextInputFormatter.withFunction(
                          (oldValue, newValue) {
                            return newValue.copyWith(
                              text: newValue.text.toLowerCase(),
                            );
                          },
                        ),
                      ],
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white38),
              ),
            ),
            PrimaryButton(
              label: language != null ? 'Actualizar' : 'Guardar',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final notifier = ref.read(languageNotifierProvider.notifier);

                  final flagUrl = _flagUrlController.text.isNotEmpty
                      ? _flagUrlController.text
                      : null;

                  if (language != null) {
                    notifier.editLanguage(
                      language.id,
                      _nameController.text.trim(),
                      _codeController.text.trim().toLowerCase(),
                      flagIconUrl: flagUrl,
                    );
                  } else {
                    notifier.addLanguage(
                      _nameController.text.trim(),
                      _codeController.text.trim().toLowerCase(),
                      flagIconUrl: flagUrl,
                    );
                  }
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        );
      },
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
        backgroundColor: const Color(0xFF1E1E2A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Eliminar idioma',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este idioma?\n'
          'Esta acción no se puede deshacer y afectará a los cursos asociados.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white38),
            ),
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
    final accentColor = const Color(0xFF7C4DFF);

    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          onTap: onEdit,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      language.code.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
          title: Text(
            language.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            'Código: ${language.code.toUpperCase()}',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                onPressed: onEdit,
                color: Colors.white38,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                onPressed: onDelete,
                color: const Color(0xFFFF5252).withValues(alpha: 0.7),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}