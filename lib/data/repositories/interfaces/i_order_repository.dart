import 'package:nalogistics_app/data/models/order/order_api_model.dart';

abstract class IOrderRepository {
  Future<OrderListResponse> getOrdersForDriver({
    String order = 'desc',
    String sortBy = 'id',
    int pageSize = 13,
    int pageNumber = 1,
  });
}
