import 'package:nalogistics_app/core/base/base_model.dart';

/// Response model cho Update Order API
class UpdateOrderResponse extends BaseModel {
  final int statusCode;
  final String message;
  final dynamic data;

  UpdateOrderResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory UpdateOrderResponse.fromJson(Map<String, dynamic> json) {
    return UpdateOrderResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'],
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