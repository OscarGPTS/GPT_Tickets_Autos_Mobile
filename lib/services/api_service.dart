import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/ticket_model.dart';
import 'log_service.dart';

/// Clase para gestionar todas las llamadas a la API
class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final LogService _logService = LogService();

  /// Login de despachador
  /// Retorna el usuario autenticado y sus tickets asignados
  Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String name,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'email': email,
              'name': name,
            }),
          )
          .timeout(ApiConfig.connectTimeout);

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(data);

        await _logService.info('Login exitoso para: $email');

        return ApiResponse.success(
          data: loginResponse,
          message: body['message'] as String? ?? 'Login exitoso',
        );
      } else {
        await _logService.apiError(
          message: body['message'] as String? ?? 'Error en el login',
          endpoint: ApiConfig.loginUrl,
          statusCode: response.statusCode,
          data: {'email': email, 'name': name},
        );

        return ApiResponse.error(
          message: body['message'] as String? ?? 'Error en el login',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      await _logService.apiError(
        message: 'Error de conexión: ${e.toString()}',
        endpoint: ApiConfig.loginUrl,
        statusCode: 0,
        data: {'email': email, 'name': name, 'error': e.toString()},
      );

      return ApiResponse.error(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Crear o actualizar checklist de salida (checkout)
  Future<ApiResponse<ChecklistSubmitResponse>> submitCheckout({
    required int ticketId,
    required Map<String, dynamic> checklistData,
  }) async {
    try {
      // Agregar ticket_id al payload
      final payload = {
        'ticket_id': ticketId,
        ...checklistData,
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.checkoutUrl),
            headers: ApiConfig.headers,
            body: jsonEncode(payload),
          )
          .timeout(ApiConfig.connectTimeout);

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        final submitResponse = ChecklistSubmitResponse.fromJson(data);

        return ApiResponse.success(
          data: submitResponse,
          message: body['message'] as String? ?? 'Checklist guardado',
        );
      } else {
        return ApiResponse.error(
          message: body['message'] as String? ?? 'Error al guardar checklist',
          statusCode: response.statusCode,
          errors: body['errors'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Crear o actualizar checklist de entrada (checkin)
  Future<ApiResponse<ChecklistSubmitResponse>> submitCheckin({
    required int ticketId,
    required Map<String, dynamic> checklistData,
  }) async {
    try {
      final payload = {
        'ticket_id': ticketId,
        ...checklistData,
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.checkinUrl),
            headers: ApiConfig.headers,
            body: jsonEncode(payload),
          )
          .timeout(ApiConfig.connectTimeout);

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        final submitResponse = ChecklistSubmitResponse.fromJson(data);

        await _logService.info('Checkin guardado para ticket: $ticketId');

        return ApiResponse.success(
          data: submitResponse,
          message: body['message'] as String? ?? 'Checklist guardado',
        );
      } else {
        await _logService.apiError(
          message: body['message'] as String? ?? 'Error al guardar checkin',
          endpoint: ApiConfig.checkinUrl,
          statusCode: response.statusCode,
          data: {
            'ticket_id': ticketId,
            'errors': body['errors'],
            'response': body,
          },
        );

        return ApiResponse.error(
          message: body['message'] as String? ?? 'Error al guardar checklist',
          statusCode: response.statusCode,
          errors: body['errors'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      await _logService.apiError(
        message: 'Error de conexión: ${e.toString()}',
        endpoint: ApiConfig.checkinUrl,
        statusCode: 0,
        data: {'ticket_id': ticketId, 'error': e.toString()},
      );

      return ApiResponse.error(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Obtener detalle de un ticket específico
  Future<ApiResponse<TicketModel>> getTicketDetail(int ticketId) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.ticketUrl(ticketId)),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.connectTimeout);

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final ticketData = body['data'] as Map<String, dynamic>;
        final ticket = TicketModel.fromJson(ticketData);

        await _logService.info('Ticket obtenido: $ticketId');

        return ApiResponse.success(
          data: ticket,
          message: 'Ticket obtenido correctamente',
        );
      } else {
        await _logService.apiError(
          message: body['message'] as String? ?? 'Error al obtener ticket',
          endpoint: ApiConfig.ticketUrl(ticketId),
          statusCode: response.statusCode,
          data: {'ticket_id': ticketId},
        );

        return ApiResponse.error(
          message: body['message'] as String? ?? 'Error al obtener ticket',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      await _logService.apiError(
        message: 'Error de conexión: ${e.toString()}',
        endpoint: ApiConfig.ticketUrl(ticketId),
        statusCode: 0,
        data: {'ticket_id': ticketId, 'error': e.toString()},
      );

      return ApiResponse.error(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
}

/// Respuesta genérica de la API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.success({
    required T data,
    required String message,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: 200,
    );
  }

  factory ApiResponse.error({
    required String message,
    required int statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}

/// Respuesta del endpoint de login
class LoginResponse {
  final UserModel user;
  final List<TicketModel> tickets;

  LoginResponse({
    required this.user,
    required this.tickets,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      tickets: (json['tickets'] as List<dynamic>)
          .map((ticket) => TicketModel.fromJson(ticket as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tickets': tickets.map((t) => t.toJson()).toList(),
    };
  }
}

/// Respuesta al enviar un checklist
class ChecklistSubmitResponse {
  final Map<String, dynamic> checklist;
  final TicketModel ticket;

  ChecklistSubmitResponse({
    required this.checklist,
    required this.ticket,
  });

  factory ChecklistSubmitResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistSubmitResponse(
      checklist: json['checklist'] as Map<String, dynamic>,
      ticket: TicketModel.fromJson(json['ticket'] as Map<String, dynamic>),
    );
  }
}
