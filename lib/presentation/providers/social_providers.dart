import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';

final socialRepositoryProvider = Provider<SocialMediaRepository>((ref) {
  return SocialMediaRepository();
});

final socialFeedProvider = FutureProvider<List<SocialPost>>((ref) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.fetchSocialFeed();
});

final chatThreadsProvider = FutureProvider<List<MessageThread>>((ref) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.fetchMessages();
});

final forumThreadsProvider = FutureProvider<List<ForumThread>>((ref) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.fetchForumThreads();
});

final liveSessionsProvider = FutureProvider<List<LiveSession>>((ref) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.fetchLiveSessions();
});

final notificationsProvider = FutureProvider<List<NotificationItem>>((ref) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.fetchNotifications();
});

final searchResultsProvider = FutureProvider.family<List<SearchResult>, String>(
  (ref, query) async {
    if (query.trim().isEmpty) return [];
    final repo = ref.watch(socialRepositoryProvider);
    return repo.search(query);
  },
);

final chatMessagesProvider =
    FutureProvider.family<List<ChatMessage>, String>((ref, threadId) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.fetchChatMessages(threadId);
});
