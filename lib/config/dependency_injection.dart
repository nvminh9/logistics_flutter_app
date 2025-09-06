import 'package:provider/provider.dart';
import 'package:nalogistics_app/presentation/controllers/auth_controller.dart';
import 'package:nalogistics_app/presentation/controllers/order_controller.dart';

class DependencyInjection {
  static List<ChangeNotifierProvider> providers = [
    ChangeNotifierProvider<AuthController>(
      create: (_) => AuthController(),
    ),
    ChangeNotifierProvider<OrderController>(
      create: (_) => OrderController(),
    ),
    // Các providers khác có thể thêm vào đây ...
  ];
}