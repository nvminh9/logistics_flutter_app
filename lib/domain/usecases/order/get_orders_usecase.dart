import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_order_repository.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class GetOrdersUseCase {
  final IOrderRepository _orderRepository;

  GetOrdersUseCase(this._orderRepository);

  Future<List<OrderApiModel>> execute({
    OrderStatus? filterStatus, // null = lấy tất cả
    String order = 'desc',
    String sortBy = 'id',
    int pageSize = 13,
    int pageNumber = 1,
  }) async {
    try {
      final response = await _orderRepository.getOrdersForDriver(
        order: order,
        sortBy: sortBy,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

      if (!response.isSuccess) {
        throw Exception(response.message);
      }

      // Nếu filterStatus là null, trả về tất cả orders
      if (filterStatus == null) {
        return response.data;
      }

      // Nếu có filterStatus, lọc theo status
      return response.data
          .where((order) => order.status == filterStatus.value)
          .toList();
    } catch (e) {
      print('❌ GetOrdersUseCase Error: $e');
      rethrow;
    }
  }
}