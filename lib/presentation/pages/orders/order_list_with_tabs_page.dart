// lib/presentation/pages/orders/order_list_with_tabs_page.dart (4 TABS VERSION)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/presentation/controllers/order_controller.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';
import 'package:nalogistics_app/presentation/widgets/cards/order_status_card.dart';

class OrderListWithTabsPage extends StatefulWidget {
  const OrderListWithTabsPage({super.key});

  @override
  State<OrderListWithTabsPage> createState() => _OrderListWithTabsPageState();
}

class _OrderListWithTabsPageState extends State<OrderListWithTabsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderController _orderController;

  // ⭐ CHỈ 4 TABS
  static const List<OrderStatus> _tabStatuses = [
    OrderStatus.inProgress,   // Chờ lấy hàng
    OrderStatus.pickedUp,      // Đã lấy hàng
    OrderStatus.inTransit,     // Đang vận chuyển
    OrderStatus.delivered,     // Đã giao
  ];

  @override
  void initState() {
    super.initState();

    // TabController cho 4 tabs
    _tabController = TabController(length: 4, vsync: this);
    _orderController = Provider.of<OrderController>(context, listen: false);

    // ⭐ LOAD DỮ LIỆU CHO TẤT CẢ 4 TABS NGAY KHI VÀO TRANG
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllTabsData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ⭐ LOAD TẤT CẢ 4 TABS CÙNG LÚC
  Future<void> _loadAllTabsData() async {
    print('📱 OrderListWithTabsPage: Loading all 4 tabs...');
    await _orderController.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'Danh sách đơn hàng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.maritimeBlue,
        elevation: 0,
        actions: [
          // Refresh button để reload tất cả tabs
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
          isScrollable: true, // Fixed tabs vì chỉ có 4 tabs
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
          tabs: _tabStatuses.map((status) {
            return Tab(
              child: Consumer<OrderController>(
                builder: (context, controller, child) {
                  final count = controller.getOrdersCount(status);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        status.shortName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        // overflow: TextOverflow.ellipsis,
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
        children: _tabStatuses.map((status) {
          return _buildOrderList(status);
        }).toList(),
      ),
    );
  }

  Widget _buildOrderList(OrderStatus status) {
    return Consumer<OrderController>(
      builder: (context, controller, child) {
        final orders = controller.getOrders(status);
        final isLoading = controller.isLoadingForStatus(status);
        final hasError = controller.hasErrorForStatus(status);
        final error = controller.getError(status);

        // ⭐ LOADING STATE - Khi đang load initial data
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

        // ⭐ ERROR STATE
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
                    onPressed: () => controller.refreshOrders(status),
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

        // ⭐ EMPTY STATE
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
                  onPressed: () => controller.refreshOrders(status),
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

        // ⭐ LIST VIEW WITH DATA
        return RefreshIndicator(
          onRefresh: () => controller.refreshOrders(status),
          color: AppColors.maritimeBlue,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length + (controller.hasMore(status) ? 1 : 0),
            itemBuilder: (context, index) {
              // Load more indicator
              if (index >= orders.length) {
                if (!isLoading) {
                  controller.loadMoreOrders(status);
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
              return OrderStatusCard(
                order: order,
                onTap: () {
                  context.push('/order-detail/${order.orderID}');
                },
              );
            },
          ),
        );
      },
    );
  }

  IconData _getEmptyIcon(OrderStatus status) {
    switch (status) {
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