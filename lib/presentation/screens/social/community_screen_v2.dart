import 'package:flutter/material.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';
import 'package:jumpup_app/presentation/screens/social/forum_create_dialog.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final repository = SocialMediaRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: repository.fetchForumThreads(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final threads = snapshot.data!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Foro de comunidad',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      final created = await showDialog<bool>(
                        context: context,
                        builder: (_) => const ForumCreateDialog(),
                      );
                      if (created == true && mounted) {
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: threads.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final thread = threads[index];
                  return Card(
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text(thread.title)),
                          if (thread.isPinned)
                            const Icon(Icons.push_pin,
                                size: 16, color: Colors.amber),
                        ],
                      ),
                      subtitle: Text(
                          '${thread.authorName} · ${thread.language} · ${thread.replies} respuestas'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
