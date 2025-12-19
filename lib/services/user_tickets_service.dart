import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/ticket_model.dart';

class PaginationInfo {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int? from;
  final int? to;
  final bool hasMorePages;

  PaginationInfo({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.from,
    this.to,
    required this.hasMorePages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 10,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      from: json['from'],
      to: json['to'],
      hasMorePages: json['has_more_pages'] ?? false,
    );
  }
}

class UserTicketsResponse {
  final bool success;
  final String message;
  final List<TicketModel> tickets;
  final PaginationInfo pagination;

  UserTicketsResponse({
    required this.success,
    required this.message,
    required this.tickets,
    required this.pagination,
  });

  factory UserTicketsResponse.fromJson(Map<String, dynamic> json) {
    return UserTicketsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      tickets: (json['data']?['tickets'] as List?)
              ?.map((ticket) => TicketModel.fromJson(ticket))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(json['data']?['pagination'] ?? {}),
    );
  }
}

class UserTicketsService {
  // Singleton pattern
  static final UserTicketsService _instance = UserTicketsService._internal();
  factory UserTicketsService() => _instance;
  UserTicketsService._internal();

  /// Obtener todos los tickets del usuario con paginación
  Future<UserTicketsResponse> getMyTickets({
    required String email,
    int page = 1,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.userTicketsUrl),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'email': email,
              'page': page,
            }),
          )
          .timeout(ApiConfig.connectTimeout);

      print('=== USER TICKETS RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('=============================');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return UserTicketsResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Error al obtener tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getMyTickets: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
