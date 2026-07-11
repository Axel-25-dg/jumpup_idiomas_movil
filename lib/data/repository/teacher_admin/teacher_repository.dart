// lib/data/repository/teacher_admin/teacher_repository.dart
import 'package:jumpup_app/data/repository/teacher_admin/language_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/course_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/module_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/lesson_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/exercise_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/user_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/report_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/announcement_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/subscription_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/classroom_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/stats_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/resource_repository.dart';

class TeacherRepository {
  final LanguageRepository languages = LanguageRepository();
  final CourseRepository courses = CourseRepository();
  final ModuleRepository modules = ModuleRepository();
  final LessonRepository lessons = LessonRepository();
  final ExerciseRepository exercises = ExerciseRepository();
  final UserRepository users = UserRepository();
  final ReportRepository reports = ReportRepository();
  final AnnouncementRepository announcements = AnnouncementRepository();
  final SubscriptionRepository subscriptions = SubscriptionRepository();
  final ClassroomRepository classrooms = ClassroomRepository();
  final StatsRepository stats = StatsRepository();
  final ResourceRepository resources = ResourceRepository();

  Future<Object?> initiateCheckout(int id) async {}
}