import 'package:nalogistics_app/core/base/base_model.dart';

class AssignDriverResponse extends BaseModel {
  final int statusCode;
  final String message;
  final dynamic data;

  AssignDriverResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory AssignDriverResponse.fromJson(Map<String, dynamic> json) {
    return AssignDriverResponse(
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