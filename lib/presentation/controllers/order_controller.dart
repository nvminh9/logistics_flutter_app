import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/base/base_controller.dart';
import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/repositories/implementations/order_repository.dart';
import 'package:nalogistics_app/domain/usecases/order/get_orders_usecase.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OrderController extends BaseController {
  late final GetOrdersUseCase _getOrdersUseCase;
  late final OrderRepository _orderRepository;

  // ⭐ CHỈ 4 STATUS CẦN HIỂN THị
  static const List<OrderStatus> activeStatuses = [
    OrderStatus.inProgress,
    OrderStatus.pickedUp,
    OrderStatus.inTransit,
    OrderStatus.delivered,
  ];

  // Order data by status
  Map<OrderStatus, List<OrderApiModel>> _ordersByStatus = {};
  Map<OrderStatus, bool> _loadingByStatus = {};
  Map<OrderStatus, String?> _errorByStatus = {};

  // Pagination tracking
  Map<OrderStatus, int> _currentPageByStatus = {};
  Map<OrderStatus, bool> _hasMoreByStatus = {};

  // Flag để check đã load initial data chưa
  bool _initialDataLoaded = false;

  // Getters
  Map<OrderStatus, List<OrderApiModel>> get ordersByStatus => _ordersByStatus;
  Map<OrderStatus, bool> get loadingByStatus => _loadingByStatus;
  Map<OrderStatus, String?> get errorByStatus => _errorByStatus;
  bool get initialDataLoaded => _initialDataLoaded;

  OrderController() {
    _orderRepository = OrderRepository();
    _getOrdersUseCase = GetOrdersUseCase(_orderRepository);
    _initializeData();
  }

  void _initializeData() {
    // ⭐ CHỈ KHỞI TẠO CHO 4 STATUS
    for (var status in activeStatuses) {
      _ordersByStatus[status] = [];
      _loadingByStatus[status] = false;
      _errorByStatus[status] = null;
      _currentPageByStatus[status] = 1;
      _hasMoreByStatus[status] = true;
    }
  }

  // ⭐ LOAD TẤT CẢ 4 TABS NGAY TỪ ĐẦU
  Future<void> loadInitialData() async {
    if (_initialDataLoaded) return;

    try {
      setLoading(true);

      // Set loading cho tất cả 4 status
      for (var status in activeStatuses) {
        _loadingByStatus[status] = true;
      }
      notifyListeners();

      print('🔄 Loading initial data for all 4 tabs...');

      // Gọi API lấy TẤT CẢ orders (không filter)
      final allOrders = await _getOrdersUseCase.execute(
        filterStatus: null,
        pageNumber: 1,
        pageSize: 100, // Lấy nhiều để có đủ data
      );

      print('✅ Received ${allOrders.length} orders from API');

      // ⭐ PHÂN LOẠI ORDERS CHO 4 TABS
      for (var status in activeStatuses) {
        _ordersByStatus[status] = allOrders
            .where((order) => order.status == status.value)
            .toList();

        print('   ${status.shortName}: ${_ordersByStatus[status]!.length} orders');
      }

      // Check xem còn data không (cho pagination sau này)
      if (allOrders.length < 100) {
        for (var status in activeStatuses) {
          _hasMoreByStatus[status] = false;
        }
      }

      _initialDataLoaded = true;

      // Clear loading cho tất cả status
      for (var status in activeStatuses) {
        _loadingByStatus[status] = false;
      }

      setLoading(false);
      notifyListeners();

      print('✅ Initial data loaded successfully for all 4 tabs!');

    } catch (e) {
      print('❌ Load Initial Data Error: $e');

      for (var status in activeStatuses) {
        _loadingByStatus[status] = false;
        _errorByStatus[status] = e.toString();
      }

      setLoading(false);
      setError(e.toString());
      notifyListeners();
    }
  }

  // Load more orders for specific status (pagination)
  Future<void> loadMoreOrders(OrderStatus status) async {
    // Chỉ load more cho 4 status được phép
    if (!activeStatuses.contains(status)) return;

    if (_loadingByStatus[status] == true) return;
    if (_hasMoreByStatus[status] == false) return;

    try {
      _loadingByStatus[status] = true;
      notifyListeners();

      print('📄 Loading more for ${status.shortName}...');

      final newOrders = await _getOrdersUseCase.execute(
        filterStatus: status,
        pageNumber: _currentPageByStatus[status]! + 1,
        pageSize: 13,
      );

      _ordersByStatus[status]!.addAll(newOrders);
      _currentPageByStatus[status] = _currentPageByStatus[status]! + 1;

      // Check if has more
      if (newOrders.length < 13) {
        _hasMoreByStatus[status] = false;
      }

      _loadingByStatus[status] = false;
      notifyListeners();

    } catch (e) {
      print('❌ Load More Error: $e');
      _loadingByStatus[status] = false;
      _errorByStatus[status] = e.toString();
      notifyListeners();
    }
  }

  // Refresh orders for specific status
  Future<void> refreshOrders(OrderStatus status) async {
    // Chỉ refresh cho 4 status được phép
    if (!activeStatuses.contains(status)) return;

    try {
      _loadingByStatus[status] = true;
      _errorByStatus[status] = null;
      notifyListeners();

      print('🔄 Refreshing ${status.shortName}...');

      final orders = await _getOrdersUseCase.execute(
        filterStatus: status,
        pageNumber: 1,
        pageSize: 13,
      );

      _ordersByStatus[status] = orders;
      _currentPageByStatus[status] = 1;
      _hasMoreByStatus[status] = orders.length >= 13;

      _loadingByStatus[status] = false;
      notifyListeners();

    } catch (e) {
      print('❌ Refresh Error: $e');
      _loadingByStatus[status] = false;
      _errorByStatus[status] = e.toString();
      notifyListeners();
    }
  }

  // Refresh tất cả 4 tabs
  Future<void> refreshAllTabs() async {
    _initialDataLoaded = false;
    await loadInitialData();
  }

  // Getters
  bool isLoadingForStatus(OrderStatus status) =>
      _loadingByStatus[status] ?? false;

  bool hasErrorForStatus(OrderStatus status) =>
      _errorByStatus[status] != null;

  String? getError(OrderStatus status) =>
      _errorByStatus[status];

  List<OrderApiModel> getOrders(OrderStatus status) =>
      _ordersByStatus[status] ?? [];

  bool hasMore(OrderStatus status) =>
      _hasMoreByStatus[status] ?? false;

  int getTotalOrdersCount() {
    return activeStatuses.fold(
      0,
          (sum, status) => sum + (_ordersByStatus[status]?.length ?? 0),
    );
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