import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/base/base_controller.dart';
import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/repositories/implementations/order_repository.dart';
import 'package:nalogistics_app/domain/usecases/order/get_orders_usecase.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OrderController extends BaseController {
  late final GetOrdersUseCase _getOrdersUseCase;
  late final OrderRepository _orderRepository;

  // Order data by status
  Map<OrderStatus, List<OrderApiModel>> _ordersByStatus = {};
  Map<OrderStatus, bool> _loadingByStatus = {};
  Map<OrderStatus, String?> _errorByStatus = {};

  // Current page tracking for pagination
  Map<OrderStatus, int> _currentPageByStatus = {};
  Map<OrderStatus, bool> _hasMoreByStatus = {};

  // Getters
  Map<OrderStatus, List<OrderApiModel>> get ordersByStatus => _ordersByStatus;
  Map<OrderStatus, bool> get loadingByStatus => _loadingByStatus;
  Map<OrderStatus, String?> get errorByStatus => _errorByStatus;

  OrderController() {
    _orderRepository = OrderRepository();
    _getOrdersUseCase = GetOrdersUseCase(_orderRepository);
    _initializeData();
  }

  void _initializeData() {
    for (var status in OrderStatus.values) {
      _ordersByStatus[status] = [];
      _loadingByStatus[status] = false;
      _errorByStatus[status] = null;
      _currentPageByStatus[status] = 1;
      _hasMoreByStatus[status] = true;
    }
  }

  Future<void> loadOrders(OrderStatus status, {bool refresh = false}) async {
    try {
      if (_loadingByStatus[status] == true) return;

      if (refresh) {
        _currentPageByStatus[status] = 1;
        _hasMoreByStatus[status] = true;
        _ordersByStatus[status] = [];
      }

      _loadingByStatus[status] = true;
      _errorByStatus[status] = null;
      notifyListeners();

      final orders = await _getOrdersUseCase.execute(
        filterStatus: status,
        pageNumber: _currentPageByStatus[status]!,
      );

      if (refresh) {
        _ordersByStatus[status] = orders;
      } else {
        _ordersByStatus[status]!.addAll(orders);
      }

      // Check if there are more pages
      if (orders.length < 13) {
        _hasMoreByStatus[status] = false;
      } else {
        _currentPageByStatus[status] = _currentPageByStatus[status]! + 1;
      }

      _loadingByStatus[status] = false;
      notifyListeners();

    } catch (e) {
      print('❌ Load Orders Error: $e');
      _loadingByStatus[status] = false;
      _errorByStatus[status] = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshOrders(OrderStatus status) async {
    await loadOrders(status, refresh: true);
  }

  Future<void> loadMoreOrders(OrderStatus status) async {
    if (_hasMoreByStatus[status] == true && _loadingByStatus[status] == false) {
      await loadOrders(status);
    }
  }

  bool isLoadingForStatus(OrderStatus status) => _loadingByStatus[status] ?? false;
  bool hasErrorForStatus(OrderStatus status) => _errorByStatus[status] != null;
  String? getError(OrderStatus status) => _errorByStatus[status];
  List<OrderApiModel> getOrders(OrderStatus status) => _ordersByStatus[status] ?? [];
  bool hasMore(OrderStatus status) => _hasMoreByStatus[status] ?? false;

  int getTotalOrdersCount() {
    return _ordersByStatus.values
        .map((orders) => orders.length)
        .fold(0, (a, b) => a + b);
  }

  int getOrdersCount(OrderStatus status) {
    return _ordersByStatus[status]?.length ?? 0;
  }

  void clearErrorForStatus(OrderStatus status) {
    _errorByStatus[status] = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}