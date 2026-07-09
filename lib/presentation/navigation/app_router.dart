import 'package:go_router/go_router.dart';
import 'package:jumpup_app/data/local/token_storage.dart';
import 'package:jumpup_app/domain/model/user_model.dart';
import 'package:jumpup_app/presentation/screens/auth/forgot_password_screen.dart';
import 'package:jumpup_app/presentation/screens/auth/loading_screen.dart';
import 'package:jumpup_app/presentation/screens/auth/login_screen.dart';
import 'package:jumpup_app/presentation/screens/auth/register_screen.dart';
import 'package:jumpup_app/presentation/screens/auth/splash_screen.dart';
import 'package:jumpup_app/presentation/screens/student/dashboard_screen.dart';
import 'package:jumpup_app/presentation/screens/student/course_list_screen.dart';
import 'package:jumpup_app/presentation/screens/student/course_detail_screen.dart';
import 'package:jumpup_app/presentation/screens/student/lesson_detail_screen.dart';
import 'package:jumpup_app/presentation/screens/student/exercise_screen.dart';
import 'package:jumpup_app/presentation/screens/student/learning_path_screen.dart';
import 'package:jumpup_app/presentation/screens/student/profile_screen.dart' as student_profile;
import 'package:jumpup_app/presentation/screens/student/progress_screen.dart';
import 'package:jumpup_app/presentation/screens/student/ranking_screen.dart';
import 'package:jumpup_app/presentation/screens/student/achievements_screen.dart';
import 'package:jumpup_app/presentation/screens/student/certificates_screen.dart';
import 'package:jumpup_app/presentation/screens/student/virtual_class_list_screen.dart';
import 'package:jumpup_app/presentation/screens/student/ai_tutor_screen.dart';
import 'package:jumpup_app/presentation/screens/student/daily_challenges_screen.dart';
import 'package:jumpup_app/presentation/screens/student/subscriptions_screen.dart' as student_subs;
import 'package:jumpup_app/presentation/screens/student/payment_history_screen.dart';
import 'package:jumpup_app/presentation/screens/student/settings_screen.dart';
import 'package:jumpup_app/presentation/screens/student/classroom_resources_screen.dart';
import 'package:jumpup_app/presentation/screens/social/social_media_shell.dart';
import 'package:jumpup_app/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/teacher_dashboard_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_classroom_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/manage_classroom_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_exercise_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/upload_resource_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/profile_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/user_stats_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/users_list_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_course_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/announcements_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/report_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/subscriptions_screen.dart' as admin_subs;

abstract final class AppRoutes {
  // Auth
  static const splash = '/';
  static const loading = '/loading';
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

  // Teacher
  static const teacherDashboard = '/teacher';
  static const teacherCreateClassroom = '/teacher/create-classroom';
  static const teacherManageClassroom = '/teacher/classroom/:id';
  static const teacherCreateExercise = '/teacher/create-exercise';
  static const teacherUploadResource = '/teacher/upload-resource';
  static const teacherProfile = '/teacher/profile';
  static const teacherUserStats = '/teacher/user-stats/:studentId';

