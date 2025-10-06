import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    super.dispose();
  }

  Future<void> _loadAllTabsData() async {
    print('📱 Loading all tabs for role: ${_authController.userRole.displayName}');
    await _orderController.loadInitialData();
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
            title: Row(
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
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(userRole.colorValue).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userRole.displayName,
                    style: const TextStyle(
                      fontSize: 11,
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
          body: TabBarView(
            controller: _tabController,
            children: activeStatuses.map((status) {
              return _buildOrderList(status, userRole);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildOrderList(OrderStatus status, UserRole userRole) {
    return Consumer<OrderController>(
      builder: (context, orderController, child) {
        final orders = orderController.getOrders(status);
        final isLoading = orderController.isLoadingForStatus(status);
        final hasError = orderController.hasErrorForStatus(status);
        final error = orderController.getError(status);

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
                const SizedBox(height: 8),
                Text(
                  userRole.isOperator ? '(Operator Mode)' : '(Driver Mode)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(userRole.colorValue),
                    fontWeight: FontWeight.w600,
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

        return RefreshIndicator(
          onRefresh: () => orderController.refreshOrders(status),
          color: AppColors.maritimeBlue,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length + (orderController.hasMore(status) ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= orders.length) {
                if (!isLoading) {
                  orderController.loadMoreOrders(status);
                }
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.maritimeBlue,
                    ),
                  ),
                );
              }

              final order = orders[index];

              // ⭐ KEY CHANGE: Route khác nhau theo role
              if (userRole.isOperator) {
                return OperatorOrderCard(
                  order: order,
                  onTap: () {
                    // ⭐ Operator dùng route riêng
                    context.push('/operator-order-detail/${order.orderID}');
                  },
                );
              } else {
                return OrderStatusCard(
                  order: order,
                  onTap: () {
                    // ⭐ Driver dùng route cũ
                    context.push('/order-detail/${order.orderID}');
                  },
                );
              }
            },
          ),
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