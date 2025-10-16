import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nalogistics_app/core/utils/date_formatter.dart';
import 'package:nalogistics_app/presentation/widgets/dialogs/date_filter_dialog.dart';
import 'package:nalogistics_app/presentation/widgets/common/pagination_bar.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/presentation/controllers/order_controller.dart';
import 'package:nalogistics_app/presentation/controllers/auth_controller.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';
import 'package:nalogistics_app/shared/enums/user_role_enum.dart';
import 'package:nalogistics_app/presentation/widgets/cards/order_status_card.dart';
import 'package:nalogistics_app/presentation/widgets/cards/operator_order_card.dart';

class OrderListWithTabsPage extends StatefulWidget {
  const OrderListWithTabsPage({super.key});

  @override
  State<OrderListWithTabsPage> createState() => _OrderListWithTabsPageState();
}

class _OrderListWithTabsPageState extends State<OrderListWithTabsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderController _orderController;
  late AuthController _authController;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearchBarVisible = false;

  @override
  void initState() {
    super.initState();

    _authController = Provider.of<AuthController>(context, listen: false);
    _orderController = Provider.of<OrderController>(context, listen: false);

    final tabCount = _authController.userRole.isOperator ? 5 : 4;
    _tabController = TabController(length: tabCount, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orderController.setUserRole(_authController.userRole);
      _loadAllTabsData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllTabsData() async {
    print('📱 Loading all tabs for role: ${_authController.userRole.displayName}');
    await _orderController.loadInitialData();
  }

  void _handleSearch(String query) {
    _orderController.searchOrders(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _orderController.clearSearch();
    _orderController.refreshAllTabs();
    setState(() {
      _isSearchBarVisible = false;
    });
  }

  void _toggleSearchBar() {
    setState(() {
      _isSearchBarVisible = !_isSearchBarVisible;
      if (!_isSearchBarVisible) {
        _clearSearch();
      }
    });
  }

  Future<void> _showDateFilterDialog() async {
    final result = await showDialog<Map<String, DateTime?>>(
      context: context,
      builder: (context) => DateFilterDialog(
        initialFromDate: _orderController.fromDate,
        initialToDate: _orderController.toDate,
      ),
    );

    if (result != null) {
      final fromDate = result['fromDate'];
      final toDate = result['toDate'];
      await _orderController.applyDateFilter(fromDate, toDate);
    }
  }

  void _clearAllFilters() {
    _searchController.clear();
    _orderController.clearSearch();
    _orderController.clearDateFilter();
    setState(() {
      _isSearchBarVisible = false;
    });
    _orderController.refreshAllTabs();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthController, OrderController>(
      builder: (context, authController, orderController, child) {
        final userRole = authController.userRole;
        final activeStatuses = orderController.activeStatuses;

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            title: _isSearchBarVisible
                ? _buildSearchField()
                : Row(
              children: [
                const Text(
                  'Danh sách đơn hàng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(userRole.colorValue).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userRole.displayName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.maritimeBlue,
            elevation: 0,
            actions: [
              if (userRole.isOperator) ...[
                Consumer<OrderController>(
                  builder: (context, controller, child) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: _showDateFilterDialog,
                          tooltip: 'Lọc theo ngày',
                        ),
                        if (controller.hasDateFilter)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
              IconButton(
                icon: Icon(_isSearchBarVisible ? Icons.close : Icons.search),
                onPressed: _toggleSearchBar,
                tooltip: _isSearchBarVisible ? 'Đóng tìm kiếm' : 'Tìm kiếm',
              ),
              Consumer<OrderController>(
                builder: (context, controller, child) {
                  return IconButton(
                    icon: controller.isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.refresh),
                    onPressed: controller.isLoading
                        ? null
                        : () => controller.refreshAllTabs(),
                    tooltip: 'Làm mới tất cả',
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
              tabs: activeStatuses.map((status) {
                return Tab(
                  child: Consumer<OrderController>(
                    builder: (context, controller, child) {
                      final count = controller.getOrdersCount(status);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (status == OrderStatus.pending) ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                status.shortName,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                            ],
                          ),
                          if (count > 0) ...[
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                  color: AppColors.maritimeBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          body: Column(
            children: [
              Consumer<OrderController>(
                builder: (context, controller, child) {
                  final hasFilters = controller.isSearching || controller.hasDateFilter;

                  if (!hasFilters) return const SizedBox.shrink();

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: AppColors.statusInTransit.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.filter_alt,
                              size: 18,
                              color: AppColors.statusInTransit,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Bộ lọc đang áp dụng:',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.statusInTransit,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _clearAllFilters,
                              icon: const Icon(
                                Icons.clear_all,
                                size: 16,
                              ),
                              label: const Text('Xóa tất cả'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.statusError,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (controller.isSearching)
                              _buildFilterChip(
                                icon: Icons.search,
                                label: 'Tìm kiếm: "${controller.searchQuery}"',
                                onRemove: () {
                                  _searchController.clear();
                                  controller.clearSearch();
                                  controller.refreshAllTabs();
                                },
                              ),
                            if (controller.hasDateFilter)
                              _buildFilterChip(
                                icon: Icons.calendar_month,
                                label: _getDateFilterLabel(controller),
                                onRemove: () {
                                  controller.clearDateFilter();
                                  controller.refreshAllTabs();
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: activeStatuses.map((status) {
                    return _buildOrderList(status, userRole);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Tìm theo mã đơn hàng...',
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
        border: InputBorder.none,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, color: AppColors.maritimeDarkBlue),
          onPressed: () {
            _searchController.clear();
            _orderController.refreshAllTabs();
            _handleSearch('');
          },
        )
            : null,
      ),
      onChanged: (value) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (value == _searchController.text) {
            _handleSearch(value);
          }
        });
      },
      onSubmitted: _handleSearch,
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.maritimeBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.maritimeBlue.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.maritimeBlue,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.maritimeBlue,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(2),
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.maritimeBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateFilterLabel(OrderController controller) {
    final fromDate = controller.fromDate;
    final toDate = controller.toDate;

    if (fromDate != null && toDate != null) {
      if (fromDate.year == toDate.year &&
          fromDate.month == toDate.month &&
          fromDate.day == toDate.day) {
        return 'Ngày: ${DateFormatter.formatDate(fromDate)}';
      }
      return '${DateFormatter.formatDate(fromDate)} - ${DateFormatter.formatDate(toDate)}';
    } else if (fromDate != null) {
      return 'Từ: ${DateFormatter.formatDate(fromDate)}';
    } else if (toDate != null) {
      return 'Đến: ${DateFormatter.formatDate(toDate)}';
    }
    return 'Lọc theo ngày';
  }

  Widget _buildOrderList(OrderStatus status, UserRole userRole) {
    return Consumer<OrderController>(
      builder: (context, orderController, child) {
        final orders = orderController.getOrders(status);
        final isLoading = orderController.isLoadingForStatus(status);
        final hasError = orderController.hasErrorForStatus(status);
        final error = orderController.getError(status);

        // ⭐ Pagination state
        final currentPage = orderController.getCurrentPage(status);
        final totalPages = orderController.getTotalPages(status);
        final isPaginationLoading = orderController.isPaginationLoading(status);

        if (isLoading && orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.maritimeBlue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Đang tải ${status.displayName.toLowerCase()}...',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (hasError && orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.statusError,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Có lỗi xảy ra',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error ?? 'Không thể tải danh sách đơn hàng',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => orderController.refreshOrders(status),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maritimeBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmptyIcon(status),
                  size: 64,
                  color: AppColors.hintText,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có đơn hàng ${status.displayName.toLowerCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptyMessage(status),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.hintText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => orderController.refreshOrders(status),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.maritimeBlue,
                  ),
                ),
              ],
            ),
          );
        }

        // ⭐ Column with ListView + Pagination
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => orderController.refreshOrders(status),
                color: AppColors.maritimeBlue,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    if (userRole.isOperator) {
                      return OperatorOrderCard(
                        order: order,
                        onTap: () {
                          context.push('/operator-order-detail/${order.orderID}');
                        },
                      );
                    } else {
                      return OrderStatusCard(
                        order: order,
                        onTap: () {
                          context.push('/order-detail/${order.orderID}');
                        },
                      );
                    }
                  },
                ),
              ),
            ),

            // ⭐ Pagination bar
            CompactPaginationBar(
              currentPage: currentPage,
              totalPages: totalPages,
              isLoading: isPaginationLoading,
              onPreviousPage: orderController.hasPreviousPage(status)
                  ? () => orderController.previousPage(status)
                  : null,
              onNextPage: orderController.hasNextPage(status)
                  ? () => orderController.nextPage(status)
                  : null,
            ),
          ],
        );
      },
    );
  }

  IconData _getEmptyIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_actions;
      case OrderStatus.inProgress:
        return Icons.hourglass_empty;
      case OrderStatus.pickedUp:
        return Icons.inventory_2_outlined;
      case OrderStatus.inTransit:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      default:
        return Icons.inbox_outlined;
    }
  }

  String _getEmptyMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Không có đơn hàng chờ xử lý';
      case OrderStatus.inProgress:
        return 'Tất cả đơn hàng đều đã được xử lý';
      case OrderStatus.pickedUp:
        return 'Chưa có đơn hàng nào được lấy';
      case OrderStatus.inTransit:
        return 'Không có đơn hàng đang vận chuyển';
      case OrderStatus.delivered:
        return 'Chưa có đơn hàng nào được giao';
      default:
        return 'Không có dữ liệu';
    }
  }
}