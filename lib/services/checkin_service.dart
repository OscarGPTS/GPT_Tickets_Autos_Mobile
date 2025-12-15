import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'log_service.dart';

/// Servicio dedicado para operaciones de checkin (entrada de vehículos)
class CheckinService {
  // Singleton pattern
  static final CheckinService _instance = CheckinService._internal();
  factory CheckinService() => _instance;
  CheckinService._internal();

  final LogService _logService = LogService();

  /// Enviar checklist de entrada (checkin) al backend
  /// 
  /// [ticketId] - ID del ticket asociado
  /// [checklistData] - Datos completos del checklist en formato Map
  /// 
  /// Retorna un ApiResponse con el resultado de la operación
  Future<ApiResponse<ChecklistSubmitResponse>> submitCheckin({
    required int ticketId,
    required Map<String, dynamic> checklistData,
  }) async {
    try {
      // Preparar payload
      final payload = {
        'ticket_id': ticketId,
        ...checklistData,
      };

      await _logService.info('Enviando checkin para ticket: $ticketId');

      // Realizar petición POST
      final response = await http
          .post(
            Uri.parse(ApiConfig.checkinUrl),
            headers: ApiConfig.headers,
            body: jsonEncode(payload),
          )
          .timeout(ApiConfig.connectTimeout);

      final Map<String, dynamic> body = jsonDecode(response.body);

      // Procesar respuesta exitosa
      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        final submitResponse = ChecklistSubmitResponse.fromJson(data);

        await _logService.info('Checkin guardado exitosamente para ticket: $ticketId');

        return ApiResponse.success(
          data: submitResponse,
          message: body['message'] as String? ?? 'Checkin guardado correctamente',
        );
      } else {
        // Procesar respuesta de error
        await _logService.apiError(
          message: body['message'] as String? ?? 'Error al guardar checkin',
          endpoint: ApiConfig.checkinUrl,
          statusCode: response.statusCode,
          data: {
            'ticket_id': ticketId,
            'errors': body['errors'],
          },
        );

        return ApiResponse.error(
          message: body['message'] as String? ?? 'Error al guardar checkin',
          statusCode: response.statusCode,
          errors: body['errors'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      await _logService.apiError(
        message: 'Error de conexión al enviar checkin: ${e.toString()}',
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

  /// Obtener checklist de checkin existente
  /// 
  /// [ticketId] - ID del ticket
  /// 
  /// Retorna el checklist si existe, null si no
  Future<ApiResponse<Map<String, dynamic>?>> getCheckin({
    required int ticketId,
  }) async {
    try {
      final url = '${ApiConfig.checkinUrl}/$ticketId';
      
      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.connectTimeout);

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return ApiResponse.success(
          data: body['data'] as Map<String, dynamic>?,
          message: 'Checkin obtenido correctamente',
        );
      } else {
        return ApiResponse.error(
          message: body['message'] as String? ?? 'Error al obtener checkin',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Validar que un checkin puede ser realizado
  /// 
  /// [ticketId] - ID del ticket a validar
  /// 
  /// Verifica que:
  /// - El ticket existe
  /// - Tiene un checkout previo
  /// - No tiene ya un checkin completado
  Future<ApiResponse<bool>> validateCheckin({
    required int ticketId,
  }) async {
    try {
      final url = '${ApiConfig.checkinUrl}/validate/$ticketId';
      
      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.connectTimeout);

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return ApiResponse.success(
          data: body['data']['can_checkin'] as bool? ?? false,
          message: body['message'] as String? ?? 'Validación exitosa',
        );
      } else {
        return ApiResponse.error(
          message: body['message'] as String? ?? 'Error en validación',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
}
