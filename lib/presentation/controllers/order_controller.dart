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

  // ⭐ Search state
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // ⭐ Current user role
  UserRole _userRole = UserRole.driver;
  UserRole get userRole => _userRole;

  // ⭐ Date filter state
  DateTime? _fromDate;
  DateTime? _toDate;

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  bool get hasDateFilter => _fromDate != null || _toDate != null;

  // ⭐ STATUS TABS - Dynamic based on role
  List<OrderStatus> get activeStatuses {
    if (_userRole.isOperator) {
      return const [
        OrderStatus.pending,
        OrderStatus.inProgress,
        OrderStatus.pickedUp,
        OrderStatus.inTransit,
        OrderStatus.delivered,
      ];
    } else {
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

  // ⭐ NEW: Pagination state
  Map<OrderStatus, int> _currentPageByStatus = {};
  Map<OrderStatus, int> _totalPagesByStatus = {};
  Map<OrderStatus, int> _totalItemsByStatus = {};
  Map<OrderStatus, bool> _isPaginationLoadingByStatus = {};

  // Flag để check đã load initial data chưa
  bool _initialDataLoaded = false;

  // Getters
  Map<OrderStatus, List<OrderApiModel>> get ordersByStatus => _ordersByStatus;
  Map<OrderStatus, bool> get loadingByStatus => _loadingByStatus;
  Map<OrderStatus, String?> get errorByStatus => _errorByStatus;
  bool get initialDataLoaded => _initialDataLoaded;

  // ⭐ NEW: Pagination getters
  Map<OrderStatus, int> get currentPageByStatus => _currentPageByStatus;
  Map<OrderStatus, int> get totalPagesByStatus => _totalPagesByStatus;
  Map<OrderStatus, int> get totalItemsByStatus => _totalItemsByStatus;
  Map<OrderStatus, bool> get isPaginationLoadingByStatus => _isPaginationLoadingByStatus;

  OrderController() {
    _orderRepository = OrderRepository();
    _getOrdersUseCase = GetOrdersUseCase(_orderRepository);
    _getOperatorOrdersUseCase = GetOperatorOrdersUseCase(_orderRepository);
    _initializeData();
  }

  // ⭐ Set user role
  void setUserRole(UserRole role) {
    if (_userRole != role) {
      _userRole = role;
      print('📋 OrderController: Role changed to ${role.displayName}');
      _initialDataLoaded = false;
      _initializeData();
      notifyListeners();
    }
  }

  void _initializeData() {
    for (var status in activeStatuses) {
      _ordersByStatus[status] = [];
      _loadingByStatus[status] = false;
      _errorByStatus[status] = null;
      _currentPageByStatus[status] = 1;
      _totalPagesByStatus[status] = 1;
      _totalItemsByStatus[status] = 0;
      _isPaginationLoadingByStatus[status] = false;
    }
  }

  // ⭐ Set search query
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  // ⭐ Clear search
  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  // ⭐ Set date filter
  void setDateFilter(DateTime? fromDate, DateTime? toDate) {
    _fromDate = fromDate;
    _toDate = toDate;
    notifyListeners();
  }

  // ⭐ Clear date filter
  void clearDateFilter() {
    _fromDate = null;
    _toDate = null;
    notifyListeners();
  }

  // ⭐ Format date for API
  String? _formatDateForApi(DateTime? date) {
    if (date == null) return null;
    return date.toIso8601String();
  }

  // ⭐ UPDATED: Load initial data
  Future<void> loadInitialData({
    String? searchKey,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (_initialDataLoaded && searchKey == null && fromDate == null && toDate == null) {
      return;
    }

    try {
      setLoading(true);
      _isSearching = searchKey != null && searchKey.isNotEmpty;

      if (fromDate != null || toDate != null) {
        _fromDate = fromDate;
        _toDate = toDate;
      }

      for (var status in activeStatuses) {
        _loadingByStatus[status] = true;
        _currentPageByStatus[status] = 1; // Reset to page 1
      }
      notifyListeners();

      print('🔄 Loading initial data for role: ${_userRole.displayName}...');
      if (_isSearching) print('   🔍 Searching for: $searchKey');
      if (hasDateFilter) {
        print('   📅 Date filter: ${_formatDateForApi(_fromDate)} to ${_formatDateForApi(_toDate)}');
      }

      // ⭐ Load page 1 for all tabs
      for (var status in activeStatuses) {
        await _loadPageForStatus(
          status: status,
          pageNumber: 1,
          searchKey: searchKey,
          fromDate: _formatDateForApi(_fromDate),
          toDate: _formatDateForApi(_toDate),
        );
      }

      _initialDataLoaded = true;
      setLoading(false);
      notifyListeners();

      print('✅ Initial data loaded successfully!');

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

  // ⭐ NEW: Load specific page for status
  Future<void> _loadPageForStatus({
    required OrderStatus status,
    required int pageNumber,
    String? searchKey,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      List<OrderApiModel> orders;
      final pageSize = _userRole.isOperator ? 30 : 13;
      // final pageSize = 6; // Test pagination

      if (_userRole.isOperator) {
        orders = await _getOperatorOrdersUseCase.execute(
          filterStatus: status,
          pageNumber: pageNumber,
          pageSize: pageSize,
          order: 'desc',        // ⭐ UPDATED: desc (newest first)
          sortBy: 'orderDate',  // ⭐ UPDATED: orderDate
          searchKey: searchKey,
          fromDate: fromDate,
          toDate: toDate,
        );
      } else {
        orders = await _getOrdersUseCase.execute(
          filterStatus: status,
          pageNumber: pageNumber,
          pageSize: pageSize,
          order: 'desc',        // ⭐ UPDATED: desc (newest first)
          sortBy: 'orderDate',  // ⭐ UPDATED: orderDate
          searchKey: searchKey,
        );
      }

      _ordersByStatus[status] = orders;
      _currentPageByStatus[status] = pageNumber;

      // ⭐ Calculate total pages (giả sử API không trả về total count)
      // Nếu số orders < pageSize thì đây là trang cuối
      if (orders.length < pageSize) {
        _totalPagesByStatus[status] = pageNumber;
      } else {
        // Nếu có đủ pageSize items, có thể có trang tiếp theo
        _totalPagesByStatus[status] = pageNumber + 1;
      }

      _totalItemsByStatus[status] = orders.length;
      _loadingByStatus[status] = false;

      print('   ✅ ${status.shortName}: Loaded page $pageNumber with ${orders.length} orders');

    } catch (e) {
      print('   ❌ ${status.shortName}: Error loading page $pageNumber: $e');
      _errorByStatus[status] = e.toString();
      _loadingByStatus[status] = false;
      throw e;
    }
  }

  // ⭐ NEW: Go to specific page
  Future<void> goToPage(OrderStatus status, int pageNumber) async {
    if (!activeStatuses.contains(status)) return;
    if (pageNumber < 1) return;
    if (pageNumber == _currentPageByStatus[status]) return;

    try {
      _isPaginationLoadingByStatus[status] = true;
      notifyListeners();

      print('📄 Loading page $pageNumber for ${status.shortName}...');

      await _loadPageForStatus(
        status: status,
        pageNumber: pageNumber,
        searchKey: _isSearching ? _searchQuery : null,
        fromDate: _formatDateForApi(_fromDate),
        toDate: _formatDateForApi(_toDate),
      );

      _isPaginationLoadingByStatus[status] = false;
      notifyListeners();

    } catch (e) {
      print('❌ Go To Page Error: $e');
      _isPaginationLoadingByStatus[status] = false;
      _errorByStatus[status] = e.toString();
      notifyListeners();
    }
  }

  // ⭐ NEW: Next page
  Future<void> nextPage(OrderStatus status) async {
    final currentPage = _currentPageByStatus[status] ?? 1;
    final totalPages = _totalPagesByStatus[status] ?? 1;

    if (currentPage < totalPages) {
      await goToPage(status, currentPage + 1);
    }
  }

  // ⭐ NEW: Previous page
  Future<void> previousPage(OrderStatus status) async {
    final currentPage = _currentPageByStatus[status] ?? 1;

    if (currentPage > 1) {
      await goToPage(status, currentPage - 1);
    }
  }

  // ⭐ NEW: First page
  Future<void> firstPage(OrderStatus status) async {
    await goToPage(status, 1);
  }

  // ⭐ NEW: Last page
  Future<void> lastPage(OrderStatus status) async {
    final totalPages = _totalPagesByStatus[status] ?? 1;
    await goToPage(status, totalPages);
  }

  // ⭐ NEW: Check if has next page
  bool hasNextPage(OrderStatus status) {
    final currentPage = _currentPageByStatus[status] ?? 1;
    final totalPages = _totalPagesByStatus[status] ?? 1;
    return currentPage < totalPages;
  }

  // ⭐ NEW: Check if has previous page
  bool hasPreviousPage(OrderStatus status) {
    final currentPage = _currentPageByStatus[status] ?? 1;
    return currentPage > 1;
  }

  // ⭐ UPDATED: Refresh orders
  Future<void> refreshOrders(
      OrderStatus status, {
        String? searchKey,
        DateTime? fromDate,
        DateTime? toDate,
      }) async {
    if (!activeStatuses.contains(status)) return;

    try {
      _loadingByStatus[status] = true;
      _errorByStatus[status] = null;
      _isSearching = searchKey != null && searchKey.isNotEmpty;
      notifyListeners();

      print('🔄 Refreshing ${status.shortName}...');

      await _loadPageForStatus(
        status: status,
        pageNumber: 1, // Reset to page 1 on refresh
        searchKey: searchKey,
        fromDate: _formatDateForApi(fromDate ?? _fromDate),
        toDate: _formatDateForApi(toDate ?? _toDate),
      );

      notifyListeners();

    } catch (e) {
      print('❌ Refresh Error: $e');
      _loadingByStatus[status] = false;
      _errorByStatus[status] = e.toString();
      notifyListeners();
    }
  }

  // ⭐ Search orders
  Future<void> searchOrders(String searchKey) async {
    if (searchKey.trim().isEmpty) {
      clearSearch();
      await loadInitialData();
      return;
    }

    setSearchQuery(searchKey);
    await loadInitialData(searchKey: searchKey);
  }

  // ⭐ Refresh all tabs
  Future<void> refreshAllTabs() async {
    _initialDataLoaded = false;
    await loadInitialData(
      searchKey: _isSearching ? _searchQuery : null,
      fromDate: _fromDate,
      toDate: _toDate,
    );
  }

  // ⭐ Apply date filter
  Future<void> applyDateFilter(DateTime? fromDate, DateTime? toDate) async {
    setDateFilter(fromDate, toDate);
    _initialDataLoaded = false;
    await loadInitialData(
      searchKey: _isSearching ? _searchQuery : null,
      fromDate: fromDate,
      toDate: toDate,
    );
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

  // ⭐ NEW: Get current page
  int getCurrentPage(OrderStatus status) {
    return _currentPageByStatus[status] ?? 1;
  }

  // ⭐ NEW: Get total pages
  int getTotalPages(OrderStatus status) {
    return _totalPagesByStatus[status] ?? 1;
  }

  // ⭐ NEW: Check if pagination is loading
  bool isPaginationLoading(OrderStatus status) {
    return _isPaginationLoadingByStatus[status] ?? false;
  }

  @override
  void dispose() {
    super.dispose();
  }
}