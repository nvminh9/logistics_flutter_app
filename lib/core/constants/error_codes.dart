class ErrorCodes {
  // HTTP Status Codes
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int tokenExpired = 401;

  // Custom Error Messages
  static const String tokenExpiredMessage = 'Token expired';
  static const String sessionExpiredMessage = 'Session expired';
  static const String unauthorizedMessage = 'Unauthorized';

  // Error Keys trong response từ API
  static const List<String> tokenExpiredKeys = [
    'the token is expired',
    'token expired',
    'token_expired',
    'session expired',
    'session_expired',
    'invalid token',
    'invalid_token',
    'jwt expired',
    'jwt_expired',
  ];

  // Check if error message indicates token expiration
  static bool isTokenExpiredError(String? message) {
    if (message == null) return false;

    final lowerMessage = message.toLowerCase();
    print(lowerMessage);
    return tokenExpiredKeys.any((key) => lowerMessage.contains(key));
  }
}