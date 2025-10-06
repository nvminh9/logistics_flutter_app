import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:nalogistics_app/core/constants/colors.dart';

class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Pick image từ camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compress to 85% quality
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      print('❌ Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick image từ gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      print('❌ Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick multiple images từ gallery
  Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (images.isEmpty) return [];

      // Limit số lượng
      final limitedImages = images.take(maxImages).toList();

      return limitedImages.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('❌ Error picking multiple images: $e');
      return [];
    }
  }

  /// Crop image
  Future<File?> cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cắt ảnh',
            toolbarColor: AppColors.maritimeBlue,
            toolbarWidgetColor: AppColors.onPrimaryText,
            activeControlsWidgetColor: AppColors.maritimeBlue,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            // aspectRatioPresets: [
            //   CropAspectRatioPreset.original,
            //   CropAspectRatioPreset.square,
            //   CropAspectRatioPreset.ratio4x3,
            //   CropAspectRatioPreset.ratio16x9,
            // ],
          ),
          IOSUiSettings(
            title: 'Cắt ảnh',
            // aspectRatioPresets: [
            //   CropAspectRatioPreset.original,
            //   CropAspectRatioPreset.square,
            //   CropAspectRatioPreset.ratio4x3,
            //   CropAspectRatioPreset.ratio16x9,
            // ],
          ),
        ],
      );

      if (croppedFile == null) return null;

      return File(croppedFile.path);
    } catch (e) {
      print('❌ Error cropping image: $e');
      return null;
    }
  }

  /// Show bottom sheet để chọn nguồn ảnh
  Future<File?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<File>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.hintText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Chọn nguồn ảnh',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 24),
            _buildSourceOption(
              context: context,
              icon: Icons.camera_alt,
              title: 'Chụp ảnh',
              subtitle: 'Sử dụng camera',
              onTap: () async {
                final image = await pickImageFromCamera();
                if (context.mounted) Navigator.pop(context, image);
              },
            ),
            const SizedBox(height: 12),
            _buildSourceOption(
              context: context,
              icon: Icons.photo_library,
              title: 'Chọn từ thư viện',
              subtitle: 'Chọn ảnh có sẵn',
              onTap: () async {
                final image = await pickImageFromGallery();
                if (context.mounted) Navigator.pop(context, image);
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.sectionBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.maritimeBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.maritimeBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.hintText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}