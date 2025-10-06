import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/base/base_model.dart';

/// Model cho hình ảnh đang chờ upload
class PendingImageModel extends BaseModel {
  final String id; // Unique ID để track
  final File imageFile; // File ảnh local
  final String description; // Ghi chú
  final DateTime createdAt; // Thời gian thêm

  PendingImageModel({
    required this.id,
    required this.imageFile,
    required this.description,
    required this.createdAt,
  });

  // Copy with để update description
  PendingImageModel copyWith({
    String? id,
    File? imageFile,
    String? description,
    DateTime? createdAt,
  }) {
    return PendingImageModel(
      id: id ?? this.id,
      imageFile: imageFile ?? this.imageFile,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imageFile.path,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Get file size in MB
  Future<double> getFileSizeMB() async {
    final bytes = await imageFile.length();
    return bytes / (1024 * 1024);
  }

  // Check if image exists
  bool exists() {
    return imageFile.existsSync();
  }
}

/// Response model cho upload image
class UploadImageResponse extends BaseModel {
  final int statusCode;
  final String message;
  final UploadedImageData? data;

  UploadImageResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory UploadImageResponse.fromJson(Map<String, dynamic> json) {
    return UploadImageResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UploadedImageData.fromJson(json['data'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data?.toJson(),
    };
  }

  bool get isSuccess => statusCode == 200;
}

class UploadedImageData extends BaseModel {
  final int imageID;
  final String fileName;
  final String url;

  UploadedImageData({
    required this.imageID,
    required this.fileName,
    required this.url,
  });

  factory UploadedImageData.fromJson(Map<String, dynamic> json) {
    return UploadedImageData(
      imageID: json['imageID'] ?? 0,
      fileName: json['fileName'] ?? '',
      url: json['url'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'imageID': imageID,
      'fileName': fileName,
      'url': url,
    };
  }
}