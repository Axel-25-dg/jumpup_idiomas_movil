import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final forumAsync = ref.watch(forumThreadsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foro de la Comunidad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(forumThreadsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showDialog<bool>(
            context: context,
            builder: (_) => const ForumCreateDialog(),
          );
          if (created == true && context.mounted) {
            ref.invalidate(forumThreadsProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Tema'),
      ),
      body: forumAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 48,
                    color: theme.colorScheme.error),
                const SizedBox(height: 12),
                Text('Error al cargar el foro',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(forumThreadsProvider),
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
                  Icon(Icons.forum_outlined,
                      size: 64,
                      color: theme.colorScheme.primary
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('No hay temas aún',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('¡Crea el primer tema!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
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
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: thread.isPinned
              ? Colors.amber.shade100
              : theme.colorScheme.primaryContainer,
          child: Icon(
            thread.isPinned ? Icons.push_pin : Icons.forum_outlined,
            size: 20,
            color: thread.isPinned
                ? Colors.amber.shade800
                : theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          thread.title,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(thread.authorName,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500)),
              const Text(' · ',
                  style: TextStyle(color: Colors.grey)),
              Text(thread.language,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.primary)),
              const Spacer(),
              Icon(Icons.chat_bubble_outline,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('${thread.replies}',
                  style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        trailing: thread.isPinned
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Fijado',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: Colors.amber.shade800)),
              )
            : null,
        onTap: () {
          // TODO: Navigate to thread detail
        },
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
      title: const Text('Nuevo tema'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: '¿De qué quieres hablar?',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Escribe más detalles...',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _languages.contains(languageController.text)
                  ? languageController.text
                  : 'en',
              decoration: const InputDecoration(labelText: 'Idioma'),
              items: _languages
                  .map((l) => DropdownMenuItem(
                      value: l,
                      child: Text(l.toUpperCase())))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  languageController.text = v;
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
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
                      SnackBar(content: Text('Error: $e')),
                    );
                    setState(() => loading = false);
                  }
                },
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Publicar'),
        ),
      ],
    );
  }
}
