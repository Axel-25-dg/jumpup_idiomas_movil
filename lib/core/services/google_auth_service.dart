import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._();
  static GoogleAuthService get instance => _instance;
  GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Inicia el flujo de inicio de sesión con Google.
  /// Retorna el token de ID si fue exitoso, o null si el usuario cancela.
  Future<String?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;
      final auth = await account.authentication;
      return auth.idToken;
    } catch (_) {
      return null;
    }
  }

  /// Cierra la sesión de Google.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  /// Verifica si hay un usuario firmado con Google.
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}
