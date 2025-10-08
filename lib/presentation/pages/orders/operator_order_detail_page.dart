import 'package:flutter/material.dart';
import 'package:nalogistics_app/presentation/widgets/dialogs/driver_selection_dialog.dart';
import 'package:nalogistics_app/presentation/widgets/dialogs/rmooc_selection_dialog.dart';
import 'package:nalogistics_app/presentation/widgets/dialogs/truck_selection_dialog.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/utils/date_formatter.dart';
import 'package:nalogistics_app/core/utils/money_formatter.dart';
import 'package:nalogistics_app/data/models/order/operator_order_detail_model.dart';
import 'package:nalogistics_app/presentation/controllers/operator_order_detail_controller.dart';
import 'package:nalogistics_app/presentation/widgets/common/app_bar_widget.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';
import 'package:nalogistics_app/presentation/widgets/order/add_images_section.dart';

class OperatorOrderDetailPage extends StatefulWidget {
  final String orderID;

  const OperatorOrderDetailPage({super.key, required this.orderID});

  @override
  State<OperatorOrderDetailPage> createState() => _OperatorOrderDetailPageState();
}

class _OperatorOrderDetailPageState extends State<OperatorOrderDetailPage> {
  late OperatorOrderDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<OperatorOrderDetailController>(context, listen: false);
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    await _controller.loadOrderDetail(widget.orderID);
  }

  // XỬ LÝ XÁC NHẬN ĐƠN HÀNG PENDING
  Future<void> _handleConfirmOrder() async {
    final order = _controller.orderDetail;
    if (order == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildConfirmDialog(order),
    );

    if (confirmed != true) return;

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
                'Đang xác nhận đơn hàng...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );

    // Call API to confirm order
    final success = await _controller.confirmPendingOrder();

    if (!mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Xác nhận thành công!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đơn hàng ${widget.orderID} đã chuyển sang trạng thái "Đang xử lý"',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.statusDelivered,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
          padding: const EdgeInsets.all(16),
        ),
      );

      // Reload order detail to show updated status with delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Reload with error handling
      try {
        await _controller.reloadOrderDetail();
      } catch (e) {
        print('⚠️ Error reloading order detail: $e');
        // If reload fails, try one more time
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          await _controller.reloadOrderDetail();
        }
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _controller.errorMessage ?? 'Không thể xác nhận đơn hàng. Vui lòng thử lại.',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.statusError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Thử lại',
            textColor: Colors.white,
            onPressed: _handleConfirmOrder,
          ),
        ),
      );
    }
  }

  // Dialog xác nhận
  Widget _buildConfirmDialog(OperatorOrderDetailModel order) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.statusInTransit.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.statusInTransit,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Xác nhận đơn hàng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bạn có chắc muốn xác nhận đơn hàng này?',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sectionBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.maritimeBlue.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                _buildDialogInfoRow(
                  icon: Icons.badge,
                  label: 'Mã đơn',
                  value: '${widget.orderID}',
                ),
                const SizedBox(height: 12),
                _buildDialogInfoRow(
                  icon: Icons.person,
                  label: 'Khách hàng',
                  value: order.customerName,
                ),
                const SizedBox(height: 12),
                _buildDialogInfoRow(
                  icon: Icons.local_shipping,
                  label: 'Tài xế',
                  value: order.driverName.isNotEmpty ? order.driverName : 'Chưa phân công',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.statusInTransit.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.statusInTransit.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.statusInTransit,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đơn hàng sẽ chuyển sang trạng thái "Đang xử lý"',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.statusInTransit,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Hủy',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.maritimeBlue,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Xác nhận',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondaryText),
        const SizedBox(width: 8),
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: const AppBarWidget(title: 'Chi tiết đơn hàng'),
      body: Consumer<OperatorOrderDetailController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.maritimeBlue),
            );
          }

          if (controller.hasError) {
            return _buildErrorView();
          }

          final order = controller.orderDetail;
          if (order == null) {
            return const Center(child: Text('Không tìm thấy đơn hàng'));
          }

          return _buildDetailView(order);
        },
      ),
      // ⭐ FLOATING ACTION BUTTON CHO PENDING ORDER
      floatingActionButton: Consumer<OperatorOrderDetailController>(
        builder: (context, controller, child) {
          final order = controller.orderDetail;

          // Chỉ hiện nút khi order có status Pending
          if (order?.orderStatus == OrderStatus.pending &&
              !controller.isConfirming) {
            return FloatingActionButton.extended(
              onPressed: _handleConfirmOrder,
              backgroundColor: AppColors.statusInTransit,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                'Xác nhận đơn hàng',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorView() {
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
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _controller.errorMessage ?? 'Không xác định',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Quay lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _loadOrderDetail,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maritimeBlue,
                  ),
                ),
              ],
            ),

            // Debug info (only in debug mode)
            if (_isDebugMode()) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DEBUG INFO:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order ID: ${widget.orderID}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      'Error: ${_controller.errorMessage ?? "null"}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Check if running in debug mode
  bool _isDebugMode() {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    return isDebug;
  }

  Widget _buildDetailView(OperatorOrderDetailModel order) {
    return RefreshIndicator(
      onRefresh: _loadOrderDetail,
      color: AppColors.maritimeBlue,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(order),
            const SizedBox(height: 16),

            if (order.orderStatus == OrderStatus.pending)
              _buildPendingWarning(),

            if (order.orderStatus == OrderStatus.pending)
              const SizedBox(height: 16),

            _buildCustomerCard(order),
            const SizedBox(height: 16),
            _buildDriverCard(order),
            const SizedBox(height: 16),
            _buildVehicleCard(order),
            const SizedBox(height: 16),
            _buildLocationCard(order),
            // const SizedBox(height: 16),
            // _buildOrderLinesCard(order),

            // ⭐ THÊM SECTION MỚI - Add Images Section
            const SizedBox(height: 16),
            const AddImagesSection(), // Widget mới

            // Existing images
            if (order.orderImageList.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildImagesCard(order),
            ],

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  // ⭐ PENDING WARNING BANNER
  Widget _buildPendingWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.deepOrange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.pending_actions,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đơn hàng chờ xử lý',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nhấn nút "Xác nhận đơn hàng" bên dưới để chuyển sang trạng thái "Đang xử lý"',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(OperatorOrderDetailModel order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.elevatedShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MÃ ĐƠN HÀNG',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.orderID}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: order.orderStatus.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: order.orderStatus.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.orderStatus.displayName,
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

          // ⭐ THÊM THÔNG TIN NGÀY ĐẶT VÀ BILL BOOKING
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white.withOpacity(0.9),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'NGÀY GIAO HÀNG',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormatter.formatDate(order.orderDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                if (order.billBookingNo.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Colors.white.withOpacity(0.9),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'SỐ BILL/BOOKING',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      order.billBookingNo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(OperatorOrderDetailModel order) {
    return _buildInfoCard(
      title: 'Thông tin khách hàng',
      icon: Icons.business,
      color: AppColors.maritimeBlue,
      children: [
        _buildInfoRow(
          icon: Icons.business,
          label: 'Tên khách hàng',
          value: order.customerName,
        ),
        // const SizedBox(height: 12),
        // _buildInfoRow(
        //   icon: Icons.badge,
        //   label: 'Mã khách hàng',
        //   value: '${order.customerId}',
        // ),
      ],
    );
  }

  Widget _buildDriverCard(OperatorOrderDetailModel order) {
    final hasDriver = order.driverId != null && order.driverName.isNotEmpty;

    return _buildInfoCard(
      title: 'Thông tin tài xế',
      icon: Icons.person,
      color: AppColors.oceanTeal,
      children: [
        if (hasDriver) ...[
          // Có tài xế - hiển thị thông tin
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.oceanTeal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.oceanTeal.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.oceanTeal,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      order.driverName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Driver info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.driverName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (order.driverId != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 14,
                              color: AppColors.secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ID: ${order.driverId}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Change driver button
                IconButton(
                  onPressed: () => _showDriverSelectionDialog(context),
                  icon: const Icon(Icons.edit),
                  color: AppColors.oceanTeal,
                  tooltip: 'Thay đổi tài xế',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.oceanTeal.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Chưa có tài xế - hiển thị nút chọn
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.sectionBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.hintText.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 48,
                  color: AppColors.hintText.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Chưa phân công tài xế',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nhấn nút bên dưới để chọn tài xế cho đơn hàng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDriverSelectionDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.oceanTeal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Chọn tài xế',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Thêm method mới để show dialog chọn driver
  void _showDriverSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DriverSelectionDialog(),
    );
  }

  // Thêm method mới để show dialog chọn truck
  void _showTruckSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TruckSelectionDialog(),
    );
  }

  // Thêm method mới để show dialog chọn rmooc
  void _showRmoocSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RmoocSelectionDialog(),
    );
  }

  Widget _buildVehicleCard(OperatorOrderDetailModel order) {
    final hasTruck = order.truckId != null && order.truckNo.isNotEmpty;
    final hasRmooc = order.rmoocId != null && order.rmoocNo.isNotEmpty;

    return _buildInfoCard(
      title: 'Thông tin phương tiện',
      icon: Icons.local_shipping,
      color: AppColors.containerOrange,
      children: [
        if (hasTruck) ...[
          // Có xe - hiển thị thông tin
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.containerOrange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.containerOrange.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                // Truck info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.truckNo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (order.truckId != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              size: 14,
                              color: AppColors.secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Biển số xe',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Change truck button
                IconButton(
                  onPressed: () => _showTruckSelectionDialog(context),
                  icon: const Icon(Icons.edit),
                  color: AppColors.containerOrange,
                  tooltip: 'Thay đổi xe',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.containerOrange.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Chưa có truck - hiển thị nút chọn
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.sectionBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.hintText.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 48,
                  color: AppColors.hintText.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Chưa chọn xe',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nhấn nút bên dưới để chọn xe cho đơn hàng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDriverSelectionDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.containerOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.local_shipping_sharp,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Chọn xe',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        // Nếu có Rmooc
        if (hasRmooc) ...[
          // Có rmooc - hiển thị thông tin
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.containerOrange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.containerOrange.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                // Rmooc info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.rmoocNo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (order.rmoocId != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.rv_hookup,
                              size: 14,
                              color: AppColors.secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Biển số Rơ-mooc',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Change truck button
                IconButton(
                  onPressed: () => _showRmoocSelectionDialog(context),
                  icon: const Icon(Icons.edit),
                  color: AppColors.containerOrange,
                  tooltip: 'Thay đổi Rơ-mooc',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.containerOrange.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Chưa có rmooc - hiển thị nút chọn
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.sectionBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.hintText.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rv_hookup_outlined,
                  size: 48,
                  color: AppColors.hintText.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Chưa chọn Rơ-mooc',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nhấn nút bên dưới để chọn Rơ-mooc cho đơn hàng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showRmoocSelectionDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.containerOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.rv_hookup_sharp,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Chọn Rơ-mooc',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Widget _buildVehicleCard(OperatorOrderDetailModel order) {
  //   return _buildInfoCard(
  //     title: 'Thông tin phương tiện',
  //     icon: Icons.local_shipping,
  //     color: AppColors.containerOrange,
  //     children: [
  //       _buildVehicleInfo(
  //         icon: Icons.local_shipping,
  //         label: 'Biển số xe',
  //         value: order.truckNo,
  //         // id: order.truckId.toString(),
  //       ),
  //       const SizedBox(height: 12),
  //       _buildVehicleInfo(
  //         icon: Icons.rv_hookup,
  //         label: 'Rơ moóc',
  //         value: order.rmoocNo,
  //         // id: order.rmoocId.toString(),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildLocationCard(OperatorOrderDetailModel order) {
    return _buildInfoCard(
      title: 'Thông tin vận chuyển',
      icon: Icons.location_on,
      color: AppColors.statusInTransit,
      children: [
        _buildLocationItem(
          icon: Icons.upload,
          label: 'ĐIỂM LẤY HÀNG',
          location: order.fromLocationName,
          detail: order.fromWhereName,
          color: AppColors.statusInTransit,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_downward, color: AppColors.maritimeBlue),
            ],
          ),
        ),
        _buildLocationItem(
          icon: Icons.download,
          label: 'ĐIỂM GIAO HÀNG',
          location: order.toLocationName,
          color: AppColors.statusDelivered,
        ),
      ],
    );
  }

  Widget _buildOrderLinesCard(OperatorOrderDetailModel order) {
    final lines = order.orderLineList1;
    final totalCost = order.totalCost;

    return _buildInfoCard(
      title: 'Chi phí đơn hàng',
      icon: Icons.receipt,
      color: AppColors.skyBlue,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lines.length,
          separatorBuilder: (_, __) => Divider(
            height: 24,
            color: AppColors.hintText.withOpacity(0.2),
          ),
          itemBuilder: (context, index) {
            final line = lines[index];
            return _buildOrderLineItem(line);
          },
        ),
        Divider(
          height: 32,
          thickness: 2,
          color: AppColors.maritimeBlue.withOpacity(0.2),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TỔNG CỘNG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              MoneyFormatter.formatSimple(totalCost),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.maritimeBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagesCard(OperatorOrderDetailModel order) {
    final images = order.activeImages;

    return _buildInfoCard(
      title: 'Hình ảnh đã tải lên', // ⭐ Changed title
      icon: Icons.photo_library,  // ⭐ Changed icon
      color: AppColors.portGrey,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final image = images[index];
            return _buildImageItem(image);
          },
        ),
      ],
    );
  }

  // Helper widgets
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
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

  Widget _buildVehicleInfo({
    required IconData icon,
    required String label,
    required String value,
    String? type,
    String? id,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.containerOrange.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.containerOrange),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          if (type != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.containerOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Loại: $type',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.containerOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (id != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.containerOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ID: $id',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.containerOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String label,
    required String location,
    String? detail,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
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
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            location,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Text(
              detail,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderLineItem(OrderLineModel line) {
    final isActive = line.isActive;
    final hasInvoice = line.hasInvoice;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.skyBlue.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(color: AppColors.skyBlue.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.orderLineItem.itemName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: AppColors.primaryText,
                      ),
                    ),
                    if (line.itemDescription.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        line.itemDescription,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    MoneyFormatter.formatSimple(line.actualCost),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.skyBlue : AppColors.primaryText,
                    ),
                  ),
                  if (line.itemCost > 0 &&
                      line.itemCost != line.orderLineItem.fixedPrice) ...[
                    const SizedBox(height: 2),
                    Text(
                      MoneyFormatter.formatSimple(line.orderLineItem.fixedPrice),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.hintText,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (hasInvoice) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusDelivered.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt,
                    size: 12,
                    color: AppColors.statusDelivered,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hóa đơn: ${line.invoiceNo}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.statusDelivered,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageItem(OrderImageModel image) {
    return GestureDetector(
      onTap: () => _showImageDialog(image),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.sectionBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.hintText.withOpacity(0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: image.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: AppColors.statusError,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    image.descrip,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDialog(OrderImageModel image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: CachedNetworkImage(
                  imageUrl: image.url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    image.descrip,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormatter.formatDateTime(image.created),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}