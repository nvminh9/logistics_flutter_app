import 'dart:io';
import 'package:nalogistics_app/data/models/driver/driver_list_model.dart';
import 'package:nalogistics_app/data/models/order/assign_driver_response_model.dart';
import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/models/order/order_operator_model.dart';
import 'package:nalogistics_app/data/models/order/order_detail_api_model.dart';
import 'package:nalogistics_app/data/models/order/operator_order_detail_model.dart';
import 'package:nalogistics_app/data/models/order/update_status_response_model.dart';
import 'package:nalogistics_app/data/models/order/confirm_order_response_model.dart';
import 'package:nalogistics_app/data/models/order/pending_image_model.dart';

abstract class IOrderRepository {
  // ========================================
  // DRIVER ROLE METHODS
  // ========================================

  Future<OrderListResponse> getOrdersForDriver({
    String order = 'desc',
    String sortBy = 'id',
    int pageSize = 13,
    int pageNumber = 1,
  });

  Future<OrderDetailResponse> getOrderDetail({
    required String orderID,
  });

  Future<UpdateStatusResponse> updateOrderStatus({
    required String orderID,
    required int statusValue,
  });

  // ========================================
  // OPERATOR ROLE METHODS
  // ========================================

  Future<OperatorOrderListResponse> getOrdersForOperator({
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 30,
    int pageNumber = 1,
    String? fromDate,
    String? toDate,
  });

  Future<OperatorOrderDetailResponse> getOperatorOrderDetail({
    required String orderID,
  });

  Future<UpdateStatusResponse> updateOperatorOrderStatus({
    required String orderID,
    required int statusValue,
  });

  Future<ConfirmOrderResponse> confirmPendingOrder({
    required String orderID,
  });

  // ========================================
  // DRIVER MANAGEMENT METHODS
  // ========================================
  /// Get list of available drivers
  Future<DriverListResponse> getDriverList({
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 100,
    int pageNumber = 1,
    String? keySearch,
  });

  /// Assign driver to order
  Future<AssignDriverResponse> assignDriverToOrder({
    required String orderID,
    required int driverID,
  });

  // ========================================
  // IMAGE UPLOAD METHODS
  // ========================================

  /// ⭐ NEW: Upload single image
  Future<UploadImageResponse> uploadSingleImage({
    required String orderID,
    required File imageFile,
    required String description,
  });

  /// ⭐ UPDATED: Upload multiple images (uploads one by one)
  Future<List<UploadImageResponse>> uploadMultipleImages({
    required String orderID,
    required List<Map<String, dynamic>> images, // {file: File, description: String}
    Function(int current, int total)? onProgress, // Progress callback
  });
}