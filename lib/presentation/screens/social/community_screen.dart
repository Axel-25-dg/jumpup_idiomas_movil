import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forumAsync = ref.watch(forumThreadsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Foro',
            style: AppTextStyles.titleLarge
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => ref.invalidate(forumThreadsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 3,
        onPressed: () async {
          final created = await showDialog<bool>(
            context: context,
            builder: (_) => const ForumCreateDialog(),
          );
          if (created == true && context.mounted) {
            ref.invalidate(forumThreadsProvider);
          }
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Nuevo Tema',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
      body: forumAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('Error al cargar el foro',
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(forumThreadsProvider),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (threads) {
          if (threads.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                    child: Icon(Icons.forum_outlined,
                        size: 56,
                        color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(height: 16),
                  Text('No hay temas aún',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('¡Crea el primer tema!',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final thread = threads[index];
              return _ForumThreadCard(thread: thread);
            },
          );
        },
      ),
    );
  }
}

class _ForumThreadCard extends StatelessWidget {
  const _ForumThreadCard({required this.thread});
  final ForumThread thread;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: thread.isPinned ? AppColors.secondary : AppColors.divider,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: thread.isPinned
              ? AppColors.secondary.withValues(alpha: 0.15)
              : AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            thread.isPinned ? Icons.push_pin_rounded : Icons.forum_outlined,
            size: 20,
            color: thread.isPinned ? AppColors.secondary : AppColors.primary,
          ),
        ),
        title: Text(
          thread.title,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(thread.authorName,
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w500)),
              Text(' · ',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textHint)),
              Text(thread.language.toUpperCase(),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary)),
              const Spacer(),
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${thread.replies}', style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        trailing: thread.isPinned
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Fijado',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.secondary)),
              )
            : null,
        onTap: () {},
      ),
    );
  }
}

class ForumCreateDialog extends StatefulWidget {
  const ForumCreateDialog({super.key});

  @override
  State<ForumCreateDialog> createState() => _ForumCreateDialogState();
}

class _ForumCreateDialogState extends State<ForumCreateDialog> {
  final repository = SocialMediaRepository();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final languageController = TextEditingController(text: 'en');
  bool loading = false;
  final _languages = ['en', 'es', 'fr', 'de', 'it', 'pt', 'ja', 'zh', 'ko'];

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Nuevo tema',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          )),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: AppTextStyles.inputLabel,
                hintText: '¿De qué quieres hablar?',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 4,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: AppTextStyles.inputLabel,
                hintText: 'Escribe más detalles...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _languages.contains(languageController.text)
                  ? languageController.text
                  : 'en',
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Idioma',
                labelStyle: AppTextStyles.inputLabel,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              items: _languages
                  .map((l) => DropdownMenuItem(
                      value: l, child: Text(l.toUpperCase())))
                  .toList(),
              onChanged: (v) {
                if (v != null) languageController.text = v;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar',
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.textSecondary)),
        ),
        FilledButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() => loading = true);
                  try {
                    await repository.createForumThread(
                      title: titleController.text,
                      body: bodyController.text,
                      language: languageController.text,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al crear tema'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    setState(() => loading = false);
                  }
                },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Publicar'),
        ),
      ],
    );
  }
}
