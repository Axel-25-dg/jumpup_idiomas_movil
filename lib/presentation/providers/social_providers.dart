import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/social/chat_repository_impl.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/domain/repository/chat_repository.dart';

final socialRepositoryProvider = Provider<SocialMediaRepository>((ref) {
  return const SocialMediaRepository();
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repo = ChatRepositoryImpl();
  ref.onDispose(() => repo.disconnect());
  return repo;
});

// ── Feed ─────────────────────────────────────────────────────────────────────

final socialFeedProvider = FutureProvider<List<SocialPost>>((ref) async {
  return ref.watch(socialRepositoryProvider).fetchSocialFeed();
});

final postCommentsProvider =
    FutureProvider.family<List<SocialComment>, int>((ref, postId) async {
  return ref.watch(socialRepositoryProvider).fetchComments(postId);
});

// ── Chat ─────────────────────────────────────────────────────────────────────

final chatThreadsProvider = FutureProvider<List<MessageThread>>((ref) async {
  return ref.watch(chatRepositoryProvider).getThreads();
});

final chatMessagesProvider =
    FutureProvider.family<List<ChatMessage>, int>((ref, threadId) async {
  return ref.watch(chatRepositoryProvider).getMessages(threadId);
});

// ── Foro ─────────────────────────────────────────────────────────────────────

final forumCategoriesProvider =
    FutureProvider<List<ForumCategory>>((ref) async {
  return ref.watch(socialRepositoryProvider).fetchForumCategories();
});

final forumThreadsProvider =
    FutureProvider.family<List<ForumThread>, int?>((ref, categoryId) async {
  return ref.watch(socialRepositoryProvider).fetchForumThreads(categoryId: categoryId);
});

final forumPostsProvider =
    FutureProvider.family<List<ForumPost>, int>((ref, threadId) async {
  return ref.watch(socialRepositoryProvider).fetchForumPosts(threadId);
});

// ── Sesiones en Vivo ─────────────────────────────────────────────────────────

final liveSessionsProvider = FutureProvider<List<LiveSession>>((ref) async {
  return ref.watch(socialRepositoryProvider).fetchLiveSessions();
});

// ── Notificaciones ───────────────────────────────────────────────────────────

final notificationsProvider =
    FutureProvider<List<NotificationItem>>((ref) async {
  return ref.watch(socialRepositoryProvider).fetchNotifications();
});

final unreadNotificationsProvider = FutureProvider<int>((ref) async {
  return ref.watch(socialRepositoryProvider).fetchUnreadCount();
});

// ── Búsqueda ─────────────────────────────────────────────────────────────────

final searchResultsProvider =
    FutureProvider.family<List<SearchResult>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  return ref.watch(socialRepositoryProvider).search(query);
});
