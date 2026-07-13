import 'package:jumpup_app/domain/model/social_media_models.dart';

/// Contrato para la funcionalidad social y de sesiones en vivo.
abstract class SocialRepositoryBase {
  // ── Feed ───────────────────────────────────────────────────────────────────

  /// Devuelve el feed social del usuario.
  Future<List<SocialPost>> fetchSocialFeed();

  // ── Chat ───────────────────────────────────────────────────────────────────

  /// Devuelve los hilos de conversación del usuario.
  Future<List<MessageThread>> fetchThreads();

  // ── Sesiones en vivo ───────────────────────────────────────────────────────

  /// Devuelve todas las sesiones en vivo disponibles.
  Future<List<LiveSession>> fetchLiveSessions();

  /// Crea una nueva sesión en vivo.
  Future<void> createLiveSession({
    required String title,
    required int courseId,
    required DateTime startsAt,
    String? meetingUrl,
  });

  /// Marca una sesión como iniciada.
  Future<void> startLiveSession(int sessionId);

  /// Marca una sesión como finalizada.
  Future<void> endLiveSession(int sessionId);
}
