import 'package:flutter/material.dart';
import 'package:jumpup_app/features/social_media/data/social_media_repository.dart';

class LiveSessionsScreen extends StatefulWidget {
  const LiveSessionsScreen({super.key});

  @override
  State<LiveSessionsScreen> createState() => _LiveSessionsScreenState();
}

class _LiveSessionsScreenState extends State<LiveSessionsScreen> {
  final repository = SocialMediaRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: repository.fetchLiveSessions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final sessions = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Card(
              child: ListTile(
                title: Text(session.title),
                subtitle: Text(
                    '${session.hostName} · ${session.startsAt.toLocal().toString().substring(0, 16)}'),
                trailing: Chip(label: Text(session.statusLabel)),
              ),
            );
          },
        );
      },
    );
  }
}
