class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  NetworkException(
      this.message, {
        this.statusCode,
        this.originalError,
      });

  @override
  String toString() => message;
}