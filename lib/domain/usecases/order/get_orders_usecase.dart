import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_order_repository.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class GetOrdersUseCase {
  final IOrderRepository _orderRepository;

  GetOrdersUseCase(this._orderRepository);

  Future<List<OrderApiModel>> execute({
    OrderStatus? filterStatus,
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

      // Filter by status if specified
      if (filterStatus != null) {
        return response.data
            .where((order) => order.status == filterStatus.value)
            .toList();
      }

      return response.data;
    } catch (e) {
      print('❌ GetOrdersUseCase Error: $e');
      rethrow;
    }
  }
}