// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get welcomeSubtitle => 'Inicia sesión para continuar tu viaje';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get noAccount => '¿No tienes cuenta? ';

  @override
  String get registerHere => 'Regístrate aquí';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get logoutConfirmation => '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get joinToday => 'Únete hoy';

  @override
  String get createAccountSubtitle =>
      'Crea tu cuenta y lleva tus idiomas al siguiente nivel.';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellido';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get registerButton => 'Crear Cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get loginLink => 'Inicia sesión';

  @override
  String get settings => 'Configuración';

  @override
  String get preferences => 'PREFERENCIAS';

  @override
  String get darkMode => 'Tema Oscuro';

  @override
  String get darkModeSubtitle => 'Mejora la lectura en la noche';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationsSubtitle => 'Recordatorios de clases y retos';

  @override
  String get haptics => 'Haptics (Vibración)';

  @override
  String get hapticsSubtitle => 'Feedback táctil al interactuar';

  @override
  String get appLanguage => 'Idioma de la App';

  @override
  String get account => 'CUENTA';

  @override
  String get learningLanguages => 'Idiomas de aprendizaje';

  @override
  String get manageCourses => 'Gestiona tus cursos activos';

  @override
  String get security => 'Seguridad';

  @override
  String get securitySubtitle => 'Cambiar contraseña y privacidad';

  @override
  String get support => 'SOPORTE';

  @override
  String get sendFeedback => 'Enviar sugerencia';

  @override
  String get helpCenter => 'Centro de Ayuda';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get category => 'Categoría';

  @override
  String get bug => 'Error';

  @override
  String get feature => 'Nueva función';

  @override
  String get improvement => 'Mejora';

  @override
  String get other => 'Otro';

  @override
  String get feedbackHint => 'Describe tu sugerencia...';

  @override
  String get send => 'ENVIAR';

  @override
  String get feedbackSuccess => '¡Gracias por tu sugerencia!';

  @override
  String get forgotPasswordTitle => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordInstructions =>
      'Ingresa tu correo electrónico para recibir un código de recuperación.';

  @override
  String get sendCode => 'Enviar Código';

  @override
  String get verifyEmail => 'Verifica tu correo';

  @override
  String verifyEmailInstructions(String email) {
    return 'Hemos enviado un código a $email. Ingrésalo junto con tu nueva contraseña.';
  }

  @override
  String get sixDigitCode => 'Código de 6 dígitos';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get resetPassword => 'Restablecer Contraseña';

  @override
  String get allDone => '¡Todo listo!';

  @override
  String get passwordUpdated =>
      'Tu contraseña ha sido actualizada exitosamente.';

  @override
  String get backToStart => 'Volver al Inicio';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get currentPassword => 'Contraseña Actual';

  @override
  String get updatePassword => 'ACTUALIZAR CONTRASEÑA';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordLengthError =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get fillAllFields => 'Por favor completa todos los campos';

  @override
  String get passwordUpdateSuccess => 'Contraseña actualizada con éxito';

  @override
  String get passwordUpdateError =>
      'Error al cambiar contraseña. Verifica tu contraseña actual.';

  @override
  String get user => 'Usuario';

  @override
  String get profile => 'Perfil';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get save => 'Guardar';

  @override
  String get share => 'Compartir';

  @override
  String get personalInformation => 'Información Personal';

  @override
  String get noName => 'Sin nombre';

  @override
  String get noLastName => 'Sin apellido';

  @override
  String get noUsername => 'Sin usuario';

  @override
  String get noEmail => 'Sin correo';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get profilePictureUpdated => 'Foto de perfil actualizada';

  @override
  String get profilePictureError => 'No se pudo subir la foto.';

  @override
  String get logoutSubtitle => 'Volver a la pantalla de inicio';

  @override
  String get home => 'Inicio';

  @override
  String get classrooms => 'Aulas';

  @override
  String get social => 'Social';

  @override
  String get progress => 'Progreso';

  @override
  String hello(String name) {
    return 'Hola, $name 👋';
  }

  @override
  String get readyToLearn => '¿Listo para aprender?';

  @override
  String get quickActions => 'Acciones Rápidas';

  @override
  String get virtualClasses => 'Clases V.';

  @override
  String get store => 'Tienda';

  @override
  String get games => 'Juegos';

  @override
  String get ranking => 'Ranking';

  @override
  String get recentProgress => 'Tu Progreso Reciente';

  @override
  String get viewVirtualClasses => 'Clases Virtuales ➔';

  @override
  String get exploreCourses => 'Explora cursos en la Tienda';

  @override
  String get continueLesson => 'Continuar Lección';

  @override
  String lessonsCount(int count) {
    return '$count Lecciones';
  }

  @override
  String get aiTutorTitle => 'Tutor Inteligente';

  @override
  String get aiTutorSubtitle =>
      'Practica gramática o conversación con nuestra IA avanzada';

  @override
  String get startSpeaking => 'Empezar a hablar';

  @override
  String streakDays(int days) {
    return '$days Días';
  }

  @override
  String get currentStreak => 'Racha Actual';

  @override
  String xpAmount(int xp) {
    return '$xp XP';
  }

  @override
  String levelLabel(int level) {
    return 'Nivel $level';
  }

  @override
  String levelProgressLabel(int level) {
    return 'Progreso Nivel $level';
  }

  @override
  String get exploreCoursesTitle => 'Explorar Cursos';

  @override
  String get whatDoYouWantToLearn => '¿Qué quieres aprender?';

  @override
  String get all => 'Todos';

  @override
  String modulesCount(int count) {
    return '$count Módulos';
  }

  @override
  String get advancedFilters => 'Filtros Avanzados';

  @override
  String get language => 'Idioma';

  @override
  String get clearAll => 'Limpiar Todo';

  @override
  String get apply => 'Aplicar';

  @override
  String get noCoursesFound => 'No encontramos cursos';

  @override
  String get tryOtherFilters =>
      'Intenta con otros filtros o términos de búsqueda';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get retry => 'Reintentar';

  @override
  String get loadingLanguagesError => 'Error al cargar idiomas';
}
