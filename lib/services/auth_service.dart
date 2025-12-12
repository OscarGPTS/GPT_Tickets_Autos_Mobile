import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../models/user_model.dart';
import '../models/ticket_model.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
      'openid',
    ],
  );

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  /// Login solo con Google (sin validar API todavía)
  Future<GoogleSignInAccount?> signIn() async {
    try {
      // Intenta silent sign-in primero
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser != null) {
        // Guardar credenciales para uso futuro
        await _storageService.saveGoogleCredentials(
          email: googleUser.email,
          name: googleUser.displayName ?? '',
        );
        return googleUser;
      }

      // Si no hay sesión silenciosa, muestra el diálogo
      googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        // Guardar credenciales para uso futuro
        await _storageService.saveGoogleCredentials(
          email: googleUser.email,
          name: googleUser.displayName ?? '',
        );
      }
      return googleUser;
    } catch (e) {
      rethrow;
    }
  }

  /// Sincronizar con el backend después del login
  /// Este método se llama una vez que el usuario ya está dentro de la app
  /// Si se pasan email y name, los usa; si no, intenta obtenerlos de Google o del storage
  Future<AuthResult> syncWithBackend({
    String? email,
    String? name,
  }) async {
    try {
      String? userEmail = email;
      String? userName = name;

      // Si no se pasaron credenciales, intentar obtenerlas
      if (userEmail == null || userName == null) {
        // Primero intentar de Google
        final googleUser = _googleSignIn.currentUser;
        if (googleUser != null) {
          userEmail = googleUser.email;
          userName = googleUser.displayName ?? '';
        } else {
          // Si no hay Google, intentar del storage
          userEmail = await _storageService.getUserEmail();
          userName = await _storageService.getUserName();
        }
      }
      
      if (userEmail == null || userName == null) {
        return AuthResult(
          success: false,
          message: 'No hay credenciales disponibles para sincronizar',
        );
      }

      // Llamar a la API del backend para obtener tickets
      final response = await _apiService.login(
        email: userEmail,
        name: userName,
      );

      if (response.success && response.data != null) {
        // Guardar datos del backend en storage local
        await _storageService.saveSession(
          user: response.data!.user,
          tickets: response.data!.tickets,
        );

        return AuthResult(
          success: true,
          message: response.message,
          user: response.data!.user,
          tickets: response.data!.tickets,
        );
      } else {
        return AuthResult(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Error al sincronizar: ${e.toString()}',
      );
    }
  }

  /// Cerrar sesión completa (Google + Storage)
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      await _googleSignIn.signOut();
    }
    await _storageService.logout();
  }

  /// Verificar si hay sesión activa (verifica Storage, no Google)
  Future<bool> isSignedIn() async {
    return await _storageService.isLoggedIn();
  }

  /// Obtener usuario almacenado
  Future<UserModel?> getCurrentUser() async {
    return await _storageService.getUser();
  }

  /// Obtener tickets almacenados
  Future<List<TicketModel>> getTickets() async {
    return await _storageService.getTickets();
  }

  /// Actualizar tickets en storage
  Future<void> updateTickets(List<TicketModel> tickets) async {
    await _storageService.updateTickets(tickets);
  }

  /// Actualizar un ticket específico
  Future<void> updateTicket(TicketModel ticket) async {
    await _storageService.updateTicket(ticket);
  }

  // Mantener compatibilidad con código antiguo
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> getUser() async {
    final user = _googleSignIn.currentUser;
    if (user != null) return user;
    return _googleSignIn.signInSilently();
  }
}

/// Resultado del proceso de autenticación
class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;
  final List<TicketModel>? tickets;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.tickets,
  });
}
