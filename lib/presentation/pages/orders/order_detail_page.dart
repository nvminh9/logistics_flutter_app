import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/utils/date_formatter.dart';
import 'package:nalogistics_app/core/utils/money_formatter.dart';
import 'package:nalogistics_app/data/models/order/order_model.dart';
import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';
import 'package:nalogistics_app/presentation/widgets/common/custom_button.dart';
import 'package:nalogistics_app/presentation/widgets/common/modern_app_bar.dart';
import 'package:nalogistics_app/presentation/widgets/common/app_bar_widget.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderID;

  const OrderDetailPage({super.key, required this.orderID});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> with TickerProviderStateMixin {
  OrderModel? order;
  bool isLoading = true;
  bool isConfirming = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadOrderDetail();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadOrderDetail() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    order = OrderModel(
      orderID: widget.orderID,
      customerName: 'Nguyễn Văn A',
      orderDate: DateTime.now().subtract(const Duration(hours: 2)),
      totalCost: 250000,
      status: OrderStatus.inProgress,
      customerPhone: '0901234567',
      customerAddress: '123 Đường ABC, Phường Bến Nghé, Quận 1, TP.HCM',
      notes: 'Giao hàng trước 17h, gọi trước khi đến 15 phút',
    );

    setState(() => isLoading = false);
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _confirmOrder() async {
    setState(() => isConfirming = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      order = OrderModel(
        orderID: order!.orderID,
        customerName: order!.customerName,
        orderDate: order!.orderDate,
        totalCost: order!.totalCost,
        status: OrderStatus.pickedUp,
        customerPhone: order!.customerPhone,
        customerAddress: order!.customerAddress,
        notes: order!.notes,
      );
      isConfirming = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text(AppStrings.orderConfirmed),
          ],
        ),
        backgroundColor: AppColors.statusDelivered,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: const AppBarWidget(title: AppStrings.orderDetail),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Đang tải chi tiết đơn hàng...',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (order == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: const AppBarWidget(title: AppStrings.orderDetail),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: AppColors.statusError,
              ),
              SizedBox(height: 16),
              Text(
                AppStrings.error,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.statusError,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: const AppBarWidget(
        title: AppStrings.orderDetail,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(),
                const SizedBox(height: 10),
                _buildOrderInfoCard(),
                const SizedBox(height: 10),
                _buildCustomerCard(),
                const SizedBox(height: 10),
                if (order!.notes?.isNotEmpty == true) ...[
                  _buildNotesCard(),
                  const SizedBox(height: 10),
                ],
                _buildTimelineCard(),
                const SizedBox(height: 20),
                if (order!.status == OrderStatus.inProgress)
                  _buildConfirmButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        // gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.maritimeLightBlue.withOpacity(0.1),
            blurRadius: 60,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mã đơn hàng',
                style: TextStyle(
                  color: AppColors.hintText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _getStatusColor(order!.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order!.status.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order!.orderID,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                MoneyFormatter.formatSimple(order!.totalCost),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black26,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: AppStrings.orderDate,
            value: DateFormatter.formatDateTime(order!.orderDate),
            color: AppColors.primaryText,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.payments_rounded,
            label: AppStrings.totalCost,
            value: MoneyFormatter.formatSimple(order!.totalCost),
            color: AppColors.primaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black26,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin khách hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.person_rounded,
            label: AppStrings.customerName,
            value: order!.customerName,
            color: AppColors.primaryText,
          ),
          if (order!.customerPhone?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.phone_rounded,
              label: AppStrings.phoneNumber,
              value: order!.customerPhone!,
              color: AppColors.primaryText,
              isClickable: true,
            ),
          ],
          if (order!.customerAddress?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.location_on_rounded,
              label: 'Địa chỉ giao hàng',
              value: order!.customerAddress!,
              color: AppColors.primaryText,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black26,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Ghi chú đặc biệt',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.hintText.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondaryText.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              order!.notes!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primaryText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black26,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trạng thái đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            icon: Icons.add_circle_rounded,
            title: 'Đơn hàng được tạo',
            time: DateFormatter.formatDateTime(order!.orderDate),
            isCompleted: true,
          ),
          _buildTimelineItem(
            icon: Icons.check_circle_rounded,
            title: 'Đã xác nhận',
            time: order!.status.index >= OrderStatus.pickedUp.index
                ? 'Đã hoàn thành'
                : 'Chờ xác nhận',
            isCompleted: order!.status.index >= OrderStatus.pickedUp.index,
          ),
          _buildTimelineItem(
            icon: Icons.local_shipping_rounded,
            title: 'Đang giao hàng',
            time: 'Chưa bắt đầu',
            isCompleted: order!.status.index >= OrderStatus.inProgress.index,
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.done_all_rounded,
            title: 'Hoàn thành',
            time: 'Chưa hoàn thành',
            isCompleted: order!.status.index >= OrderStatus.completed.index,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String time,
    required bool isCompleted,
    bool isLast = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.statusDelivered.withOpacity(0.1)
                    : AppColors.secondaryText.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: isCompleted
                    ? AppColors.statusDelivered
                    : AppColors.secondaryText,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isCompleted
                    ? AppColors.statusDelivered.withOpacity(0.3)
                    : AppColors.secondaryText.withOpacity(0.2),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? AppColors.primaryText
                        : AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isClickable = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isClickable ? AppColors.primaryText : AppColors.primaryText,
                  decoration: isClickable ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return CustomButton(
      text: AppStrings.confirmOrder,
      onPressed: _confirmOrder,
      isLoading: isConfirming,
      isFullWidth: true,
      icon: Icons.check_circle_rounded,
      backgroundColor: AppColors.maritimeBlue,
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.inProgress:
        return OrderStatus.inProgress.color;
      case OrderStatus.pickedUp:
        return OrderStatus.pickedUp.color;
      case OrderStatus.inTransit:
        return OrderStatus.inTransit.color;
      case OrderStatus.delivered:
        return OrderStatus.delivered.color;
      case OrderStatus.completed:
        return OrderStatus.completed.color;
      case OrderStatus.cancelled:
        return OrderStatus.cancelled.color;
      case OrderStatus.failedDelivery:
        return OrderStatus.failedDelivery.color;
    }
  }
}