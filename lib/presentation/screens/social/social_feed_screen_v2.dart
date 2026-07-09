import 'package:flutter/material.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final repository = SocialMediaRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: repository.fetchSocialFeed(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              child: ListTile(
                title: Text(post.authorName),
                subtitle: Text(post.content),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${post.likes} likes'),
                    Text('${post.comments} comentarios'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
