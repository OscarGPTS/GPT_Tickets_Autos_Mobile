/// Configuración centralizada de la API
class ApiConfig {
  // URL base de la API - Cambiar solo esta línea para entornos diferentes
  static const String baseUrl = 'http://192.168.100.62:8000/api';

  // Endpoints del Dispatcher
  static const String loginEndpoint = '/dispatcher/login';
  static const String checkoutEndpoint = '/dispatcher/checklist/checkout';
  static const String checkinEndpoint = '/dispatcher/checklist/checkin';
  static const String ticketDetailEndpoint = '/dispatcher/ticket';
  
  // Endpoints del Usuario
  static const String userTicketsEndpoint = '/user/my-tickets';

  // URLs completas
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get checkoutUrl => '$baseUrl$checkoutEndpoint';
  static String get checkinUrl => '$baseUrl$checkinEndpoint';
  static String ticketUrl(int id) => '$baseUrl$ticketDetailEndpoint/$id';
  static String get userTicketsUrl => '$baseUrl$userTicketsEndpoint';

  // Configuración de timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers comunes
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
