import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/models/order/order_operator_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_order_repository.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OperatorOrderPageResult {
  final List<OrderApiModel> orders;
  final int totalItems;
  final int totalPages;
  final int pageNumber;
  final int pageSize;

  const OperatorOrderPageResult({
    required this.orders,
    required this.totalItems,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
  });
}

class GetOperatorOrdersUseCase {
  final IOrderRepository _orderRepository;

  GetOperatorOrdersUseCase(this._orderRepository);

  Future<List<OrderApiModel>> execute({
    OrderStatus? filterStatus,
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 30,
    int pageNumber = 1,
    String? fromDate,
    String? toDate,
    String? searchKey,
  }) async {
    try {
      final pageResult = await executePaged(
        filterStatus: filterStatus,
        order: order,
        sortBy: sortBy,
        pageSize: pageSize,
        pageNumber: pageNumber,
        fromDate: fromDate,
        toDate: toDate,
        searchKey: searchKey,
      );

      return pageResult.orders;
    } catch (e) {
      print('GetOperatorOrdersUseCase Error: $e');
      rethrow;
    }
  }

  Future<OperatorOrderPageResult> executePaged({
    OrderStatus? filterStatus,
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 30,
    int pageNumber = 1,
    String? fromDate,
    String? toDate,
    String? searchKey,
  }) async {
    try {
      final response = await _orderRepository.getOrdersForOperator(
        order: order,
        sortBy: sortBy,
        pageSize: pageSize,
        pageNumber: pageNumber,
        fromDate: fromDate,
        toDate: toDate,
        searchKey: searchKey,
        status: filterStatus?.value,
      );

      if (!response.isSuccess || response.data == null) {
        throw Exception(response.message);
      }

      final responseData = response.data!;
      final orders = responseData.listOrder
          .map((operatorOrder) => operatorOrder.toOrderApiModel())
          .toList();

      final filteredOrders = filterStatus == null
          ? orders
          : orders
                .where((order) => order.status == filterStatus.value)
                .toList();

      return OperatorOrderPageResult(
        orders: filteredOrders,
        totalItems: responseData.totalItems,
        totalPages: responseData.totalPages,
        pageNumber: responseData.pageNumber,
        pageSize: responseData.pageSize,
      );
    } catch (e) {
      print('GetOperatorOrdersUseCase Error: $e');
      rethrow;
    }
  }

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
      print('GetOperatorOrdersUseCase (Raw) Error: $e');
      rethrow;
    }
  }
}
