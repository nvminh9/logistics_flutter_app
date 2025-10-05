// lib/domain/usecases/order/get_operator_orders_usecase.dart

import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/models/order/order_operator_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_order_repository.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class GetOperatorOrdersUseCase {
  final IOrderRepository _orderRepository;

  GetOperatorOrdersUseCase(this._orderRepository);

  /// Execute - Lấy danh sách orders cho Operator
  /// Convert OperatorOrderModel → OrderApiModel để tương thích với UI hiện tại
  Future<List<OrderApiModel>> execute({
    OrderStatus? filterStatus,
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 30,
    int pageNumber = 1,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      // Gọi API Operator
      final response = await _orderRepository.getOrdersForOperator(
        order: order,
        sortBy: sortBy,
        pageSize: pageSize,
        pageNumber: pageNumber,
        fromDate: fromDate,
        toDate: toDate,
      );

      if (!response.isSuccess || response.data == null) {
        throw Exception(response.message);
      }

      // Convert OperatorOrderModel → OrderApiModel
      final orders = response.data!.listOrder
          .map((operatorOrder) => operatorOrder.toOrderApiModel())
          .toList();

      // Nếu có filterStatus, lọc theo status
      if (filterStatus != null) {
        return orders
            .where((order) => order.status == filterStatus.value)
            .toList();
      }

      return orders;
    } catch (e) {
      print('❌ GetOperatorOrdersUseCase Error: $e');
      rethrow;
    }
  }

  /// Execute với return native OperatorOrderModel (nếu cần full data)
  Future<List<OperatorOrderModel>> executeRaw({
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 30,
    int pageNumber = 1,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final response = await _orderRepository.getOrdersForOperator(
        order: order,
        sortBy: sortBy,
        pageSize: pageSize,
        pageNumber: pageNumber,
        fromDate: fromDate,
        toDate: toDate,
      );

      if (!response.isSuccess || response.data == null) {
        throw Exception(response.message);
      }

      return response.data!.listOrder;
    } catch (e) {
      print('❌ GetOperatorOrdersUseCase (Raw) Error: $e');
      rethrow;
    }
  }
}