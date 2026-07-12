// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'Login';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeSubtitle => 'Log in to continue your journey';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get loginButton => 'Log In';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get registerHere => 'Register here';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get joinToday => 'Join today';

  @override
  String get createAccountSubtitle =>
      'Create your account and take your languages to the next level.';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get username => 'Username';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get registerButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get loginLink => 'Log in';

  @override
  String get settings => 'Settings';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Improves reading at night';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Class and challenge reminders';

  @override
  String get haptics => 'Haptics (Vibration)';

  @override
  String get hapticsSubtitle => 'Tactile feedback when interacting';

  @override
  String get appLanguage => 'App Language';

  @override
  String get account => 'ACCOUNT';

  @override
  String get learningLanguages => 'Learning Languages';

  @override
  String get manageCourses => 'Manage your active courses';

  @override
  String get security => 'Security';

  @override
  String get securitySubtitle => 'Change password and privacy';

  @override
  String get support => 'SUPPORT';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get category => 'Category';

  @override
  String get bug => 'Bug';

  @override
  String get feature => 'Feature';

  @override
  String get improvement => 'Improvement';

  @override
  String get other => 'Other';

  @override
  String get feedbackHint => 'Describe your suggestion...';

  @override
  String get send => 'SEND';

  @override
  String get feedbackSuccess => 'Thank you for your feedback!';

  @override
  String get forgotPasswordTitle => 'Forgot your password?';

  @override
  String get forgotPasswordInstructions =>
      'Enter your email to receive a recovery code.';

  @override
  String get sendCode => 'Send Code';

  @override
  String get verifyEmail => 'Verify your email';

  @override
  String verifyEmailInstructions(String email) {
    return 'We\'ve sent a code to $email. Enter it along with your new password.';
  }

  @override
  String get sixDigitCode => '6-digit code';

  @override
  String get newPassword => 'New password';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get allDone => 'All done!';

  @override
  String get passwordUpdated => 'Your password has been successfully updated.';

  @override
  String get backToStart => 'Back to Start';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get updatePassword => 'UPDATE PASSWORD';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordLengthError => 'Password must be at least 8 characters';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get passwordUpdateSuccess => 'Password updated successfully';

  @override
  String get passwordUpdateError =>
      'Error changing password. Check your current password.';

  @override
  String get user => 'User';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get save => 'Save';

  @override
  String get share => 'Share';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get noName => 'No name';

  @override
  String get noLastName => 'No last name';

  @override
  String get noUsername => 'No username';

  @override
  String get noEmail => 'No email';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get profilePictureUpdated => 'Profile picture updated';

  @override
  String get profilePictureError => 'Could not upload picture.';

  @override
  String get logoutSubtitle => 'Back to start screen';

  @override
  String get home => 'Home';

  @override
  String get classrooms => 'Classrooms';

  @override
  String get social => 'Social';

  @override
  String get progress => 'Progress';

  @override
  String hello(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String get readyToLearn => 'Ready to learn?';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get virtualClasses => 'Classes';

  @override
  String get store => 'Store';

  @override
  String get games => 'Games';

  @override
  String get ranking => 'Ranking';

  @override
  String get recentProgress => 'Your Recent Progress';

  @override
  String get viewVirtualClasses => 'Virtual Classes ➔';

  @override
  String get exploreCourses => 'Explore courses in the Store';

  @override
  String get continueLesson => 'Continue Lesson';

  @override
  String lessonsCount(int count) {
    return '$count Lessons';
  }

  @override
  String get aiTutorTitle => 'AI Tutor';

  @override
  String get aiTutorSubtitle =>
      'Practice grammar or conversation with our advanced AI';

  @override
  String get startSpeaking => 'Start speaking';

  @override
  String streakDays(int days) {
    return '$days Days';
  }

  @override
  String get currentStreak => 'Current Streak';

  @override
  String xpAmount(int xp) {
    return '$xp XP';
  }

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String levelProgressLabel(int level) {
    return 'Level $level Progress';
  }

  @override
  String get exploreCoursesTitle => 'Explore Courses';

  @override
  String get whatDoYouWantToLearn => 'What do you want to learn?';

  @override
  String get all => 'All';

  @override
  String modulesCount(int count) {
    return '$count Modules';
  }

  @override
  String get advancedFilters => 'Advanced Filters';

  @override
  String get language => 'Language';

  @override
  String get clearAll => 'Clear All';

  @override
  String get apply => 'Apply';

  @override
  String get noCoursesFound => 'No courses found';

  @override
  String get tryOtherFilters => 'Try with other filters or search terms';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get loadingLanguagesError => 'Error loading languages';

  @override
  String get adminStats => 'Stats';

  @override
  String get adminPeople => 'People';

  @override
  String get adminContent => 'Content';

  @override
  String get adminOps => 'Ops';

  @override
  String get platformOverview => 'Platform Overview';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get studentCourses => 'Courses';

  @override
  String get adminSubscriptions => 'Subscriptions';

  @override
  String get studentCertificates => 'Certificates';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get systemAnnouncements => 'System Announcements';

  @override
  String get manageAnnouncementsSubtitle => 'Manage global platform updates';

  @override
  String get peopleManagement => 'People Management';

  @override
  String get usersAndRoles => 'Users & Roles';

  @override
  String get manageUsersSubtitle => 'Manage all student and teacher accounts';

  @override
  String get monitorClassroomsSubtitle =>
      'Monitor active groups and assignments';

  @override
  String get languageExperts => 'Language Experts';

  @override
  String get manageLanguagesSubtitle => 'Manage platform language assets';

  @override
  String get contentAndCurriculum => 'Content & Curriculum';

  @override
  String get courseCatalog => 'Course Catalog';

  @override
  String get editCoursesSubtitle => 'Edit syllabus, lessons and modules';

  @override
  String get exerciseBank => 'Exercise Bank';

  @override
  String get manageExercisesSubtitle => 'Review and update practice materials';

  @override
  String get operationsAndBilling => 'Operations & Billing';

  @override
  String get billingAndSubscriptions => 'Subscriptions & Billing';

  @override
  String get monitorRevenueSubtitle => 'Monitor revenue and premium plans';

  @override
  String get contentReports => 'Content Reports';

  @override
  String get moderateReportsSubtitle => 'Moderate forum and social reports';

  @override
  String get adminProfile => 'Admin Profile';

  @override
  String get administrator => 'Administrator';

  @override
  String get superAdminAccess => 'Super Admin Access';

  @override
  String get securitySettings => 'Security Settings';

  @override
  String get logoutAdminConfirm =>
      'Are you sure you want to exit the admin panel?';
}
