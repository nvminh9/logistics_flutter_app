import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/data/models/order/order_model.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';
import 'package:nalogistics_app/presentation/widgets/cards/status_order_card.dart';
import 'package:nalogistics_app/presentation/widgets/common/modern_app_bar.dart';

class TabbedOrderListPage extends StatefulWidget {
  const TabbedOrderListPage({super.key});

  @override
  State<TabbedOrderListPage> createState() => _TabbedOrderListPageState();
}

class _TabbedOrderListPageState extends State<TabbedOrderListPage>
    with TickerProviderStateMixin {

  late TabController _tabController;
  bool isLoading = true;
  Map<OrderStatus, List<OrderModel>> _ordersByStatus = {};

  final List<OrderStatus> _statusTabs = [
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
    _tabController = TabController(
      length: _statusTabs.length,
      vsync: this,
    );
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data với đa dạng status
    final allOrders = [
      // InProgress orders
      OrderModel(
        orderID: 'ORD001',
        customerName: 'Nguyễn Văn A',
        orderDate: DateTime.now().subtract(const Duration(hours: 1)),
        totalCost: 250000,
        status: OrderStatus.inProgress,
        customerPhone: '0901234567',
        customerAddress: '123 Đường ABC, Quận 1, TP.HCM',
      ),
      OrderModel(
        orderID: 'ORD008',
        customerName: 'Đặng Thị H',
        orderDate: DateTime.now().subtract(const Duration(hours: 3)),
        totalCost: 180000,
        status: OrderStatus.inProgress,
        customerPhone: '0908888888',
        customerAddress: '789 Đường GHI, Quận 8, TP.HCM',
      ),

      // PickedUp orders
      OrderModel(
        orderID: 'ORD002',
        customerName: 'Trần Thị B',
        orderDate: DateTime.now().subtract(const Duration(hours: 2)),
        totalCost: 320000,
        status: OrderStatus.pickedUp,
        customerPhone: '0912345678',
        customerAddress: '456 Đường DEF, Quận 2, TP.HCM',
      ),

      // InTransit orders
      OrderModel(
        orderID: 'ORD003',
        customerName: 'Lê Văn C',
        orderDate: DateTime.now().subtract(const Duration(hours: 4)),
        totalCost: 150000,
        status: OrderStatus.inTransit,
        customerPhone: '0923456789',
        customerAddress: '789 Đường GHI, Quận 3, TP.HCM',
      ),
      OrderModel(
        orderID: 'ORD009',
        customerName: 'Võ Thị I',
        orderDate: DateTime.now().subtract(const Duration(hours: 5)),
        totalCost: 420000,
        status: OrderStatus.inTransit,
        customerPhone: '0909999999',
        customerAddress: '321 Đường JKL, Quận 9, TP.HCM',
      ),

      // Delivered orders
      OrderModel(
        orderID: 'ORD004',
        customerName: 'Phạm Văn D',
        orderDate: DateTime.now().subtract(const Duration(hours: 6)),
        totalCost: 280000,
        status: OrderStatus.delivered,
        customerPhone: '0934567890',
        customerAddress: '012 Đường MNO, Quận 4, TP.HCM',
      ),

      // Completed orders
      OrderModel(
        orderID: 'ORD005',
        customerName: 'Hoàng Thị E',
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        totalCost: 350000,
        status: OrderStatus.completed,
        customerPhone: '0945678901',
        customerAddress: '345 Đường PQR, Quận 5, TP.HCM',
      ),
      OrderModel(
        orderID: 'ORD010',
        customerName: 'Bùi Văn J',
        orderDate: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        totalCost: 220000,
        status: OrderStatus.completed,
        customerPhone: '0901010101',
        customerAddress: '567 Đường STU, Quận 10, TP.HCM',
      ),

      // Cancelled orders
      OrderModel(
        orderID: 'ORD006',
        customerName: 'Đỗ Văn F',
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        totalCost: 190000,
        status: OrderStatus.cancelled,
        customerPhone: '0956789012',
        customerAddress: '678 Đường VWX, Quận 6, TP.HCM',
      ),

      // Failed Delivery orders
      OrderModel(
        orderID: 'ORD007',
        customerName: 'Ngô Thị G',
        orderDate: DateTime.now().subtract(const Duration(hours: 8)),
        totalCost: 240000,
        status: OrderStatus.failedDelivery,
        customerPhone: '0967890123',
        customerAddress: '901 Đường YZ, Quận 7, TP.HCM',
      ),
    ];

    // Group orders by status
    _ordersByStatus = {};
    for (final status in _statusTabs) {
      _ordersByStatus[status] = allOrders
          .where((order) => order.status == status)
          .toList();
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: ModernAppBar(
        title: AppStrings.orderList,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadOrders,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.maritimeBlue,
              unselectedLabelColor: AppColors.hintText,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              indicator: BoxDecoration(
                color: AppColors.maritimeBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: _statusTabs.map((status) {
                final count = _ordersByStatus[status]?.length ?? 0;
                return Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon(
                        //   status.icon,
                        //   size: 16,
                        // ),
                        // const SizedBox(width: 6),
                        Text(status.shortName),
                        if (count > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              // color: status.color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
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
      )
          : TabBarView(
        controller: _tabController,
        children: _statusTabs.map((status) {
          final orders = _ordersByStatus[status] ?? [];
          return _buildOrderList(status, orders);
        }).toList(),
      ),
    );
  }

  Widget _buildOrderList(OrderStatus status, List<OrderModel> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.maritimeBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return StatusOrderCard(
            order: orders[index],
            onTap: () {
              context.push('/order-detail/${orders[index].orderID}');
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(OrderStatus status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              // color: status.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            // child: Icon(
            //   // status.icon,
            //   size: 40,
            //   // color: status.color.withOpacity(0.6),
            // ),
          ),
          const SizedBox(height: 16),
          Text(
            'Không có đơn hàng ${status.displayName.toLowerCase()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kéo xuống để làm mới',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.hintText,
            ),
          ),
        ],
      ),
    );
  }
}