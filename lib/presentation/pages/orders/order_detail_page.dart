import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/utils/attachment_utils.dart';
import 'package:nalogistics_app/data/models/order/order_detail_api_model.dart';
import 'package:nalogistics_app/data/models/order/order_image_model.dart';
import 'package:nalogistics_app/data/services/media/attachment_picker_service.dart';
import 'package:nalogistics_app/presentation/controllers/auth_controller.dart';
import 'package:nalogistics_app/presentation/controllers/driver_location_tracking_controller.dart';
import 'package:nalogistics_app/presentation/widgets/order/driver_add_images_section.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/utils/date_formatter.dart';
import 'package:nalogistics_app/presentation/controllers/order_detail_controller.dart';
import 'package:nalogistics_app/presentation/controllers/order_controller.dart';
import 'package:nalogistics_app/presentation/widgets/common/custom_button.dart';
import 'package:nalogistics_app/presentation/widgets/common/app_bar_widget.dart';
import 'package:nalogistics_app/presentation/widgets/common/image_gallery_viewer.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';
import 'dart:async';

class OrderDetailPage extends StatefulWidget {
  final String orderID;

  const OrderDetailPage({super.key, required this.orderID});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _driverSeenTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadOrderDetail();
    _startDriverSeenTimer();
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
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _driverSeenTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrderDetail() async {
    final controller = Provider.of<OrderDetailController>(
      context,
      listen: false,
    );
    await controller.loadOrderDetail(widget.orderID);

    if (mounted && controller.orderDetail != null) {
      _fadeController.forward();
      _slideController.forward();
    }
  }

  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    final controller = Provider.of<OrderDetailController>(
      context,
      listen: false,
    );

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.maritimeBlue, size: 24),
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
                border: Border.all(color: newStatus.color.withOpacity(0.3)),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                  child: Text(
                    'Đã cập nhật trạng thái thành "${newStatus.displayName}"',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.statusDelivered,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Reload order detail to get latest data
        await controller.reloadOrderDetail();

        // Also refresh the order list in background
        final orderController = Provider.of<OrderController>(
          context,
          listen: false,
        );
        await orderController.refreshAllTabs();

        final authController = context.read<AuthController>();
        final trackingController = context
            .read<DriverLocationTrackingController>();
        if (authController.isDriver) {
          if (newStatus == OrderStatus.pickedUp ||
              newStatus == OrderStatus.inTransit) {
            await trackingController.startTracking(
              orderId: controller.orderDetail!.orderID.toString(),
            );
          } else if (newStatus == OrderStatus.delivered ||
              newStatus == OrderStatus.completed ||
              newStatus == OrderStatus.cancelled ||
              newStatus == OrderStatus.failedDelivery) {
            trackingController.stopTracking();
          }
        }
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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

  void _startDriverSeenTimer() {
    final authController = context.read<AuthController>();

    if (!authController.isDriver) {
      return;
    }

    _driverSeenTimer?.cancel();

    _driverSeenTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;

      context.read<OrderDetailController>().updateDriverSeenAt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: const AppBarWidget(title: 'Chi tiết đơn hàng'),
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
                      _buildCargoTypeCard(order),
                      const SizedBox(height: 16),
                      _buildLocationCard(order),
                      const SizedBox(height: 16),
                      _buildVehicleCard(order),
                      const SizedBox(height: 16),
                      // Driver Add Images Section
                      const DriverAddImagesSection(),
                      // Existing images
                      if (order.orderImageList.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildImagesCard(order),
                      ],
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

  void _openImageGallery(List<OrderImageModel> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ImageGalleryViewer(images: images, initialIndex: initialIndex),
      ),
    );
  }

  Widget _buildImageItem(
    OrderImageModel image,
    int index,
    List<OrderImageModel> allImages,
  ) {
    final isImage = AttachmentUtils.isImagePath(
      image.fileName.isNotEmpty ? image.fileName : image.url,
    );
    final displayName = image.fileName.isNotEmpty
        ? image.fileName
        : AttachmentUtils.fileNameFromPath(image.url);
    final imageAttachments = allImages
        .where(
          (item) => AttachmentUtils.isImagePath(
            item.fileName.isNotEmpty ? item.fileName : item.url,
          ),
        )
        .toList();
    final imageIndex = imageAttachments.indexWhere(
      (item) => item.imageID == image.imageID,
    );

    return GestureDetector(
      onTap: isImage && imageIndex >= 0
          ? () => _openImageGallery(imageAttachments, imageIndex)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.sectionBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.hintText.withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isImage)
                CachedNetworkImage(
                  imageUrl: image.url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, color: AppColors.statusError),
                )
              else
                _buildFileAttachmentPreview(displayName, image.url),
              Positioned(
                top: 6,
                right: 6,
                child: Material(
                  color: AppColors.maritimeBlue,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _downloadAttachment(image),
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
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
                    displayName,
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

  Widget _buildFileAttachmentPreview(String displayName, String url) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(12),
      color: AppColors.sectionBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AttachmentUtils.iconForPath(
              displayName.isNotEmpty ? displayName : url,
            ),
            color: AppColors.maritimeBlue,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            displayName,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesCard(OrderDetailModel order) {
    // final images = order.activeImages;
    final images = order.orderImageList;

    return _buildInfoCard(
      title: 'Hình ảnh / file đã đính kèm',
      icon: Icons.attach_file,
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
            return _buildImageItem(image, index, images);
          },
        ),
      ],
    );
  }

  Future<void> _downloadAttachment(OrderImageModel attachment) async {
    final fileName = attachment.fileName.isNotEmpty
        ? attachment.fileName
        : AttachmentUtils.fileNameFromPath(attachment.url);

    try {
      final savedPath = await AttachmentPickerService().downloadAttachment(
        url: attachment.url,
        fileName: fileName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedPath == null
                ? 'Đang tải "$fileName" về thư mục Downloads'
                : 'Đã tải "$fileName" về: $savedPath',
          ),
          backgroundColor: AppColors.statusDelivered,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải tệp: $e'),
          backgroundColor: AppColors.statusError,
        ),
      );
    }
  }

  Future<void> _downloadDispatchOrderPdf() async {
    final controller = context.read<OrderDetailController>();
    final savedPath = await controller.downloadDispatchOrderPdf();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          savedPath == null
              ? controller.errorMessage ?? 'Không thể tải lệnh điều động'
              : 'Đã tải "lệnh điều động" về: $savedPath',
        ),
        backgroundColor: savedPath == null
            ? AppColors.statusError
            : AppColors.statusDelivered,
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
                    '${order.orderID}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
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
            label: 'Ngày giao hàng',
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
          _buildTransportStopCard(
            title: 'CẢNG NHẬN CONTAINER',
            location: order.fromLocationName,
            address: 'HoChiMinh1111',
            phone: '1234213',
          ),
          _buildTransportArrow(),
          _buildTransportStopCard(
            title: 'KHO NHẬN/GIAO HÀNG',
            location: order.fromWhereName,
            address: 'HoChiMinh1911',
            phone: '1234213',
          ),
          _buildTransportArrow(),
          _buildTransportStopCard(
            title: 'CẢNG HẠ/TRẢ CONTAINER',
            location: order.toLocationName,
            address: 'HoChiMinh1911',
            phone: '1234213',
          ),
        ],
      ),
    );
  }

  Widget _buildTransportStopCard({
    required String title,
    required String location,
    required String address,
    required String phone,
  }) {
    final displayLocation = location.trim().isEmpty
        ? 'Chưa có thông tin'
        : location.trim();

    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 96),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.hintText.withOpacity(0.24)),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.maritimeBlue),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
              child: DefaultTextStyle(
                style: const TextStyle(color: AppColors.primaryText),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.maritimeBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTransportMetaRow(Icons.location_on, address),
                    const SizedBox(height: 6),
                    _buildTransportMetaRow(Icons.phone, phone),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportMetaRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.statusError),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransportArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Icon(Icons.arrow_downward, color: AppColors.secondaryText),
      ),
    );
  }

  Widget _buildCargoTypeCard(dynamic order) {
    return _buildInfoCard(
      title: 'Loại hàng',
      icon: Icons.category,
      color: AppColors.containerOrange,
      children: [
        _buildInfoRow(
          icon: Icons.inventory_2_outlined,
          label: 'Loại hàng',
          value: _getCargoTypeName(order.cargoTypeId),
        ),
      ],
    );
  }

  String _getCargoTypeName(int cargoTypeId) {
    switch (cargoTypeId) {
      case 1:
        return 'Nhập khẩu';
      case 2:
        return 'Xuất khẩu';
      case 3:
        return 'Trung chuyển';
      default:
        return 'Không xác định';
    }
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
          _buildVehicleInfo(
            icon: Icons.inventory_2_outlined,
            label: 'Số Container',
            value: order.containerNo,
            color: AppColors.skyBlue,
          ),
          const SizedBox(height: 12),
          _buildVehicleInfo(
            icon: Icons.local_shipping,
            label: 'Biển số xe',
            value: order.truckNo,
            color: AppColors.maritimeBlue,
          ),
          const SizedBox(height: 12),
          _buildVehicleInfo(
            icon: Icons.rv_hookup,
            label: 'Biển số Rơ-mooc',
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
        border: Border.all(color: color.withOpacity(0.2), width: 1),
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
                  fontSize: 14,
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
              fontSize: 17,
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
            isLast: true,
          ),
          // _buildTimelineItem(
          //   icon: Icons.done_all_rounded,
          //   title: 'Hoàn thành',
          //   time: order.orderStatus.index >= OrderStatus.completed.index
          //       ? 'Đã hoàn thành'
          //       : 'Chưa hoàn thành',
          //   isCompleted: order.orderStatus.index >= OrderStatus.completed.index,
          //   isLast: true,
          // ),
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
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
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
    final controller = context.watch<OrderDetailController>();
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
        nextStatus = OrderStatus.completed;
        break;
      default:
        nextStatus = null;
    }

    // Nếu đơn hàng đã giao thì không hiện nút xác nhận nữa
    if (nextStatus == OrderStatus.completed) {
      return _buildDispatchOrderPdfButton(controller);
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
        _buildDispatchOrderPdfButton(controller),
        const SizedBox(height: 12),
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

  Widget _buildDispatchOrderPdfButton(OrderDetailController controller) {
    return CustomButton(
      text: 'Xuất lệnh điều động (PDF)',
      onPressed: controller.isDownloadingDispatchPdf
          ? null
          : _downloadDispatchOrderPdf,
      isFullWidth: true,
      isLoading: controller.isDownloadingDispatchPdf,
      icon: Icons.picture_as_pdf,
      backgroundColor: AppColors.statusError,
      height: 56,
    );
  }

  Color _getStatusColor(OrderStatus status) {
    return status.color;
  }

  String _getStatusDisplayName(OrderStatus status) {
    return status.displayName;
  }
}
