import 'package:nalogistics_app/presentation/controllers/operator_order_detail_controller.dart';
import 'package:nalogistics_app/presentation/controllers/profile_controller.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/presentation/controllers/auth_controller.dart';
import 'package:nalogistics_app/presentation/controllers/order_controller.dart';
import 'package:nalogistics_app/presentation/controllers/order_detail_controller.dart';

class DependencyInjection {
  static List<ChangeNotifierProvider> providers = [
    ChangeNotifierProvider<AuthController>(
      create: (_) => AuthController(),
    ),
    ChangeNotifierProvider<OrderController>(
      create: (_) => OrderController(),
    ),
    ChangeNotifierProvider<OrderDetailController>(
      create: (_) => OrderDetailController(),
    ),
    ChangeNotifierProvider<OperatorOrderDetailController>(
      create: (_) => OperatorOrderDetailController(),
    ),
    ChangeNotifierProvider<ProfileController>(
      create: (_) => ProfileController(),
    ),
    // Các providers khác có thể thêm vào đây ...
  ];
}