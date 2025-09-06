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
    with TickerProviderStateMixin {
  late TabController _tabController;
  late OrderController _orderController;

  final List<OrderStatus> _tabStatuses = [
    OrderStatus.inProgress,
    OrderStatus.pickedUp,
    OrderStatus.inTransit,
    OrderStatus.delivered,
    OrderStatus.completed,
    OrderStatus.cancelled,
    OrderStatus.failedDelivery,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabStatuses.length, vsync: this);
    _orderController = Provider.of<OrderController>(context, listen: false);

    // Load initial data for first tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTabData(0);
    });

    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadTabData(_tabController.index);
    }
  }

  void _loadTabData(int tabIndex) {
    final status = _tabStatuses[tabIndex];
    if (_orderController.getOrders(status).isEmpty &&
        !_orderController.isLoadingForStatus(status)) {
      _orderController.loadOrders(status);
    }
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          tabs: _tabStatuses.map((status) {
            return Tab(
              child: Consumer<OrderController>(
                builder: (context, controller, child) {
                  final count = controller.getOrdersCount(status);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(status.shortName),
                      if (count > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
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

        if (isLoading && orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.maritimeBlue),
                SizedBox(height: 16),
                Text(
                  'Đang tải đơn hàng...',
                  style: TextStyle(
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
                  Text(
                    'Có lỗi xảy ra',
                    style: const TextStyle(
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

        return RefreshIndicator(
          onRefresh: () => controller.refreshOrders(status),
          color: AppColors.maritimeBlue,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length + (controller.hasMore(status) ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= orders.length) {
                // Load more indicator
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
        return Icons.inventory_2;
      case OrderStatus.inTransit:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.completed:
        return Icons.task_alt;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.failedDelivery:
        return Icons.error_outline;
    }
  }
}