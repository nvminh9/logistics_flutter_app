import 'package:flutter/material.dart';
import 'package:nalogistics_app/data/models/order/operator_order_detail_model.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/presentation/controllers/operator_order_detail_controller.dart';
import 'package:nalogistics_app/data/models/truck/truck_list_model.dart';

class TruckSelectionDialog extends StatefulWidget {
  const TruckSelectionDialog({Key? key}) : super(key: key);

  @override
  State<TruckSelectionDialog> createState() => _TruckSelectionDialogState();
}

class _TruckSelectionDialogState extends State<TruckSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();

  TruckItemModel? _selectedTruck;
  OperatorOrderDetailModel? _orderDetail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<OperatorOrderDetailController>(
        context,
        listen: false,
      );
      controller.loadTruckList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OperatorOrderDetailController>(
      builder: (context, controller, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context),
                const SizedBox(height: 20),

                // Search bar
                _buildSearchBar(controller),
                const SizedBox(height: 20),

                // Truck list
                Expanded(
                  child: _buildTruckList(controller),
                ),

                const SizedBox(height: 16),

                // Action buttons
                _buildActionButtons(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.containerOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.local_shipping,
            color: AppColors.containerOrange,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn xe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              Text(
                'Điều phối xe cho đơn hàng',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          color: AppColors.secondaryText,
        ),
      ],
    );
  }

  Widget _buildSearchBar(OperatorOrderDetailController controller) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm theo biển số...',
        prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, size: 20),
          onPressed: () {
            _searchController.clear();
            controller.loadTruckList();
          },
        )
            : null,
        filled: true,
        fillColor: AppColors.sectionBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: (value) {
        setState(() {});
        controller.loadTruckList(searchQuery: value);
      },
    );
  }

  Widget _buildTruckList(OperatorOrderDetailController controller) {
    if (controller.isLoadingTrucks) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.containerOrange),
            SizedBox(height: 16),
            Text(
              'Đang tải danh sách xe...',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ],
        ),
      );
    }

    // final drivers = controller.filteredDriverList;
    final trucks = controller.filteredTruckList;

    if (trucks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: AppColors.hintText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Không có xe nào'
                  : 'Không tìm thấy xe',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Danh sách xe đang trống'
                  : 'Thử tìm kiếm với từ khóa khác',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: trucks.length,
      itemBuilder: (context, index) {
        final truck = trucks[index];
        final isSelected = _selectedTruck?.truckID == truck.truckID;

        return _buildTruckItem(truck, isSelected);
      },
    );
  }

  Widget _buildTruckItem(TruckItemModel truck, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected
            ? AppColors.containerOrange.withOpacity(0.1)
            : AppColors.sectionBackground,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTruck = truck;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.containerOrange
                    : Colors.transparent,
                width: 2,
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
                        truck.truckNo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping_sharp,
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
                  ),
                ),

                // Selection indicator
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.containerOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context,
      OperatorOrderDetailController controller,
      ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.secondaryText),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _selectedTruck == null
                ? null
                : () => _handleAssignTruck(context, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.containerOrange,
              disabledBackgroundColor: AppColors.hintText,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
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
        ),
      ],
    );
  }

  Future<void> _handleAssignTruck(
      BuildContext context,
      OperatorOrderDetailController controller,
      ) async {
    if (_selectedTruck == null) return;

    // Show loading
    Navigator.pop(context); // Close dialog first

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
              const CircularProgressIndicator(
                color: AppColors.containerOrange,
              ),
              const SizedBox(height: 20),
              Text(
                'Đang phân công phương tiện ${_selectedTruck!.truckNo}...',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );

    // Call API
    // final success = await controller.assignDriverToOrder(
    //   _selectedDriver!.driverID,
    // );

    // Chỉ cập nhật state
    controller.selectTruck(_selectedTruck!);
    final success = true;

    if (!context.mounted) return;

    // Close loading dialog
    Navigator.pop(context);

    if (success) {
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Đã phân công xe với biển số: ${_selectedTruck!.truckNo}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.statusDelivered,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Reload order detail
      // await controller.reloadOrderDetail();
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.errorMessage ?? 'Không thể phân công tài xế',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.statusError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}