// lib/data/repositories/implementations/order_repository.dart

import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/models/order/order_operator_model.dart';
import 'package:nalogistics_app/data/models/order/order_detail_api_model.dart';
import 'package:nalogistics_app/data/models/order/operator_order_detail_model.dart';
import 'package:nalogistics_app/data/models/order/update_status_response_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_order_repository.dart';
import 'package:nalogistics_app/data/services/api/api_client.dart';
import 'package:nalogistics_app/core/constants/api_constants.dart';

class OrderRepository implements IOrderRepository {
  final ApiClient _apiClient = ApiClient();

  // ========================================
  // DRIVER ROLE METHODS
  // ========================================

  @override
  Future<OrderListResponse> getOrdersForDriver({
    String order = 'desc',
    String sortBy = 'id',
    int pageSize = 13,
    int pageNumber = 1,
  }) async {
    try {
      final queryParams = {
        'order': order,
        'sortBy': sortBy,
        'pageSize': pageSize.toString(),
        'pageNumber': pageNumber.toString(),
      };

      final response = await _apiClient.get(
        ApiConstants.driverOrders,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return OrderListResponse.fromJson(response);
    } catch (e) {
      print('❌ Driver Order Repository Error: $e');
      rethrow;
    }
  }

  @override
  Future<OrderDetailResponse> getOrderDetail({
    required String orderID,
  }) async {
    try {
      final queryParams = {
        'orderID': orderID,
      };

      final response = await _apiClient.get(
        ApiConstants.driverOrderDetail,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return OrderDetailResponse.fromJson(response);
    } catch (e) {
      print('❌ Order Detail Repository Error: $e');
      rethrow;
    }
  }

  @override
  Future<UpdateStatusResponse> updateOrderStatus({
    required String orderID,
    required int statusValue,
  }) async {
    try {
      final queryParams = {
        'orderID': orderID,
        'statusString': statusValue.toString(),
      };

      print('📤 Updating Driver order status: orderID=$orderID, status=$statusValue');

      final response = await _apiClient.put(
        ApiConstants.driverUpdateStatus,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return UpdateStatusResponse.fromJson(response);
    } catch (e) {
      print('❌ Update Driver Order Status Error: $e');
      rethrow;
    }
  }

  // ========================================
  // OPERATOR ROLE METHODS
  // ========================================

  @override
  Future<OperatorOrderListResponse> getOrdersForOperator({
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 30,
    int pageNumber = 1,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParams = {
        'order': order,
        'sortBy': sortBy,
        'pageSize': pageSize.toString(),
        'pageNumber': pageNumber.toString(),
      };

      // Add optional date filters
      if (fromDate != null) {
        queryParams['fromDate'] = fromDate;
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate;
      }

      print('📤 Operator fetching orders: $queryParams');

      final response = await _apiClient.get(
        ApiConstants.operatorOrders,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return OperatorOrderListResponse.fromJson(response);
    } catch (e) {
      print('❌ Operator Order Repository Error: $e');
      rethrow;
    }
  }

  /// ⭐ NEW: Operator Order Detail với API khác
  /// URI: /api/Order/detailOrder?id=12 (chú ý param là 'id' chứ không phải 'orderID')
  @override
  Future<OperatorOrderDetailResponse> getOperatorOrderDetail({
    required String orderID,
  }) async {
    try {
      final queryParams = {
        'id': orderID, // ⭐ Operator API dùng 'id' thay vì 'orderID'
      };

      print('📤 Operator fetching order detail: id=$orderID');

      final response = await _apiClient.get(
        ApiConstants.operatorOrderDetail,
        queryParams: queryParams,
        requiresAuth: true,
      );

      print('📥 Operator order detail response: ${response['statusCode']}');

      return OperatorOrderDetailResponse.fromJson(response);
    } catch (e) {
      print('❌ Operator Order Detail Repository Error: $e');
      rethrow;
    }
  }

  @override
  Future<UpdateStatusResponse> updateOperatorOrderStatus({
    required String orderID,
    required int statusValue,
  }) async {
    try {
      final queryParams = {
        'orderID': orderID,
        'statusString': statusValue.toString(),
      };

      print('📤 Updating Operator order status: orderID=$orderID, status=$statusValue');

      final response = await _apiClient.put(
        ApiConstants.operatorUpdateStatus,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return UpdateStatusResponse.fromJson(response);
    } catch (e) {
      print('❌ Update Operator Order Status Error: $e');
      rethrow;
    }
  }
}