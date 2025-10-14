import 'package:nalogistics_app/core/base/base_model.dart';

/// Order Image (Hình ảnh đơn hàng)
class OrderImageModel extends BaseModel {
  final int imageID;
  final String fileName;
  final String url;
  final int userID;
  final String descrip;
  final DateTime created;
  final bool isActive;
  final int orderID;

  OrderImageModel({
    required this.imageID,
    required this.fileName,
    required this.url,
    required this.userID,
    required this.descrip,
    required this.created,
    required this.isActive,
    required this.orderID,
  });

  factory OrderImageModel.fromJson(Map<String, dynamic> json) {
    return OrderImageModel(
      imageID: json['imageID'] ?? 0,
      fileName: json['fileName'] ?? '',
      url: json['url'] ?? '',
      userID: json['userID'] ?? 0,
      descrip: json['descrip'] ?? 'Chưa có chú thích',
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? false,
      orderID: json['orderID'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'imageID': imageID,
      'fileName': fileName,
      'url': url,
      'userID': userID,
      'descrip': descrip,
      'created': created.toIso8601String(),
      'isActive': isActive,
      'orderID': orderID,
    };
  }
}