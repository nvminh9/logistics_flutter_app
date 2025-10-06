// lib/data/models/order/confirm_order_response_model.dart

import 'package:nalogistics_app/core/base/base_model.dart';

class ConfirmOrderResponse extends BaseModel {
  final int statusCode;
  final String message;
  final int? data; // OrderID được confirm

  ConfirmOrderResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ConfirmOrderResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmOrderResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data,
    };
  }

  bool get isSuccess => statusCode == 200;
}