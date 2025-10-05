// lib/data/repositories/interfaces/i_order_repository.dart

import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/models/order/order_operator_model.dart';
import 'package:nalogistics_app/data/models/order/order_detail_api_model.dart';
import 'package:nalogistics_app/data/models/order/update_status_response_model.dart';

abstract class IOrderRepository {
  // ========================================
  // DRIVER ROLE METHODS
  // ========================================

  /// Danh sách đơn hàng của tài xế
  Future<OrderListResponse> getOrdersForDriver({
    String order = 'desc',
    String sortBy = 'id',
    int pageSize = 13,
    int pageNumber = 1,
  });

  /// Chi tiết đơn hàng (Driver)
  Future<OrderDetailResponse> getOrderDetail({
    required String orderID,
  });

  /// Cập nhật trạng thái đơn hàng (Driver)
  Future<UpdateStatusResponse> updateOrderStatus({
    required String orderID,
    required int statusValue,
  });

  // ========================================
  // OPERATOR ROLE METHODS (NEW)
  // ========================================

  /// ⭐ Danh sách TẤT CẢ đơn hàng (Operator)
  Future<OperatorOrderListResponse> getOrdersForOperator({
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 30,
    int pageNumber = 1,
    String? fromDate,
    String? toDate,
  });

  /// ⭐ Chi tiết đơn hàng (Operator) - Có thể khác API Driver
  Future<OrderDetailResponse> getOperatorOrderDetail({
    required String orderID,
  });

  /// ⭐ Cập nhật trạng thái (Operator) - Có thể có permissions khác
  Future<UpdateStatusResponse> updateOperatorOrderStatus({
    required String orderID,
    required int statusValue,
  });
}