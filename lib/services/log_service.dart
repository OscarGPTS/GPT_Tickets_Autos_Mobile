import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Tipos de log
enum LogLevel {
  info,
  warning,
  error,
  apiError,
}

/// Servicio para registrar logs de la aplicación
class LogService {
  // Singleton pattern
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  static const String _keyLogs = 'app_logs';
  static const int _maxLogs = 100; // Mantener solo los últimos 100 logs

  /// Registrar un log
  Future<void> log({
    required String message,
    required LogLevel level,
    String? endpoint,
    int? statusCode,
    Map<String, dynamic>? data,
    String? stackTrace,
  }) async {
    try {
      final logEntry = LogEntry(
        timestamp: DateTime.now(),
        level: level,
        message: message,
        endpoint: endpoint,
        statusCode: statusCode,
        data: data,
        stackTrace: stackTrace,
      );

      final prefs = await SharedPreferences.getInstance();
      final logs = await _getLogs();
      
      // Agregar nuevo log
      logs.insert(0, logEntry);
      
      // Mantener solo los últimos _maxLogs
      if (logs.length > _maxLogs) {
        logs.removeRange(_maxLogs, logs.length);
      }

      // Guardar
      await prefs.setString(
        _keyLogs,
        jsonEncode(logs.map((l) => l.toJson()).toList()),
      );

      // Imprimir en consola en debug
      print('[$_formattedLevel(level)] $message');
      if (endpoint != null) print('  Endpoint: $endpoint');
      if (statusCode != null) print('  Status: $statusCode');
      if (data != null) print('  Data: ${jsonEncode(data)}');
      if (stackTrace != null) print('  Stack: $stackTrace');
    } catch (e) {
      print('Error al guardar log: $e');
    }
  }

  /// Obtener logs guardados
  Future<List<LogEntry>> _getLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_keyLogs);

      if (logsJson == null) return [];

      final List<dynamic> logsData = jsonDecode(logsJson);
      return logsData
          .map((log) => LogEntry.fromJson(log as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener logs (público)
  Future<List<LogEntry>> getLogs() async {
    return await _getLogs();
  }

  /// Obtener logs de errores solamente
  Future<List<LogEntry>> getErrorLogs() async {
    final logs = await _getLogs();
    return logs.where((log) => 
      log.level == LogLevel.error || log.level == LogLevel.apiError
    ).toList();
  }

  /// Limpiar todos los logs
  Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLogs);
  }

  /// Exportar logs como texto
  Future<String> exportLogs() async {
    final logs = await _getLogs();
    final buffer = StringBuffer();
    
    buffer.writeln('=== LOGS DE LA APLICACIÓN ===');
    buffer.writeln('Generado: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total de logs: ${logs.length}');
    buffer.writeln('');

    for (var log in logs) {
      buffer.writeln('[$_formattedLevel(log.level)] ${log.timestamp.toIso8601String()}');
      buffer.writeln('  Mensaje: ${log.message}');
      if (log.endpoint != null) buffer.writeln('  Endpoint: ${log.endpoint}');
      if (log.statusCode != null) buffer.writeln('  Status: ${log.statusCode}');
      if (log.data != null) buffer.writeln('  Data: ${jsonEncode(log.data)}');
      if (log.stackTrace != null) buffer.writeln('  Stack: ${log.stackTrace}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _formattedLevel(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.apiError:
        return 'API ERROR';
    }
  }

  /// Métodos helper para registrar diferentes tipos de logs
  Future<void> info(String message) async {
    await log(message: message, level: LogLevel.info);
  }

  Future<void> warning(String message) async {
    await log(message: message, level: LogLevel.warning);
  }

  Future<void> error(String message, {String? stackTrace}) async {
    await log(
      message: message,
      level: LogLevel.error,
      stackTrace: stackTrace,
    );
  }

  Future<void> apiError({
    required String message,
    required String endpoint,
    int? statusCode,
    Map<String, dynamic>? data,
  }) async {
    await log(
      message: message,
      level: LogLevel.apiError,
      endpoint: endpoint,
      statusCode: statusCode,
      data: data,
    );
  }
}

/// Modelo de entrada de log
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? endpoint;
  final int? statusCode;
  final Map<String, dynamic>? data;
  final String? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.endpoint,
    this.statusCode,
    this.data,
    this.stackTrace,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: LogLevel.values.firstWhere(
        (e) => e.toString() == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'] as String,
      endpoint: json['endpoint'] as String?,
      statusCode: json['statusCode'] as int?,
      data: json['data'] as Map<String, dynamic>?,
      stackTrace: json['stackTrace'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.toString(),
      'message': message,
      'endpoint': endpoint,
      'statusCode': statusCode,
      'data': data,
      'stackTrace': stackTrace,
    };
  }

  String get levelName {
    switch (level) {
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.apiError:
        return 'API ERROR';
    }
  }
}
