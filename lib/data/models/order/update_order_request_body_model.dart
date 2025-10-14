import 'package:nalogistics_app/core/base/base_model.dart';

class UpdateOrderRequest extends BaseModel {
  final String username;
  final String password;

  UpdateOrderRequest({
    required this.username,
    required this.password,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}