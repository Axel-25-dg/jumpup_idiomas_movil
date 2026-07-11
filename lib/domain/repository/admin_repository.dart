import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';
import 'package:jumpup_app/domain/model/admin/report_model.dart';
import 'package:jumpup_app/domain/model/admin/announcement_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_subscription_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_stats_model.dart';

/// Contrato para operaciones exclusivas del rol Admin.
///
/// Cubre usuarios, reportes, anuncios, suscripciones y estadísticas globales.
abstract class AdminRepository {
  // ── Usuarios ───────────────────────────────────────────────────────────────

  /// Devuelve la lista completa de usuarios registrados.
  Future<List<User>> fetchUsers();

  /// Actualiza un campo específico de un usuario (ej: rol, estado).
  Future<void> updateUser(int id, Map<String, dynamic> data);

  // ── Idiomas ────────────────────────────────────────────────────────────────

  /// Devuelve todos los idiomas de la plataforma.
  Future<List<Language>> fetchLanguages();

  /// Crea un nuevo idioma.
  Future<void> createLanguage(Map<String, dynamic> data);

  // ── Reportes ───────────────────────────────────────────────────────────────

  /// Devuelve la lista de reportes generados por usuarios.
  Future<List<Report>> fetchReports();

  /// Actualiza el estado de un reporte (ej: resuelto, en revisión).
  Future<void> updateReport(int id, Map<String, dynamic> data);

  // ── Anuncios ───────────────────────────────────────────────────────────────

  /// Devuelve todos los anuncios publicados.
  Future<List<Announcement>> fetchAnnouncements();

  // ── Suscripciones ──────────────────────────────────────────────────────────

  /// Devuelve los planes de suscripción disponibles.
  Future<List<Subscription>> fetchSubscriptions();

  /// Inicia el proceso de pago para una suscripción.
  Future<String> initiateCheckout(int subscriptionId);

  // ── Estadísticas globales ─────────────────────────────────────────────────

  /// Devuelve las métricas globales del panel de administración.
  Future<AdminStats> getAdminStats();
}
