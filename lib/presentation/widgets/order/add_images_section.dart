import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/presentation/controllers/operator_order_detail_controller.dart';
import 'package:nalogistics_app/data/services/media/image_picker_service.dart';
import 'package:nalogistics_app/data/models/order/pending_image_model.dart';

class AddImagesSection extends StatelessWidget {
  const AddImagesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OperatorOrderDetailController>(
      builder: (context, controller, child) {
        final hasPendingImages = controller.pendingImages.isNotEmpty;

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
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.containerOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate,
                      color: AppColors.containerOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Thêm hình ảnh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  if (hasPendingImages) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.containerOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${controller.pendingImages.length} ảnh',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.containerOrange,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // Action Buttons
              if (!hasPendingImages) ...[
                _buildEmptyState(context, controller),
              ] else ...[
                _buildPendingImagesList(context, controller),
                const SizedBox(height: 16),
                _buildUploadButton(context, controller),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, OperatorOrderDetailController controller) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
                Icons.add_a_photo,
                size: 64,
                color: AppColors.hintText.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có ảnh nào',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Thêm ảnh để ghi nhận tình trạng đơn hàng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAddButton(
                context: context,
                controller: controller,
                icon: Icons.camera_alt,
                label: 'Chụp ảnh',
                onTap: () => _handleAddImage(context, controller, fromCamera: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAddButton(
                context: context,
                controller: controller,
                icon: Icons.photo_library,
                label: 'Chọn ảnh',
                onTap: () => _handleAddImage(context, controller, fromCamera: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddButton({
    required BuildContext context,
    required OperatorOrderDetailController controller,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.maritimeBlue,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingImagesList(BuildContext context, OperatorOrderDetailController controller) {
    return Column(
      children: [
        // Grid of pending images
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: controller.pendingImages.length + 1, // +1 for add button
          itemBuilder: (context, index) {
            if (index == controller.pendingImages.length) {
              return _buildAddMoreButton(context, controller);
            }

            final image = controller.pendingImages[index];
            return _buildPendingImageItem(context, controller, image);
          },
        ),
      ],
    );
  }

  Widget _buildPendingImageItem(
      BuildContext context,
      OperatorOrderDetailController controller,
      PendingImageModel image,
      ) {
    return GestureDetector(
      onTap: () => _showImagePreviewDialog(context, controller, image),
      child: Stack(
        children: [
          // Image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.maritimeBlue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                image.imageFile,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Description badge
          if (image.description.isNotEmpty)
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  image.description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _confirmDeleteImage(context, controller, image),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.statusError,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton(BuildContext context, OperatorOrderDetailController controller) {
    return GestureDetector(
      onTap: () => _handleAddImage(context, controller),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.sectionBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.maritimeBlue.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: AppColors.maritimeBlue.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm ảnh',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.maritimeBlue.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, OperatorOrderDetailController controller) {
    final isUploading = controller.isUploadingImages;
    final progress = controller.uploadPercentage;

    return Column(
      children: [
        if (isUploading) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.statusInTransit.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Đang upload...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.statusInTransit,
                      ),
                    ),
                    Text(
                      '${controller.uploadProgress}/${controller.totalImagesToUpload}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.statusInTransit,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: AppColors.hintText.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.statusInTransit,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: isUploading ? null : () => _handleUploadImages(context, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.containerOrange,
              disabledBackgroundColor: AppColors.hintText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: Icon(
              isUploading ? Icons.hourglass_empty : Icons.cloud_upload,
              color: Colors.white,
            ),
            label: Text(
              isUploading
                  ? 'Đang upload...'
                  : 'Upload ${controller.pendingImages.length} ảnh',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // HANDLERS
  // ============================================

  Future<void> _handleAddImage(
      BuildContext context,
      OperatorOrderDetailController controller, {
        bool? fromCamera,
      }) async {
    final imageService = ImagePickerService();
    File? imageFile;

    if (fromCamera == true) {
      imageFile = await imageService.pickImageFromCamera();
    } else if (fromCamera == false) {
      imageFile = await imageService.pickImageFromGallery();
    } else {
      imageFile = await imageService.showImageSourceDialog(context);
    }

    if (imageFile != null) {
      // Show dialog to add description
      if (context.mounted) {
        _showAddDescriptionDialog(context, controller, imageFile);
      }
    }
  }

  void _showAddDescriptionDialog(
      BuildContext context,
      OperatorOrderDetailController controller,
      File imageFile,
      ) {
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Thêm ghi chú cho ảnh',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  imageFile,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú (không bắt buộc)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColors.sectionBackground,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addPendingImage(
                imageFile,
                description: descriptionController.text.trim(),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maritimeBlue,
            ),
            child: const Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showImagePreviewDialog(
      BuildContext context,
      OperatorOrderDetailController controller,
      PendingImageModel image,
      ) {
    final descriptionController = TextEditingController(text: image.description);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  image.imageFile,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              // Controls
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _confirmDeleteImage(context, controller, image);
                            },
                            icon: const Icon(Icons.delete, color: AppColors.statusError),
                            label: const Text(
                              'Xóa',
                              style: TextStyle(color: AppColors.statusError),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              controller.updatePendingImageDescription(
                                image.id,
                                descriptionController.text.trim(),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.maritimeBlue,
                            ),
                            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteImage(
      BuildContext context,
      OperatorOrderDetailController controller,
      PendingImageModel image,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa ảnh?'),
        content: const Text('Bạn có chắc muốn xóa ảnh này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.removePendingImage(image.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusError,
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUploadImages(
      BuildContext context,
      OperatorOrderDetailController controller,
      ) async {
    // Confirm upload
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận upload'),
        content: Text(
          'Bạn có chắc muốn upload ${controller.pendingImages.length} ảnh?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.containerOrange,
            ),
            child: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Upload
    final success = await controller.uploadAllPendingImages();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Upload ảnh thành công!')),
            ],
          ),
          backgroundColor: AppColors.statusDelivered,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      // Reload order detail to show new images
      await controller.reloadOrderDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(controller.errorMessage ?? 'Upload thất bại'),
              ),
            ],
          ),
          backgroundColor: AppColors.statusError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}