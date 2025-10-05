// lib/presentation/controllers/order_controller.dart

import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/base/base_controller.dart';
import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/repositories/implementations/order_repository.dart';
import 'package:nalogistics_app/domain/usecases/order/get_orders_usecase.dart';
import 'package:nalogistics_app/domain/usecases/order/get_operator_orders_usecase.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';
import 'package:nalogistics_app/shared/enums/user_role_enum.dart';

class OrderController extends BaseController {
  late final GetOrdersUseCase _getOrdersUseCase;
  late final GetOperatorOrdersUseCase _getOperatorOrdersUseCase;
  late final OrderRepository _orderRepository;

  // ⭐ Current user role
  UserRole _userRole = UserRole.driver;
  UserRole get userRole => _userRole;

  // ⭐ STATUS TABS - Dynamic based on role
  List<OrderStatus> get activeStatuses {
    if (_userRole.isOperator) {
      // OPERATOR: 5 tabs including Pending
      return const [
        OrderStatus.pending,      // ⭐ NEW for Operator
        OrderStatus.inProgress,
        OrderStatus.pickedUp,
        OrderStatus.inTransit,
        OrderStatus.delivered,
      ];
    } else {
      // DRIVER: 4 tabs (no Pending)
      return const [
        OrderStatus.inProgress,
        OrderStatus.pickedUp,
        OrderStatus.inTransit,
        OrderStatus.delivered,
      ];
    }
  }

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
    _getOperatorOrdersUseCase = GetOperatorOrdersUseCase(_orderRepository);
    _initializeData();
  }

  /// ⭐ Set user role (gọi từ bên ngoài khi login)
  void setUserRole(UserRole role) {
    if (_userRole != role) {
      _userRole = role;
      print('📋 OrderController: Role changed to ${role.displayName}');
      print('   → Tabs count: ${activeStatuses.length}');
      print('   → Statuses: ${activeStatuses.map((s) => s.shortName).join(", ")}');

      // Reset data khi đổi role
      _initialDataLoaded = false;
      _initializeData();
      notifyListeners();
    }
  }

  void _initializeData() {
    // ⭐ Khởi tạo cho tất cả statuses theo role
    for (var status in activeStatuses) {
      _ordersByStatus[status] = [];
      _loadingByStatus[status] = false;
      _errorByStatus[status] = null;
      _currentPageByStatus[status] = 1;
      _hasMoreByStatus[status] = true;
    }
  }

  /// ⭐ LOAD TẤT CẢ TABS NGAY TỪ ĐẦU (Role-aware)
  Future<void> loadInitialData() async {
    if (_initialDataLoaded) return;

    try {
      setLoading(true);

      // Set loading cho tất cả statuses
      for (var status in activeStatuses) {
        _loadingByStatus[status] = true;
      }
      notifyListeners();

      print('🔄 Loading initial data for role: ${_userRole.displayName}...');
      print('   → Loading ${activeStatuses.length} tabs');

      List<OrderApiModel> allOrders;

      // ⭐ Gọi API tương ứng theo role
      if (_userRole.isOperator) {
        // OPERATOR: Gọi API Operator
        allOrders = await _getOperatorOrdersUseCase.execute(
          filterStatus: null,
          pageNumber: 1,
          pageSize: 100,
          order: 'asc',
          sortBy: 'id',
        );
        print('✅ [OPERATOR] Received ${allOrders.length} orders from API');
      } else {
        // DRIVER: Gọi API Driver (existing)
        allOrders = await _getOrdersUseCase.execute(
          filterStatus: null,
          pageNumber: 1,
          pageSize: 100,
          order: 'desc',
          sortBy: 'id',
        );
        print('✅ [DRIVER] Received ${allOrders.length} orders from API');
      }

      // ⭐ PHÂN LOẠI ORDERS CHO CÁC TABS
      for (var status in activeStatuses) {
        _ordersByStatus[status] = allOrders
            .where((order) => order.status == status.value)
            .toList();

        print('   ${status.shortName}: ${_ordersByStatus[status]!.length} orders');
      }

      // Check xem còn data không
      if (allOrders.length < 100) {
        for (var status in activeStatuses) {
          _hasMoreByStatus[status] = false;
        }
      }

      _initialDataLoaded = true;

      // Clear loading
      for (var status in activeStatuses) {
        _loadingByStatus[status] = false;
      }

      setLoading(false);
      notifyListeners();

      print('✅ Initial data loaded successfully for ${_userRole.displayName}!');

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

  /// Load more orders for specific status (pagination)
  Future<void> loadMoreOrders(OrderStatus status) async {
    if (!activeStatuses.contains(status)) return;
    if (_loadingByStatus[status] == true) return;
    if (_hasMoreByStatus[status] == false) return;

    try {
      _loadingByStatus[status] = true;
      notifyListeners();

      print('📄 Loading more for ${status.shortName}...');

      List<OrderApiModel> newOrders;

      // ⭐ Gọi API tương ứng theo role
      if (_userRole.isOperator) {
        newOrders = await _getOperatorOrdersUseCase.execute(
          filterStatus: status,
          pageNumber: _currentPageByStatus[status]! + 1,
          pageSize: 30,
        );
      } else {
        newOrders = await _getOrdersUseCase.execute(
          filterStatus: status,
          pageNumber: _currentPageByStatus[status]! + 1,
          pageSize: 13,
        );
      }

      _ordersByStatus[status]!.addAll(newOrders);
      _currentPageByStatus[status] = _currentPageByStatus[status]! + 1;

      // Check if has more
      final pageSize = _userRole.isOperator ? 30 : 13;
      if (newOrders.length < pageSize) {
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

  /// Refresh orders for specific status
  Future<void> refreshOrders(OrderStatus status) async {
    if (!activeStatuses.contains(status)) return;

    try {
      _loadingByStatus[status] = true;
      _errorByStatus[status] = null;
      notifyListeners();

      print('🔄 Refreshing ${status.shortName}...');

      List<OrderApiModel> orders;

      // ⭐ Gọi API tương ứng theo role
      if (_userRole.isOperator) {
        orders = await _getOperatorOrdersUseCase.execute(
          filterStatus: status,
          pageNumber: 1,
          pageSize: 30,
        );
      } else {
        orders = await _getOrdersUseCase.execute(
          filterStatus: status,
          pageNumber: 1,
          pageSize: 13,
        );
      }

      _ordersByStatus[status] = orders;
      _currentPageByStatus[status] = 1;

      final pageSize = _userRole.isOperator ? 30 : 13;
      _hasMoreByStatus[status] = orders.length >= pageSize;

      _loadingByStatus[status] = false;
      notifyListeners();

    } catch (e) {
      print('❌ Refresh Error: $e');
      _loadingByStatus[status] = false;
      _errorByStatus[status] = e.toString();
      notifyListeners();
    }
  }

  /// Refresh tất cả tabs
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