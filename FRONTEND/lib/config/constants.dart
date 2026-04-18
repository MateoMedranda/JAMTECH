/// Constantes globales de la aplicación
class AppConstants {
  /// URL base del backend API
  static const String baseUrl = 'http://3.19.123.52:8000';

  /// URLs de los endpoints
  static const String usersEndpoint = '$baseUrl/api/users';
  static const String medicalBotEndpoint = '$baseUrl/medical-bot';
  static const String imagePredictionEndpoint = '$baseUrl/image-prediction';

  /// Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
}
