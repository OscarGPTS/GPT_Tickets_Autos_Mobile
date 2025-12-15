import '../models/ticket_model.dart';
import '../models/user_model.dart';

/// Clase genérica para manejar respuestas de la API
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

/// Respuesta al enviar un checklist (checkout o checkin)
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
