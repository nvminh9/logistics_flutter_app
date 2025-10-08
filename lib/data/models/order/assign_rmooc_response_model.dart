import 'package:nalogistics_app/core/base/base_model.dart';

class AssignRmoocResponse extends BaseModel {
  final int statusCode;
  final String message;
  final dynamic data;

  AssignRmoocResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory AssignRmoocResponse.fromJson(Map<String, dynamic> json) {
    return AssignRmoocResponse(
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