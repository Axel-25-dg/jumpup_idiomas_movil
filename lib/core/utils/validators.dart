abstract final class Validators {
  // ── Email ──────────────────────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu correo electrónico';
    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Correo electrónico inválido';
    return null;
  }

  // ── Contraseña ─────────────────────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  // ── Campo requerido genérico ───────────────────────────────────────────────
  static String? required(String? value, {String label = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$label es requerido';
    return null;
  }

  // ── Usuario ────────────────────────────────────────────────────────────────
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa un nombre de usuario';
    }
    if (value.trim().length < 3) return 'Mínimo 3 caracteres';
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_\.]+$');
    if (!usernameRegex.hasMatch(value.trim())) {
      return 'Solo letras, números, _ y .';
    }
    return null;
  }

  // ── Confirmar contraseña ───────────────────────────────────────────────────
  static String? Function(String?) confirmPassword(String original) {
    return (String? value) {
      if (value == null || value.isEmpty) return 'Confirma tu contraseña';
      if (value != original) return 'Las contraseñas no coinciden';
      return null;
    };
  }

  // ── Nombre / apellido ──────────────────────────────────────────────────────
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es requerido';
    if (value.trim().length < 2) return 'Mínimo 2 caracteres';
    return null;
  }
}
