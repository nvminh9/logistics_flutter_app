// lib/data/repositories/interfaces/i_order_repository.dart

import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/models/order/order_operator_model.dart';
import 'package:nalogistics_app/data/models/order/order_detail_api_model.dart';
import 'package:nalogistics_app/data/models/order/operator_order_detail_model.dart';
import 'package:nalogistics_app/data/models/order/update_status_response_model.dart';
import 'package:nalogistics_app/data/models/order/confirm_order_response_model.dart';

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

  // ⭐ NEW: Confirm pending order (chuyển Pending → InProgress)
  Future<ConfirmOrderResponse> confirmPendingOrder({
    required String orderID,
  });
}