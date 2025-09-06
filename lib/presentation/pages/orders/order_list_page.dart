import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/data/models/order/order_model.dart';
import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';
import 'package:nalogistics_app/presentation/widgets/cards/order_card.dart';
import 'package:nalogistics_app/presentation/widgets/common/app_bar_widget.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> with SingleTickerProviderStateMixin {
  List<OrderModel> orders = [];
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadOrders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    orders = [
      OrderModel(
        orderID: 'ORD001',
        customerName: 'Nguyễn Văn A',
        orderDate: DateTime.now().subtract(const Duration(hours: 2)),
        totalCost: 250000,
        status: OrderStatus.inProgress,
        customerPhone: '0901234567',
        customerAddress: '123 Đường ABC, Quận 1, TP.HCM',
        notes: 'Giao hàng trước 17h, gọi trước khi đến 15 phút',
      ),
      OrderModel(
        orderID: 'ORD002',
        customerName: 'Trần Thị B',
        orderDate: DateTime.now().subtract(const Duration(hours: 4)),
        totalCost: 180000,
        status: OrderStatus.pickedUp,
        customerPhone: '0912345678',
        customerAddress: '456 Đường DEF, Quận 2, TP.HCM',
      ),
      OrderModel(
        orderID: 'ORD003',
        customerName: 'Lê Văn C',
        orderDate: DateTime.now().subtract(const Duration(hours: 6)),
        totalCost: 320000,
        status: OrderStatus.inProgress,
        customerPhone: '0923456789',
        customerAddress: '789 Đường GHI, Quận 3, TP.HCM',
      ),
    ];

    setState(() => isLoading = false);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBarWidget(
        title: AppStrings.orderList,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadOrders,
          ),
        ],
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
          : RefreshIndicator(
        onRefresh: _loadOrders,
        color: AppColors.maritimeBlue,
        child: orders.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: AppColors.secondaryText,
              ),
              SizedBox(height: 16),
              Text(
                AppStrings.noData,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final animationValue = Curves.easeOutCubic.transform(
                  (_animationController.value - (index * 0.1)).clamp(0.0, 1.0),
                );
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: OrderCard(
                      order: orders[index],
                      onTap: () {
                        context.push('/order-detail/${orders[index].orderID}');
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}