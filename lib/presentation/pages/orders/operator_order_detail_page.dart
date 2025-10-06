// lib/presentation/pages/orders/operator_order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/utils/date_formatter.dart';
import 'package:nalogistics_app/core/utils/money_formatter.dart';
import 'package:nalogistics_app/data/models/order/operator_order_detail_model.dart';
import 'package:nalogistics_app/data/repositories/implementations/order_repository.dart';
import 'package:nalogistics_app/domain/usecases/order/get_operator_order_detail_usecase.dart';
import 'package:nalogistics_app/presentation/widgets/common/app_bar_widget.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OperatorOrderDetailPage extends StatefulWidget {
  final String orderID;

  const OperatorOrderDetailPage({super.key, required this.orderID});

  @override
  State<OperatorOrderDetailPage> createState() => _OperatorOrderDetailPageState();
}

class _OperatorOrderDetailPageState extends State<OperatorOrderDetailPage> {
  late GetOperatorOrderDetailUseCase _useCase;
  OperatorOrderDetailModel? _orderDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _useCase = GetOperatorOrderDetailUseCase(OrderRepository());
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _useCase.execute(orderID: widget.orderID);
      setState(() {
        _orderDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: const AppBarWidget(title: 'Chi tiết đơn hàng'),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.maritimeBlue),
      )
          : _errorMessage != null
          ? _buildErrorView()
          : _buildDetailView(),
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
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 24),
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
      ),
    );
  }

  Widget _buildDetailView() {
    if (_orderDetail == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: _loadOrderDetail,
      color: AppColors.maritimeBlue,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildCustomerCard(),
            const SizedBox(height: 16),
            _buildDriverCard(),
            const SizedBox(height: 16),
            _buildVehicleCard(),
            const SizedBox(height: 16),
            _buildLocationCard(),
            const SizedBox(height: 16),
            _buildOrderLinesCard(),
            const SizedBox(height: 16),
            _buildImagesCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HEADER CARD
  // ==========================================
  Widget _buildHeaderCard() {
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
                    '#${widget.orderID}',
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
                  color: _orderDetail!.orderStatus.color.withOpacity(0.2),
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
                        color: _orderDetail!.orderStatus.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _orderDetail!.orderStatus.displayName,
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
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderInfo(
                Icons.calendar_today,
                'Ngày tạo',
                DateFormatter.formatDate(_orderDetail!.orderDate),
              ),
              _buildHeaderInfo(
                Icons.receipt_long,
                'Bill Booking',
                _orderDetail!.billBookingNo,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CUSTOMER CARD
  // ==========================================
  Widget _buildCustomerCard() {
    return _buildInfoCard(
      title: 'Thông tin khách hàng',
      icon: Icons.business,
      color: AppColors.maritimeBlue,
      children: [
        _buildInfoRow(
          icon: Icons.business,
          label: 'Tên khách hàng',
          value: _orderDetail!.customerName,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.badge,
          label: 'Mã khách hàng',
          value: 'KH-${_orderDetail!.customerId}',
        ),
      ],
    );
  }

  // ==========================================
  // DRIVER CARD
  // ==========================================
  Widget _buildDriverCard() {
    return _buildInfoCard(
      title: 'Thông tin tài xế',
      icon: Icons.person,
      color: AppColors.oceanTeal,
      children: [
        _buildInfoRow(
          icon: Icons.person,
          label: 'Tên tài xế',
          value: _orderDetail!.driverName.isNotEmpty
              ? _orderDetail!.driverName
              : 'Chưa phân công',
        ),
        if (_orderDetail!.driverId != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.badge,
            label: 'Mã tài xế',
            value: 'TX-${_orderDetail!.driverId}',
          ),
        ],
      ],
    );
  }

  // ==========================================
  // VEHICLE CARD
  // ==========================================
  Widget _buildVehicleCard() {
    return _buildInfoCard(
      title: 'Thông tin phương tiện',
      icon: Icons.local_shipping,
      color: AppColors.containerOrange,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildVehicleInfo(
                icon: Icons.inventory_2,
                label: 'Container',
                value: _orderDetail!.containerNo,
                type: _orderDetail!.containerType,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVehicleInfo(
                icon: Icons.local_shipping,
                label: 'Xe đầu kéo',
                value: _orderDetail!.truckNo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildVehicleInfo(
          icon: Icons.rv_hookup,
          label: 'Rơ moóc',
          value: _orderDetail!.rmoocNo,
        ),
      ],
    );
  }

  Widget _buildVehicleInfo({
    required IconData icon,
    required String label,
    required String value,
    String? type,
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
        ],
      ),
    );
  }

  // ==========================================
  // LOCATION CARD
  // ==========================================
  Widget _buildLocationCard() {
    return _buildInfoCard(
      title: 'Thông tin vận chuyển',
      icon: Icons.location_on,
      color: AppColors.statusInTransit,
      children: [
        _buildLocationItem(
          icon: Icons.upload,
          label: 'ĐIỂM LẤY HÀNG',
          location: _orderDetail!.fromLocationName,
          detail: _orderDetail!.fromWhereName,
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
          location: _orderDetail!.toLocationName,
          color: AppColors.statusDelivered,
        ),
      ],
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

  // ==========================================
  // ORDER LINES CARD (Chi phí)
  // ==========================================
  Widget _buildOrderLinesCard() {
    final lines = _orderDetail!.orderLineList1;
    final totalCost = _orderDetail!.totalCost;

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

  // ==========================================
  // IMAGES CARD
  // ==========================================
  Widget _buildImagesCard() {
    final images = _orderDetail!.activeImages;

    if (images.isEmpty) {
      return const SizedBox();
    }

    return _buildInfoCard(
      title: 'Hình ảnh đơn hàng',
      icon: Icons.photo_library,
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
                borderRadius: BorderRadius.circular(12),
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

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
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
}