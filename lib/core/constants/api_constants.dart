class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5167'; // Android Emulator
  // static const String baseUrl = 'http://127.0.0.1:5167'; // iOS Simulator
  static const String apiVersion = '/api';

  // ==========================================
  // AUTH ENDPOINTS
  // ==========================================
  static const String login = '$apiVersion/Auth/login';
  static const String logout = '$apiVersion/Auth/logout';
  static const String driverInfo = '$apiVersion/driver/profile';

  // ==========================================
  // DRIVER ROLE ENDPOINTS
  // ==========================================
  static const String driverOrders = '$apiVersion/DriverRole/listOrderForDriver';
  static const String driverOrderDetail = '$apiVersion/DriverRole/detailOrderForDriver';
  static const String driverUpdateStatus = '$apiVersion/DriverRole/updateStatusOrderForDriver';

  // ==========================================
  // OPERATOR ROLE ENDPOINTS
  // ==========================================
  static const String operatorOrders = '$apiVersion/Order/listOrder';
  static const String operatorOrderDetail = '$apiVersion/Order/detailOrder';
  static const String operatorUpdateStatus = '$apiVersion/Order/updateStatusOrder';

  // ⭐ NEW: Operator confirm pending order (chuyển từ Pending → InProgress)
  static const String operatorConfirmOrder = '$apiVersion/Order/updateStatusOrderForOperator';

  // ==========================================
  // DEFAULT QUERY PARAMETERS
  // ==========================================

  /// Driver default params
  static const Map<String, String> defaultDriverOrderParams = {
    'order': 'desc',
    'sortBy': 'id',
    'pageSize': '13',
    'pageNumber': '1',
  };

  /// Operator default params
  static const Map<String, String> defaultOperatorOrderParams = {
    'order': 'asc',
    'sortBy': 'id',
    'pageSize': '30',
    'pageNumber': '1',
  };

  // ==========================================
  // TIMEOUT SETTINGS
  // ==========================================
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // ==========================================
  // HEADERS
  // ==========================================
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Build full URL cho Operator order detail
  /// Example: /api/Order/detailOrder?id=12
  static String getOperatorOrderDetailUrl(String orderId) {
    return '$operatorOrderDetail?id=$orderId';
  }

  /// Build full URL cho Driver order detail
  /// Example: /api/DriverRole/detailOrderForDriver?orderID=12
  static String getDriverOrderDetailUrl(String orderId) {
    return '$driverOrderDetail?orderID=$orderId';
  }

  /// ⭐ Build URL cho Operator confirm order
  /// Example: /api/Order/updateStatusOrderForOperator?orderID=12
  static String getOperatorConfirmOrderUrl(String orderId) {
    return '$operatorConfirmOrder?orderID=$orderId';
  }
}