import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/domain/model/user_model.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/screens/auth/forgot_password_screen.dart';
import 'package:jumpup_app/presentation/screens/auth/login_screen.dart';
import 'package:jumpup_app/presentation/screens/auth/register_screen.dart';
import 'package:jumpup_app/presentation/screens/auth/splash_screen.dart';
import 'package:jumpup_app/presentation/screens/student/dashboard_screen.dart';
import 'package:jumpup_app/presentation/screens/student/course_list_screen.dart';
import 'package:jumpup_app/presentation/screens/student/course_detail_screen.dart';
import 'package:jumpup_app/presentation/screens/student/lesson_detail_screen.dart';
import 'package:jumpup_app/presentation/screens/student/exercise_screen.dart';
import 'package:jumpup_app/presentation/screens/student/learning_path_screen.dart';
import 'package:jumpup_app/presentation/screens/student/profile_screen.dart'
    as student_profile;
import 'package:jumpup_app/presentation/screens/student/progress_screen.dart';
import 'package:jumpup_app/presentation/screens/student/ranking_screen.dart';
import 'package:jumpup_app/presentation/screens/student/achievements_screen.dart';
import 'package:jumpup_app/presentation/screens/student/certificates_screen.dart';
import 'package:jumpup_app/presentation/screens/student/virtual_class_list_screen.dart';
import 'package:jumpup_app/presentation/screens/student/ai_tutor_screen.dart';
import 'package:jumpup_app/presentation/screens/student/daily_challenges_screen.dart';
import 'package:jumpup_app/presentation/screens/student/subscriptions_screen.dart'
    as student_subs;
import 'package:jumpup_app/presentation/screens/student/payment_history_screen.dart';
import 'package:jumpup_app/presentation/screens/student/settings_screen.dart';
import 'package:jumpup_app/presentation/screens/student/classroom_resources_screen.dart';
import 'package:jumpup_app/presentation/screens/social/social_media_shell.dart';

// NUEVAS IMPORTACIONES TEACHER

import 'package:jumpup_app/presentation/screens/admin/teacher_dashboard_screen.dart';

// NUEVAS IMPORTACIONES ADMIN
import 'package:jumpup_app/presentation/screens/admin/correcciones/admin_dashboard_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/announcements_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/classrooms_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/courses_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/exercises_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/languages_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/reports_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/suscription_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/users_screen.dart';

abstract final class AppRoutes {
  // Auth
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // Social
  static const home = '/home';

  // Student
  static const studentDashboard = '/student';
  static const studentCourses = '/student/courses';
  static const studentCourseDetail = '/student/course/:id';
  static const studentLessonDetail = '/student/lesson/:id';
  static const studentExercise = '/student/exercise/:lessonId';
  static const studentLearningPath = '/student/learning-path';
  static const studentProfile = '/student/profile';
  static const studentProgress = '/student/progress';
  static const studentRanking = '/student/ranking';
  static const studentAchievements = '/student/achievements';
  static const studentCertificates = '/student/certificates';
  static const studentClassrooms = '/student/classrooms';
  static const studentResources = '/student/resources';
  static const studentAiTutor = '/student/ai-tutor';
  static const studentDailyChallenges = '/student/daily-challenges';
  static const studentSubscriptions = '/student/subscriptions';
  static const studentPayments = '/student/payments';
  static const studentSettings = '/student/settings';

  // ✅ NUEVAS RUTAS TEACHER
  static const teacherDashboard = '/teacher';
  static const teacherClassrooms = '/teacher/classrooms';
  static const teacherExercises = '/teacher/exercises';

  // ✅ NUEVAS RUTAS ADMIN
  static const adminDashboard = '/admin';
  static const adminUsers = '/admin/users';
  static const adminLanguages = '/admin/languages';
  static const adminCourses = '/admin/courses';
  static const adminAnnouncements = '/admin/announcements';
  static const adminReports = '/admin/reports';
  static const adminSubscriptions = '/admin/subscriptions';
  static const adminClassrooms = '/admin/classrooms';
  static const adminExercises = '/admin/exercises';
}

