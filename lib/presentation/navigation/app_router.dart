import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/domain/model/user_model.dart';
import 'package:jumpup_app/domain/model/classroom_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart' as admin_user;
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
import 'package:jumpup_app/presentation/screens/catalog/catalog_screen.dart';
import 'package:jumpup_app/presentation/screens/student/games_screen.dart';
import 'package:jumpup_app/presentation/screens/student/ai_tutor_screen.dart';
import 'package:jumpup_app/presentation/screens/student/daily_challenges_screen.dart';
import 'package:jumpup_app/presentation/screens/student/payment_history_screen.dart';
import 'package:jumpup_app/presentation/screens/student/settings_screen.dart';
import 'package:jumpup_app/presentation/screens/student/change_password_screen.dart';
import 'package:jumpup_app/presentation/screens/student/classroom_resources_screen.dart';
import 'package:jumpup_app/presentation/screens/student/cart/cart_screen.dart';
import 'package:jumpup_app/presentation/screens/social/social_media_shell.dart';

// IMPORTACIONES TEACHER
import 'package:jumpup_app/presentation/screens/admin/teacher_dashboard_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_classroom_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/manage_classroom_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_exercise_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/upload_resource_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/resource_library_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_module_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_lesson_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/teacher_inbox_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/manage_live_sessions_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_course_screen.dart';

// IMPORTACIONES ADMIN
import 'package:jumpup_app/presentation/screens/admin/announcements_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/classrooms_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/courses_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/exercises_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/languages_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/modules_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/reports_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/users_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/student_detail_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/lesson_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/certificates_screen.dart'; 


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
  static const studentResources = '/student/classroom/:classroomId/resources';
  static const studentAiTutor = '/student/ai-tutor';
  static const studentDailyChallenges = '/student/daily-challenges';
  static const studentSettings = '/student/settings';
  static const studentChangePassword = '/student/change-password';
  static const studentGames = '/student/games';
  static const studentCart = '/cart';
  static const studentCatalog = '/student/catalog';
  static const studentPaymentHistory = '/student/payment-history';

  // RUTAS TEACHER
  static const teacherDashboard = '/teacher';
  static const teacherCreateClassroom = '/teacher/create-classroom';
  static const teacherManageClassroom = '/teacher/classroom/:id';
  static const teacherCreateExercise = '/teacher/create-exercise';
  static const teacherUploadResource = '/teacher/upload-resource';
  static const teacherResources = '/teacher/resources';
  static const teacherCreateModule = '/teacher/create-module';
  static const teacherCreateLesson = '/teacher/create-lesson';
  static const teacherInbox = '/teacher/inbox';
  static const teacherLiveSessions = '/teacher/live-sessions';

  // RUTAS ADMIN
  static const adminDashboard = '/admin';
  static const adminUsers = '/admin/users';
  static const adminStudentDetail = '/admin/users/:id';
  static const adminLanguages = '/admin/languages';
  static const adminCourses = '/admin/courses';
  static const adminCreateCourse = '/admin/courses/create';
  static const adminModules = '/admin/modules';
  static const adminLessons = '/admin/lessons';
  static const adminAnnouncements = '/admin/announcements';
  static const adminReports = '/admin/reports';
  static const adminClassrooms = '/admin/classrooms';
  static const adminExercises = '/admin/exercises';
  static const adminCertificates = '/admin/certificates'; 

}

GoRouter buildAppRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      try {
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

        if (isAuth && isAuthRoute && authState.user != null) {
          return routeForRole(authState.user!.role);
        }

        return null;
      } catch (e) {
        debugPrint('Router redirect error: $e');
        return null;
      }
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
          courseId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: AppRoutes.studentLessonDetail,
        name: 'studentLessonDetail',
        builder: (_, state) => LessonDetailScreen(
          lessonId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: AppRoutes.studentExercise,
        name: 'studentExercise',
        builder: (_, state) => ExerciseScreen(
          lessonId: int.tryParse(state.pathParameters['lessonId'] ?? '') ?? 0,
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
        builder: (_, state) => ClassroomResourcesScreen(
          classroomId: int.tryParse(state.pathParameters['classroomId'] ?? '') ?? 0,
        ),
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
        path: AppRoutes.studentSettings,
        name: 'studentSettings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentChangePassword,
        name: 'studentChangePassword',
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentGames,
        name: 'studentGames',
        builder: (_, __) => const GamesScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentCart,
        name: 'studentCart',
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentCatalog,
        name: 'studentCatalog',
        builder: (_, __) => const CatalogScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentPaymentHistory,
        name: 'studentPaymentHistory',
        builder: (_, __) => const PaymentHistoryScreen(),
      ),

      // ─── Teacher ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.teacherDashboard,
        name: 'teacherDashboard',
        builder: (_, __) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherCreateClassroom,
        name: 'teacherCreateClassroom',
        builder: (_, state) {
          final classroom = state.extra as ClassroomModel?;
          return CreateClassroomScreen(classroom: classroom);
        },
      ),
      GoRoute(
        path: AppRoutes.teacherManageClassroom,
        name: 'teacherManageClassroom',
        builder: (_, state) => ManageClassroomScreen(
          classroomId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherCreateExercise,
        name: 'teacherCreateExercise',
        builder: (_, __) => const CreateExerciseScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherUploadResource,
        name: 'teacherUploadResource',
        builder: (_, __) => const UploadResourceScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherResources,
        name: 'teacherResources',
        builder: (_, __) => const ResourceLibraryScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherCreateModule,
        name: 'teacherCreateModule',
        builder: (_, __) => const CreateModuleScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherCreateLesson,
        name: 'teacherCreateLesson',
        builder: (_, __) => const CreateLessonScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherInbox,
        name: 'teacherInbox',
        builder: (_, __) => const TeacherInboxScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherLiveSessions,
        name: 'teacherLiveSessions',
        builder: (_, __) => const ManageLiveSessionsScreen(),
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
        path: AppRoutes.adminStudentDetail,
        name: 'adminStudentDetail',
        builder: (_, state) {
          final user = state.extra as admin_user.User;
          return StudentDetailScreen(user: user);
        },
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
        path: AppRoutes.adminCreateCourse,
        name: 'adminCreateCourse',
        builder: (_, __) => const CreateCourseScreen(),
      ),
      // ✅ NUEVAS RUTAS ADMIN
      GoRoute(
        path: AppRoutes.adminModules,
        name: 'adminModules',
        builder: (_, __) => const ModulesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminLessons,
        name: 'adminLessons',
        builder: (_, __) => const LessonsScreen(),
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
        path: AppRoutes.adminClassrooms,
        name: 'adminClassrooms',
        builder: (_, __) => const ClassroomsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminExercises,
        name: 'adminExercises',
        builder: (_, __) => const ExercisesScreen(),
      ),
      GoRoute(
      path: AppRoutes.adminCertificates,
      name: 'adminCertificates',
      builder: (_, __) => const CertificatesAdminScreen(),
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
      return AppRoutes.studentDashboard;
  }
}

bool isProtectedRoute(String location) {
  if (location == AppRoutes.splash ||
      location == AppRoutes.login ||
      location == AppRoutes.register ||
      location == AppRoutes.forgotPassword ||
      location == AppRoutes.studentCatalog) {
    return false;
  }
  return true;
}