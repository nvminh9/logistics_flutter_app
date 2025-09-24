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

  // Data cho tab "Tất cả"
  List<OrderApiModel> _allOrders = [];
  bool _allOrdersLoading = false;
  String? _allOrdersError;
  int _allOrdersCurrentPage = 1;
  bool _allOrdersHasMore = true;

  // Current page tracking for pagination
  Map<OrderStatus, int> _currentPageByStatus = {};
  Map<OrderStatus, bool> _hasMoreByStatus = {};

  // Flag để check đã load initial data chưa
  bool _initialDataLoaded = false;

  // Getters
  Map<OrderStatus, List<OrderApiModel>> get ordersByStatus => _ordersByStatus;
  Map<OrderStatus, bool> get loadingByStatus => _loadingByStatus;
  Map<OrderStatus, String?> get errorByStatus => _errorByStatus;

  // Getters cho tab "Tất cả"
  List<OrderApiModel> get allOrders => _allOrders;
  bool get allOrdersLoading => _allOrdersLoading;
  String? get allOrdersError => _allOrdersError;
  bool get allOrdersHasMore => _allOrdersHasMore;
  bool get initialDataLoaded => _initialDataLoaded;

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

  // Load initial data cho tất cả tabs
  Future<void> loadInitialData() async {
    if (_initialDataLoaded) return;

    try {
      setLoading(true);
      _allOrdersLoading = true;

      // Set loading cho tất cả status
      for (var status in OrderStatus.values) {
        _loadingByStatus[status] = true;
      }
      notifyListeners();

      // Gọi API lấy tất cả orders
      final orders = await _getOrdersUseCase.execute(
        filterStatus: null,
        pageNumber: 1,
        pageSize: 100, // Lấy nhiều để có data cho các tab
      );

      // Lưu tất cả orders
      _allOrders = orders;

      // Phân loại orders theo status
      for (var status in OrderStatus.values) {
        _ordersByStatus[status] = orders
            .where((order) => order.status == status.value)
            .toList();
      }

      // Check xem còn data không
      if (orders.length < 100) {
        _allOrdersHasMore = false;
        for (var status in OrderStatus.values) {
          _hasMoreByStatus[status] = false;
        }
      }

      _initialDataLoaded = true;
      _allOrdersLoading = false;

      // Clear loading cho tất cả status
      for (var status in OrderStatus.values) {
        _loadingByStatus[status] = false;
      }

      setLoading(false);
      notifyListeners();

    } catch (e) {
      print('❌ Load Initial Data Error: $e');
      _allOrdersLoading = false;
      _allOrdersError = e.toString();

      for (var status in OrderStatus.values) {
        _loadingByStatus[status] = false;
        _errorByStatus[status] = e.toString();
      }

      setLoading(false);
      setError(e.toString());
      notifyListeners();
    }
  }

  // Load tất cả đơn hàng (không filter theo status)
  Future<void> loadAllOrders({bool refresh = false}) async {
    try {
      if (_allOrdersLoading) return;

      if (refresh) {
        _allOrdersCurrentPage = 1;
        _allOrdersHasMore = true;
        _allOrders = [];
        _initialDataLoaded = false;

        // Reset data cho tất cả status
        for (var status in OrderStatus.values) {
          _ordersByStatus[status] = [];
          _currentPageByStatus[status] = 1;
          _hasMoreByStatus[status] = true;
        }
      }

      _allOrdersLoading = true;
      _allOrdersError = null;
      notifyListeners();

      // Gọi API không có filter status để lấy tất cả
      final orders = await _getOrdersUseCase.execute(
        filterStatus: null,
        pageNumber: _allOrdersCurrentPage,
        pageSize: 13,
      );

      if (refresh) {
        _allOrders = orders;

        // Phân loại lại orders theo status
        for (var status in OrderStatus.values) {
          _ordersByStatus[status] = orders
              .where((order) => order.status == status.value)
              .toList();
        }
      } else {
        _allOrders.addAll(orders);

        // Thêm orders mới vào các status tương ứng
        for (var order in orders) {
          final status = OrderStatusExtension.fromValue(order.status);
          _ordersByStatus[status]?.add(order);
        }
      }

      // Check if there are more pages
      if (orders.length < 13) {
        _allOrdersHasMore = false;
      } else {
        _allOrdersCurrentPage++;
      }

      _allOrdersLoading = false;
      notifyListeners();

    } catch (e) {
      print('❌ Load All Orders Error: $e');
      _allOrdersLoading = false;
      _allOrdersError = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshAllOrders() async {
    // Reset initial data flag và clear all data
    _initialDataLoaded = false;
    await loadAllOrders(refresh: true);
    _initialDataLoaded = true; // Set lại sau khi refresh xong
  }

  Future<void> loadMoreAllOrders() async {
    if (_allOrdersHasMore && !_allOrdersLoading) {
      await loadAllOrders();
    }
  }

  // Load orders by status (existing method - modified)
  Future<void> loadOrders(OrderStatus status, {bool refresh = false}) async {
    try {
      // Nếu đã có initial data và không phải refresh, return
      if (_initialDataLoaded && !refresh) {
        return;
      }

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
        pageSize: 13,
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
    // Include all orders in total count
    return _allOrders.length;
  }

  int getOrdersCount(OrderStatus status) {
    return _ordersByStatus[status]?.length ?? 0;
  }

  int getAllOrdersCount() {
    return _allOrders.length;
  }

  void clearErrorForStatus(OrderStatus status) {
    _errorByStatus[status] = null;
    notifyListeners();
  }

  void clearAllOrdersError() {
    _allOrdersError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}