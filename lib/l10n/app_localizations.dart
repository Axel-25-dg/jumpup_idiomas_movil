import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue your journey'**
  String get welcomeSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @registerHere.
  ///
  /// In en, this message translates to:
  /// **'Register here'**
  String get registerHere;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @joinToday.
  ///
  /// In en, this message translates to:
  /// **'Join today'**
  String get joinToday;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account and take your languages to the next level.'**
  String get createAccountSubtitle;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginLink;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Improves reading at night'**
  String get darkModeSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Class and challenge reminders'**
  String get notificationsSubtitle;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics (Vibration)'**
  String get haptics;

  /// No description provided for @hapticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tactile feedback when interacting'**
  String get hapticsSubtitle;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @learningLanguages.
  ///
  /// In en, this message translates to:
  /// **'Learning Languages'**
  String get learningLanguages;

  /// No description provided for @manageCourses.
  ///
  /// In en, this message translates to:
  /// **'Manage your active courses'**
  String get manageCourses;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @securitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change password and privacy'**
  String get securitySubtitle;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get support;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @bug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get bug;

  /// No description provided for @feature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get feature;

  /// No description provided for @improvement.
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get improvement;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your suggestion...'**
  String get feedbackHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'SEND'**
  String get send;

  /// No description provided for @feedbackSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get feedbackSuccess;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a recovery code.'**
  String get forgotPasswordInstructions;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmail;

  /// No description provided for @verifyEmailInstructions.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a code to {email}. Enter it along with your new password.'**
  String verifyEmailInstructions(String email);

  /// No description provided for @sixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get sixDigitCode;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @allDone.
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get allDone;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully updated.'**
  String get passwordUpdated;

  /// No description provided for @backToStart.
  ///
  /// In en, this message translates to:
  /// **'Back to Start'**
  String get backToStart;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'UPDATE PASSWORD'**
  String get updatePassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordLengthError;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @passwordUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdateSuccess;

  /// No description provided for @passwordUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error changing password. Check your current password.'**
  String get passwordUpdateError;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get noName;

  /// No description provided for @noLastName.
  ///
  /// In en, this message translates to:
  /// **'No last name'**
  String get noLastName;

  /// No description provided for @noUsername.
  ///
  /// In en, this message translates to:
  /// **'No username'**
  String get noUsername;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated'**
  String get profilePictureUpdated;

  /// No description provided for @profilePictureError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload picture.'**
  String get profilePictureError;

  /// No description provided for @logoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Back to start screen'**
  String get logoutSubtitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @classrooms.
  ///
  /// In en, this message translates to:
  /// **'Classrooms'**
  String get classrooms;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name} 👋'**
  String hello(String name);

  /// No description provided for @readyToLearn.
  ///
  /// In en, this message translates to:
  /// **'Ready to learn?'**
  String get readyToLearn;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @virtualClasses.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get virtualClasses;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @ranking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get ranking;

  /// No description provided for @recentProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Recent Progress'**
  String get recentProgress;

  /// No description provided for @viewVirtualClasses.
  ///
  /// In en, this message translates to:
  /// **'Virtual Classes ➔'**
  String get viewVirtualClasses;

  /// No description provided for @exploreCourses.
  ///
  /// In en, this message translates to:
  /// **'Explore courses in the Store'**
  String get exploreCourses;

  /// No description provided for @continueLesson.
  ///
  /// In en, this message translates to:
  /// **'Continue Lesson'**
  String get continueLesson;

  /// No description provided for @lessonsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Lessons'**
  String lessonsCount(int count);

  /// No description provided for @aiTutorTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor'**
  String get aiTutorTitle;

  /// No description provided for @aiTutorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Practice grammar or conversation with our advanced AI'**
  String get aiTutorSubtitle;

  /// No description provided for @startSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Start speaking'**
  String get startSpeaking;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} Days'**
  String streakDays(int days);

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @xpAmount.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String xpAmount(int xp);

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// No description provided for @levelProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level} Progress'**
  String levelProgressLabel(int level);

  /// No description provided for @exploreCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Courses'**
  String get exploreCoursesTitle;

  /// No description provided for @whatDoYouWantToLearn.
  ///
  /// In en, this message translates to:
  /// **'What do you want to learn?'**
  String get whatDoYouWantToLearn;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @modulesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Modules'**
  String modulesCount(int count);

  /// No description provided for @advancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get advancedFilters;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @noCoursesFound.
  ///
  /// In en, this message translates to:
  /// **'No courses found'**
  String get noCoursesFound;

  /// No description provided for @tryOtherFilters.
  ///
  /// In en, this message translates to:
  /// **'Try with other filters or search terms'**
  String get tryOtherFilters;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loadingLanguagesError.
  ///
  /// In en, this message translates to:
  /// **'Error loading languages'**
  String get loadingLanguagesError;

  /// No description provided for @adminStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get adminStats;

  /// No description provided for @adminPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get adminPeople;

  /// No description provided for @adminContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get adminContent;

  /// No description provided for @adminOps.
  ///
  /// In en, this message translates to:
  /// **'Ops'**
  String get adminOps;

  /// No description provided for @platformOverview.
  ///
  /// In en, this message translates to:
  /// **'Platform Overview'**
  String get platformOverview;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @studentCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get studentCourses;

  /// No description provided for @adminSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get adminSubscriptions;

  /// No description provided for @studentCertificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get studentCertificates;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @systemAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'System Announcements'**
  String get systemAnnouncements;

  /// No description provided for @manageAnnouncementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage global platform updates'**
  String get manageAnnouncementsSubtitle;

  /// No description provided for @peopleManagement.
  ///
  /// In en, this message translates to:
  /// **'People Management'**
  String get peopleManagement;

  /// No description provided for @usersAndRoles.
  ///
  /// In en, this message translates to:
  /// **'Users & Roles'**
  String get usersAndRoles;

  /// No description provided for @manageUsersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage all student and teacher accounts'**
  String get manageUsersSubtitle;

  /// No description provided for @monitorClassroomsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor active groups and assignments'**
  String get monitorClassroomsSubtitle;

  /// No description provided for @languageExperts.
  ///
  /// In en, this message translates to:
  /// **'Language Experts'**
  String get languageExperts;

  /// No description provided for @manageLanguagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage platform language assets'**
  String get manageLanguagesSubtitle;

  /// No description provided for @contentAndCurriculum.
  ///
  /// In en, this message translates to:
  /// **'Content & Curriculum'**
  String get contentAndCurriculum;

  /// No description provided for @courseCatalog.
  ///
  /// In en, this message translates to:
  /// **'Course Catalog'**
  String get courseCatalog;

  /// No description provided for @editCoursesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit syllabus, lessons and modules'**
  String get editCoursesSubtitle;

  /// No description provided for @exerciseBank.
  ///
  /// In en, this message translates to:
  /// **'Exercise Bank'**
  String get exerciseBank;

  /// No description provided for @manageExercisesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review and update practice materials'**
  String get manageExercisesSubtitle;

  /// No description provided for @operationsAndBilling.
  ///
  /// In en, this message translates to:
  /// **'Operations & Billing'**
  String get operationsAndBilling;

  /// No description provided for @billingAndSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions & Billing'**
  String get billingAndSubscriptions;

  /// No description provided for @monitorRevenueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor revenue and premium plans'**
  String get monitorRevenueSubtitle;

  /// No description provided for @contentReports.
  ///
  /// In en, this message translates to:
  /// **'Content Reports'**
  String get contentReports;

  /// No description provided for @moderateReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Moderate forum and social reports'**
  String get moderateReportsSubtitle;

  /// No description provided for @adminProfile.
  ///
  /// In en, this message translates to:
  /// **'Admin Profile'**
  String get adminProfile;

  /// No description provided for @administrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administrator;

  /// No description provided for @superAdminAccess.
  ///
  /// In en, this message translates to:
  /// **'Super Admin Access'**
  String get superAdminAccess;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// No description provided for @logoutAdminConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the admin panel?'**
  String get logoutAdminConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
