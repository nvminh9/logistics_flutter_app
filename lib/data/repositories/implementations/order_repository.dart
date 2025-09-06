import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_order_repository.dart';
import 'package:nalogistics_app/data/services/api/api_client.dart';

class OrderRepository implements IOrderRepository {
  final ApiClient _apiClient = ApiClient();

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
        '/api/DriverRole/listOrderForDriver',
        queryParams: queryParams,
        requiresAuth: true,
      );

      return OrderListResponse.fromJson(response);
    } catch (e) {
      print('❌ Order Repository Error: $e');
      rethrow;
    }
  }
}