GoRouter buildAppRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuth = authState.status == AuthStatus.authenticated;
      final location = state.uri.toString();

      final isAuthRoute = location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.forgotPassword ||
          location == AppRoutes.splash;

      if (!isAuth && isProtectedRoute(location)) {
        return AppRoutes.login;
      }

      if (isAuth && isAuthRoute) {
        return routeForRole(authState.user!.role);
      }

      return null;
    },
    routes: [
      // ─── Auth ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ─── Social ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (_, __) => const SocialMediaShell(),
      ),

      // ─── Student ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.studentDashboard,
        name: 'studentDashboard',
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentCourses,
        name: 'studentCourses',
        builder: (_, __) => const CourseListScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentCourseDetail,
        name: 'studentCourseDetail',
        builder: (_, state) => CourseDetailScreen(
          courseId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.studentLessonDetail,
        name: 'studentLessonDetail',
        builder: (_, state) => LessonDetailScreen(
          lessonId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.studentExercise,
        name: 'studentExercise',
        builder: (_, state) => ExerciseScreen(
          lessonId: int.parse(state.pathParameters['lessonId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.studentLearningPath,
        name: 'studentLearningPath',
        builder: (_, __) => const LearningPathScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentProfile,
        name: 'studentProfile',
        builder: (_, __) => const student_profile.ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentProgress,
        name: 'studentProgress',
        builder: (_, __) => const ProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentRanking,
        name: 'studentRanking',
        builder: (_, __) => const RankingScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentAchievements,
        name: 'studentAchievements',
        builder: (_, __) => const AchievementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentCertificates,
        name: 'studentCertificates',
        builder: (_, __) => const CertificatesScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentClassrooms,
        name: 'studentClassrooms',
        builder: (_, __) => const VirtualClassListScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentResources,
        name: 'studentResources',
        builder: (_, __) => const ClassroomResourcesScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentAiTutor,
        name: 'studentAiTutor',
        builder: (_, __) => const AITutorScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentDailyChallenges,
        name: 'studentDailyChallenges',
        builder: (_, __) => const DailyChallengesScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentSubscriptions,
        name: 'studentSubscriptions',
        builder: (_, __) => const student_subs.SubscriptionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentPayments,
        name: 'studentPayments',
        builder: (_, __) => const PaymentHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentSettings,
        name: 'studentSettings',
        builder: (_, __) => const SettingsScreen(),
      ),

      // ─── Teacher ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.teacherDashboard,
        name: 'teacherDashboard',
        builder: (_, __) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherClassrooms,
        name: 'teacherClassrooms',
        builder: (_, __) => const ClassroomsScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherExercises,
        name: 'teacherExercises',
        builder: (_, __) => const ExercisesScreen(),
      ),

      // ─── Admin ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'adminDashboard',
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        name: 'adminUsers',
        builder: (_, __) => const UsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminLanguages,
        name: 'adminLanguages',
        builder: (_, __) => const LanguagesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCourses,
        name: 'adminCourses',
        builder: (_, __) => const CoursesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAnnouncements,
        name: 'adminAnnouncements',
        builder: (_, __) => const AnnouncementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminReports,
        name: 'adminReports',
        builder: (_, __) => const ReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSubscriptions,
        name: 'adminSubscriptions',
        builder: (_, __) => const SubscriptionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminClassrooms,
        name: 'adminClassrooms',
        builder: (_, __) => const ClassroomsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminExercises,
        name: 'adminExercises',
        builder: (_, __) => const ExercisesScreen(),
      ),
    ],
  );
}

String routeForRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return AppRoutes.adminDashboard;
    case UserRole.teacher:
      return AppRoutes.teacherDashboard;
    case UserRole.student:
      return AppRoutes.studentDashboard;
    case UserRole.unknown:
      return AppRoutes.login;
  }
}

bool isProtectedRoute(String location) {
  if (location == AppRoutes.splash ||
      location == AppRoutes.login ||
      location == AppRoutes.register ||
      location == AppRoutes.forgotPassword) {
    return false;
  }
  return true;
}