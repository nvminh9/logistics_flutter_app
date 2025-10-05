class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5167'; // Android Emulator
  // static const String baseUrl = 'http://127.0.0.1:5167'; // iOS Simulator
  static const String apiVersion = '/api';

  // Auth endpoints
  static const String login = '$apiVersion/Auth/login';
  static const String logout = '$apiVersion/Auth/logout';
  static const String driverInfo = '$apiVersion/driver/profile';

  // Driver Role endpoints
  static const String driverOrders = '$apiVersion/DriverRole/listOrderForDriver';
  static const String driverOrderDetail = '$apiVersion/DriverRole/detailOrderForDriver';
  static const String driverUpdateStatus = '$apiVersion/DriverRole/updateStatusOrderForDriver';

  // Operator Role endpoints
  static const String operatorOrders = '$apiVersion/Order/listOrder';
  static const String operatorOrderDetail = '$apiVersion/Order/detailOrder'; // Assuming similar pattern
  static const String operatorUpdateStatus = '$apiVersion/Order/updateStatusOrder'; // Assuming similar pattern

  // Default query parameters for Driver
  static const Map<String, String> defaultDriverOrderParams = {
    'order': 'desc',
    'sortBy': 'id',
    'pageSize': '13',
    'pageNumber': '1',
  };

  // Default query parameters for Operator
  static const Map<String, String> defaultOperatorOrderParams = {
    'order': 'asc',
    'sortBy': 'id',
    'pageSize': '30',
    'pageNumber': '1',
  };

  // Timeout settings
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}