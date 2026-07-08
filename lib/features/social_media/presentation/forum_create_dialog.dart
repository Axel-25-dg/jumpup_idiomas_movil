import 'package:flutter/material.dart';
import 'package:jumpup_app/features/social_media/data/social_media_repository.dart';

class ForumCreateDialog extends StatefulWidget {
  const ForumCreateDialog({super.key});

  @override
  State<ForumCreateDialog> createState() => _ForumCreateDialogState();
}

class _ForumCreateDialogState extends State<ForumCreateDialog> {
  final repository = SocialMediaRepository();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final languageController = TextEditingController(text: 'Inglés');
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear publicación'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: bodyController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: languageController,
            decoration: const InputDecoration(labelText: 'Idioma'),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() => loading = true);
                  await repository.createForumThread(
                    title: titleController.text,
                    body: bodyController.text,
                    language: languageController.text,
                  );
                  if (!mounted) return;
                  Navigator.pop(context, true);
                },
          child: loading
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const Text('Publicar'),
        ),
      ],
    );
  }
}
