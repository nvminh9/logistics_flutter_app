class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5167'; // Android Emulator (localhost server)
// static const String baseUrl = 'http://127.0.0.1:5167'; // iOS Simulator (localhost server)
  static const String apiVersion = '/api';

  // Auth endpoints
  static const String login = '$apiVersion/Auth/login';
  static const String logout = '$apiVersion/Auth/logout';
  static const String driverInfo = '$apiVersion/driver/profile';

  // Order endpoints
  static const String orders = '$apiVersion/DriverRole/listOrderForDriver'; // List Order
  static const String orderDetail = '$apiVersion/DriverRole/detailOrderForDriver'; // Order Detail
  static const String updateOrderStatus = '$apiVersion/DriverRole/updateStatusOrderForDriver'; // Update Order Status
  // static const String confirmOrder = '$apiVersion/driver/orders/{id}/confirm';

  // Default query parameters
  static const Map<String, String> defaultOrderParams = {
    'order': 'desc',
    'sortBy': 'id',
    'pageSize': '13',
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