  // Admin
  static const adminDashboard = '/admin';
  static const adminUsers = '/admin/users';
  static const adminCreateCourse = '/admin/create-course';
  static const adminAnnouncements = '/admin/announcements';
  static const adminReports = '/admin/reports';
  static const adminSubscriptions = '/admin/subscriptions';
}

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      // Auth
      GoRoute(path: AppRoutes.splash, name: 'splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.loading, name: 'loading', builder: (_, __) => const LoadingScreen()),
      GoRoute(path: AppRoutes.login, name: 'login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, name: 'register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.forgotPassword, name: 'forgotPassword', builder: (_, __) => const ForgotPasswordScreen()),

      // Social
      GoRoute(path: AppRoutes.home, name: 'home', builder: (_, __) => const SocialMediaShell()),

      // Student
      GoRoute(path: AppRoutes.studentDashboard, name: 'studentDashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: AppRoutes.studentCourses, name: 'studentCourses', builder: (_, __) => const CourseListScreen()),
      GoRoute(path: AppRoutes.studentCourseDetail, name: 'studentCourseDetail', builder: (_, state) => CourseDetailScreen(courseId: int.parse(state.pathParameters['id']!))),
      GoRoute(path: AppRoutes.studentLessonDetail, name: 'studentLessonDetail', builder: (_, state) => LessonDetailScreen(lessonId: int.parse(state.pathParameters['id']!))),
      GoRoute(path: AppRoutes.studentExercise, name: 'studentExercise', builder: (_, state) => ExerciseScreen(lessonId: int.parse(state.pathParameters['lessonId']!))),
      GoRoute(path: AppRoutes.studentLearningPath, name: 'studentLearningPath', builder: (_, __) => const LearningPathScreen()),
      GoRoute(path: AppRoutes.studentProfile, name: 'studentProfile', builder: (_, __) => const student_profile.ProfileScreen()),
      GoRoute(path: AppRoutes.studentProgress, name: 'studentProgress', builder: (_, __) => const ProgressScreen()),
      GoRoute(path: AppRoutes.studentRanking, name: 'studentRanking', builder: (_, __) => const RankingScreen()),
      GoRoute(path: AppRoutes.studentAchievements, name: 'studentAchievements', builder: (_, __) => const AchievementsScreen()),
      GoRoute(path: AppRoutes.studentCertificates, name: 'studentCertificates', builder: (_, __) => const CertificatesScreen()),
      GoRoute(path: AppRoutes.studentClassrooms, name: 'studentClassrooms', builder: (_, __) => const VirtualClassListScreen()),
      GoRoute(path: AppRoutes.studentResources, name: 'studentResources', builder: (_, __) => const ClassroomResourcesScreen()),
      GoRoute(path: AppRoutes.studentAiTutor, name: 'studentAiTutor', builder: (_, __) => const AITutorScreen()),
      GoRoute(path: AppRoutes.studentDailyChallenges, name: 'studentDailyChallenges', builder: (_, __) => const DailyChallengesScreen()),
      GoRoute(path: AppRoutes.studentSubscriptions, name: 'studentSubscriptions', builder: (_, __) => const student_subs.SubscriptionsScreen()),
      GoRoute(path: AppRoutes.studentPayments, name: 'studentPayments', builder: (_, __) => const PaymentHistoryScreen()),
      GoRoute(path: AppRoutes.studentSettings, name: 'studentSettings', builder: (_, __) => const SettingsScreen()),

      // Teacher
      GoRoute(path: AppRoutes.teacherDashboard, name: 'teacherDashboard', builder: (_, __) => const TeacherDashboardScreen()),
      GoRoute(path: AppRoutes.teacherCreateClassroom, name: 'teacherCreateClassroom', builder: (_, __) => const CreateClassroomScreen()),
      GoRoute(path: AppRoutes.teacherManageClassroom, name: 'teacherManageClassroom', builder: (_, state) => ManageClassroomScreen(classroomId: int.parse(state.pathParameters['id']!))),
      GoRoute(path: AppRoutes.teacherCreateExercise, name: 'teacherCreateExercise', builder: (_, __) => const CreateExerciseScreen()),
      GoRoute(path: AppRoutes.teacherUploadResource, name: 'teacherUploadResource', builder: (_, __) => const UploadResourceScreen()),
      GoRoute(path: AppRoutes.teacherProfile, name: 'teacherProfile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: AppRoutes.teacherUserStats, name: 'teacherUserStats', builder: (_, state) => StudentStatsScreen(studentId: state.pathParameters['studentId']!, studentName: ''),),

      // Admin
      GoRoute(path: AppRoutes.adminDashboard, name: 'adminDashboard', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(path: AppRoutes.adminUsers, name: 'adminUsers', builder: (_, __) => const UsersListScreen()),
      GoRoute(path: AppRoutes.adminCreateCourse, name: 'adminCreateCourse', builder: (_, __) => const CreateCourseScreen()),
      GoRoute(path: AppRoutes.adminAnnouncements, name: 'adminAnnouncements', builder: (_, __) => const AnnouncementsScreen()),
      GoRoute(path: AppRoutes.adminReports, name: 'adminReports', builder: (_, __) => const ReportsScreen()),
      GoRoute(path: AppRoutes.adminSubscriptions, name: 'adminSubscriptions', builder: (_, __) => const admin_subs.SubscriptionsScreen()),
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
      return AppRoutes.home;
  }
}

Future<bool> hasValidToken() {
  return TokenStorage().hasToken();
}
