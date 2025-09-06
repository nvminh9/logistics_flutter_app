class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(
      this.message, {
        this.code,
        this.originalError,
      });

  @override
  String toString() => message;
}