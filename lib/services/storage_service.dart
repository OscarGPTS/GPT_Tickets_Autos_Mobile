import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/ticket_model.dart';

/// Servicio para gestionar el almacenamiento local
class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Keys para SharedPreferences
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUser = 'user_data';
  static const String _keyTickets = 'tickets_data';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';

  /// Guardar sesión del usuario
  Future<void> saveSession({
    required UserModel user,
    required List<TicketModel> tickets,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    await prefs.setString(
      _keyTickets,
      jsonEncode(tickets.map((t) => t.toJson()).toList()),
    );
    // Guardar credenciales para re-sincronización
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setString(_keyUserName, user.name);
  }

  /// Verificar si hay sesión activa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Obtener usuario guardado
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);

    if (userJson == null) return null;

    try {
      final Map<String, dynamic> userData = jsonDecode(userJson);
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Obtener tickets guardados
  Future<List<TicketModel>> getTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final ticketsJson = prefs.getString(_keyTickets);

    if (ticketsJson == null) return [];

    try {
      final List<dynamic> ticketsData = jsonDecode(ticketsJson);
      return ticketsData
          .map((ticket) => TicketModel.fromJson(ticket as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Actualizar lista de tickets
  Future<void> updateTickets(List<TicketModel> tickets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyTickets,
      jsonEncode(tickets.map((t) => t.toJson()).toList()),
    );
  }

  /// Actualizar un ticket específico
  Future<void> updateTicket(TicketModel updatedTicket) async {
    final tickets = await getTickets();
    final index = tickets.indexWhere((t) => t.id == updatedTicket.id);

    if (index != -1) {
      tickets[index] = updatedTicket;
      await updateTickets(tickets);
    }
  }

  /// Obtener email guardado
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  /// Obtener nombre guardado
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// Guardar credenciales de Google
  Future<void> saveGoogleCredentials({
    required String email,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserName, name);
  }

  /// Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUser);
    await prefs.remove(_keyTickets);
    // Mantener credenciales para re-login automático
    // await prefs.remove(_keyUserEmail);
    // await prefs.remove(_keyUserName);
  }

  /// Limpiar todo el almacenamiento
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
