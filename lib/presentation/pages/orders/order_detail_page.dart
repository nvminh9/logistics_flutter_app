import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/utils/date_formatter.dart';
import 'package:nalogistics_app/presentation/controllers/order_detail_controller.dart';
import 'package:nalogistics_app/presentation/controllers/order_controller.dart';
import 'package:nalogistics_app/presentation/widgets/common/custom_button.dart';
import 'package:nalogistics_app/presentation/widgets/common/app_bar_widget.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderID;

  const OrderDetailPage({super.key, required this.orderID});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> with TickerProviderStateMixin {
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
    final controller = Provider.of<OrderDetailController>(context, listen: false);
    await controller.loadOrderDetail(widget.orderID);

    if (mounted && controller.orderDetail != null) {
      _fadeController.forward();
      _slideController.forward();
    }
  }

  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    final controller = Provider.of<OrderDetailController>(context, listen: false);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.maritimeBlue,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Xác nhận cập nhật'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc muốn cập nhật trạng thái đơn hàng thành:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: newStatus.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: newStatus.color.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: newStatus.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    newStatus.displayName,
                    style: TextStyle(
                      color: newStatus.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lưu ý: Hành động này không thể hoàn tác.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          CustomButton(
            text: 'Xác nhận',
            onPressed: () => Navigator.of(context).pop(true),
            backgroundColor: AppColors.maritimeBlue,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.maritimeBlue),
                const SizedBox(height: 20),
                const Text(
                  'Đang cập nhật trạng thái...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );

      // Call API to update status
      final success = await controller.updateOrderStatus(newStatus);

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Đã cập nhật trạng thái thành "${newStatus.displayName}"'),
                ),
              ],
            ),
            backgroundColor: AppColors.statusDelivered,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );

        // Reload order detail to get latest data
        await controller.reloadOrderDetail();

        // Also refresh the order list in background
        final orderController = Provider.of<OrderController>(context, listen: false);
        orderController.loadInitialData();

      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(controller.errorMessage ?? 'Cập nhật thất bại'),
                ),
              ],
            ),
            backgroundColor: AppColors.statusError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () => _updateOrderStatus(newStatus),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: const AppBarWidget(
        title: 'Chi tiết đơn hàng',
      ),
      body: Consumer<OrderDetailController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.maritimeBlue),
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
            );
          }

          if (controller.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 80,
                    color: AppColors.statusError,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Có lỗi xảy ra',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.statusError,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Thử lại',
                    onPressed: _loadOrderDetail,
                    backgroundColor: AppColors.maritimeBlue,
                  ),
                ],
              ),
            );
          }

          final order = controller.orderDetail;
          if (order == null) {
            return const Center(
              child: Text('Không tìm thấy thông tin đơn hàng'),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: RefreshIndicator(
                onRefresh: _loadOrderDetail,
                color: AppColors.maritimeBlue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderHeader(order),
                      const SizedBox(height: 16),
                      _buildOrderInfoCard(order),
                      const SizedBox(height: 16),
                      _buildLocationCard(order),
                      const SizedBox(height: 16),
                      _buildVehicleCard(order),
                      const SizedBox(height: 16),
                      _buildTimelineCard(order),
                      const SizedBox(height: 24),
                      _buildActionButtons(order),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.elevatedShadow],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mã đơn hàng',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${order.orderID}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.orderStatus).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.orderStatus),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusDisplayName(order.orderStatus),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.maritimeBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.maritimeBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thông tin khách hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.person,
            label: 'Tên khách hàng',
            value: order.customerName,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Ngày đặt hàng',
            value: DateFormatter.formatDateTime(order.orderDate),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.oceanTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.oceanTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thông tin vận chuyển',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // From location
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sectionBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.statusInTransit.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.statusInTransit,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.upload_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ĐIỂM LẤY HÀNG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.statusInTransit,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  order.fromLocationName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.fromWhereName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_downward,
                  color: AppColors.maritimeBlue,
                  size: 24,
                ),
              ],
            ),
          ),

          // To location
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sectionBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.statusDelivered.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.statusDelivered,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ĐIỂM GIAO HÀNG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.statusDelivered,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  order.toLocationName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.containerOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.containerOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thông tin phương tiện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildVehicleInfo(
                  icon: Icons.inventory_2_outlined,
                  label: 'Container',
                  value: order.containerNo,
                  color: AppColors.skyBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVehicleInfo(
                  icon: Icons.local_shipping,
                  label: 'Xe đầu kéo',
                  value: order.truckNo,
                  color: AppColors.maritimeBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildVehicleInfo(
            icon: Icons.rv_hookup,
            label: 'Rơ moóc',
            value: order.rmoocNo,
            color: AppColors.oceanTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.statusInTransit.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timeline,
                  color: AppColors.statusInTransit,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tiến trình đơn hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            icon: Icons.add_circle_rounded,
            title: 'Đơn hàng được tạo',
            time: DateFormatter.formatDateTime(order.orderDate),
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.inventory_2_rounded,
            title: 'Đã lấy hàng',
            time: order.orderStatus.index >= OrderStatus.pickedUp.index
                ? 'Đã hoàn thành'
                : 'Chờ xử lý',
            isCompleted: order.orderStatus.index >= OrderStatus.pickedUp.index,
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.local_shipping_rounded,
            title: 'Đang vận chuyển',
            time: order.orderStatus.index >= OrderStatus.inTransit.index
                ? 'Đã hoàn thành'
                : 'Chưa bắt đầu',
            isCompleted: order.orderStatus.index >= OrderStatus.inTransit.index,
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.location_on_rounded,
            title: 'Đã giao hàng',
            time: order.orderStatus.index >= OrderStatus.delivered.index
                ? 'Đã hoàn thành'
                : 'Chưa hoàn thành',
            isCompleted: order.orderStatus.index >= OrderStatus.delivered.index,
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.done_all_rounded,
            title: 'Hoàn thành',
            time: order.orderStatus.index >= OrderStatus.completed.index
                ? 'Đã hoàn thành'
                : 'Chưa hoàn thành',
            isCompleted: order.orderStatus.index >= OrderStatus.completed.index,
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
    required bool isLast,
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
                size: 20,
                color: isCompleted
                    ? AppColors.statusDelivered
                    : AppColors.secondaryText,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? AppColors.statusDelivered.withOpacity(0.3)
                    : AppColors.secondaryText.withOpacity(0.2),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? AppColors.primaryText
                        : AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted
                        ? AppColors.statusDelivered
                        : AppColors.hintText,
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
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondaryText),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(dynamic order) {
    // Xác định next status dựa trên current status
    OrderStatus? nextStatus;
    String buttonText = '';
    IconData buttonIcon = Icons.check_circle;

    switch (order.orderStatus) {
      case OrderStatus.inProgress:
        nextStatus = OrderStatus.pickedUp;
        buttonText = 'Xác nhận đã lấy hàng';
        buttonIcon = Icons.inventory_2;
        break;
      case OrderStatus.pickedUp:
        nextStatus = OrderStatus.inTransit;
        buttonText = 'Bắt đầu vận chuyển';
        buttonIcon = Icons.local_shipping;
        break;
      case OrderStatus.inTransit:
        nextStatus = OrderStatus.delivered;
        buttonText = 'Xác nhận đã giao hàng';
        buttonIcon = Icons.location_on;
        break;
      case OrderStatus.delivered:
        nextStatus = OrderStatus.delivered;
        break;
      default:
        nextStatus = null;
    }

    // Nếu đơn hàng đã giao
    if(nextStatus == OrderStatus.delivered){
      return Container();
    }

    if (nextStatus == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.sectionBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              order.orderStatus == OrderStatus.completed
                  ? Icons.check_circle
                  : Icons.cancel,
              color: order.orderStatus == OrderStatus.completed
                  ? AppColors.statusDelivered
                  : AppColors.statusError,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              order.orderStatus == OrderStatus.completed
                  ? 'Đơn hàng đã hoàn thành'
                  : order.orderStatus == OrderStatus.cancelled
                  ? 'Đơn hàng đã bị hủy'
                  : 'Đơn hàng đã kết thúc',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: order.orderStatus == OrderStatus.completed
                    ? AppColors.statusDelivered
                    : AppColors.statusError,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        CustomButton(
          text: buttonText,
          onPressed: () => _updateOrderStatus(nextStatus!),
          isFullWidth: true,
          icon: buttonIcon,
          backgroundColor: AppColors.maritimeBlue,
          height: 56,
        ),
        const SizedBox(height: 12),

        // Cancel button (chỉ hiện khi đơn hàng chưa completed)
        // if (order.orderStatus != OrderStatus.completed &&
        //     order.orderStatus != OrderStatus.cancelled)
        //   OutlinedButton.icon(
        //     onPressed: () => _updateOrderStatus(OrderStatus.cancelled),
        //     icon: const Icon(Icons.cancel_outlined, size: 20),
        //     label: const Text('Hủy đơn hàng'),
        //     style: OutlinedButton.styleFrom(
        //       foregroundColor: AppColors.statusError,
        //       side: const BorderSide(color: AppColors.statusError),
        //       minimumSize: const Size(double.infinity, 48),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    return status.color;
  }

  String _getStatusDisplayName(OrderStatus status) {
    return status.displayName;
  }
}