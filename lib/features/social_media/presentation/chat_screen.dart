import 'package:flutter/material.dart';
import 'package:jumpup_app/features/social_media/data/social_media_repository.dart';
import 'package:jumpup_app/features/social_media/presentation/message_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final repository = SocialMediaRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: repository.fetchMessages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final threads = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: threads.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final thread = threads[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                    child: Text(thread.participantName.substring(0, 1))),
                title: Text(thread.title),
                subtitle: Text(thread.lastMessage ?? 'Sin mensajes recientes'),
                trailing: thread.unreadCount > 0
                    ? CircleAvatar(
                        radius: 10, child: Text('${thread.unreadCount}'))
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MessageDetailScreen(thread: thread),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
