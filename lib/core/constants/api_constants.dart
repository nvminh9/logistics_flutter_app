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
  static const String operatorConfirmOrder = '$apiVersion/Order/updateStatusOrderForOperator';

  // ==========================================
  // ADMIN/DRIVER MANAGEMENT ENDPOINTS
  // ==========================================
  /// Get list of drivers
  static const String listDrivers = '$apiVersion/admin/Driver/listDriver';

  /// Assign driver to order
  static const String assignDriver = '$apiVersion/Order/assignDriver';

  // ==========================================
  // IMAGE UPLOAD ENDPOINTS
  // ==========================================

  /// New image upload endpoint
  static const String uploadOrderImage = '$apiVersion/Image/createImageAndUpload';

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

  /// Driver list default params
  static const Map<String, String> defaultDriverListParams = {
    'order': 'asc',
    'sortBy': 'id',
    'pageSize': '100',
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
  static String getOperatorOrderDetailUrl(String orderId) {
    return '$operatorOrderDetail?id=$orderId';
  }

  /// Build full URL cho Driver order detail
  static String getDriverOrderDetailUrl(String orderId) {
    return '$driverOrderDetail?orderID=$orderId';
  }

  /// Build URL cho Operator confirm order
  static String getOperatorConfirmOrderUrl(String orderId) {
    return '$operatorConfirmOrder?orderID=$orderId';
  }

  /// Build URL cho driver list with search
  static String getDriverListUrl({String? keySearch}) {
    final params = Map<String, String>.from(defaultDriverListParams);
    if (keySearch != null && keySearch.isNotEmpty) {
      params['keySearch'] = keySearch;
    }

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$listDrivers?$queryString';
  }

  /// Build URL cho assign driver
  static String getAssignDriverUrl(String orderId, int driverId) {
    return '$assignDriver?orderID=$orderId&driverID=$driverId';
  }
}