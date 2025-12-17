import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'log_service.dart';

/// Servicio dedicado para operaciones de checkout (salida de vehículos)
class CheckoutService {
  // Singleton pattern
  static final CheckoutService _instance = CheckoutService._internal();
  factory CheckoutService() => _instance;
  CheckoutService._internal();

  final LogService _logService = LogService();

  /// Enviar checklist de salida (checkout) al backend
  /// 
  /// [ticketId] - ID del ticket asociado
  /// [checklistData] - Datos completos del checklist en formato Map
  /// 
  /// Retorna un ApiResponse con el resultado de la operación
  Future<ApiResponse<ChecklistSubmitResponse?>> submitCheckout({
    required int ticketId,
    required Map<String, dynamic> checklistData,
  }) async {
    try {
      // Preparar payload
      final payload = {
        'ticket_id': ticketId,
        ...checklistData,
      };

      await _logService.info('Enviando checkout para ticket: $ticketId');

      // Realizar petición POST
      final response = await http
          .post(
            Uri.parse(ApiConfig.checkoutUrl),
            headers: ApiConfig.headers,
            body: jsonEncode(payload),
          )
          .timeout(ApiConfig.connectTimeout);

      print("========== CHECKOUT RESPONSE ==========");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("=======================================");

      // Procesar respuesta - solo verificar status 200
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _logService.info('Checkout guardado exitosamente para ticket: $ticketId');
        
        return ApiResponse.success(
          data: null,
          message: 'Checkout guardado correctamente',
        );
      } else {
        await _logService.apiError(
          message: 'Error al guardar checkout',
          endpoint: ApiConfig.checkoutUrl,
          statusCode: response.statusCode,
          data: {'ticket_id': ticketId},
        );

        return ApiResponse.error(
          message: 'Error al guardar checkout',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      await _logService.apiError(
        message: 'Error de conexión al enviar checkout: ${e.toString()}',
        endpoint: ApiConfig.checkoutUrl,
        statusCode: 0,
        data: {'ticket_id': ticketId, 'error': e.toString()},
      );

      return ApiResponse.error(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Obtener checklist de checkout existente
  /// 
  /// [ticketId] - ID del ticket
  /// 
  /// Retorna el checklist si existe, null si no
  Future<ApiResponse<Map<String, dynamic>?>> getCheckout({
    required int ticketId,
  }) async {
    try {
      final url = '${ApiConfig.checkoutUrl}/$ticketId';
      
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
          message: 'Checkout obtenido correctamente',
        );
      } else {
        return ApiResponse.error(
          message: body['message'] as String? ?? 'Error al obtener checkout',
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
