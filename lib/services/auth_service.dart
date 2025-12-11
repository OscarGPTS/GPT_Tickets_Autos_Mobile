import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Configura este clientId si usas iOS/web; en Android se toma del archivo google-services.
  // Para este ejemplo móvil Android, el clientId se resuelve por el paquete y SHA.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
      'openid',
    ],
  );

  Future<GoogleSignInAccount?> signIn() async {
    try {
      // Intenta silent sign-in primero
      final currentUser = await _googleSignIn.signInSilently();
      if (currentUser != null) return currentUser;

      return await _googleSignIn.signIn();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // Si disconnect falla, intenta signOut estándar
      await _googleSignIn.signOut();
    }
  }

  Future<bool> isSignedIn() async {
    final user = await _googleSignIn.signInSilently();
    return user != null;
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> getUser() async {
    final user = _googleSignIn.currentUser;
    if (user != null) return user;
    return _googleSignIn.signInSilently();
  }
}
