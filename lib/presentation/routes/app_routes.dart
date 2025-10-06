import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nalogistics_app/presentation/pages/splash/api_splash_page.dart';
import 'package:nalogistics_app/presentation/pages/auth/api_login_page.dart';
import 'package:nalogistics_app/presentation/pages/main/role_based_main_navigation.dart';
import 'package:nalogistics_app/presentation/pages/orders/order_detail_page.dart';
import 'package:nalogistics_app/presentation/pages/orders/operator_order_detail_page.dart';
import 'package:nalogistics_app/presentation/routes/route_names.dart';
import 'package:nalogistics_app/main.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RouteNames.splash,

    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const ApiSplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const ApiLoginPage(),
      ),
      GoRoute(
        path: RouteNames.main,
        name: 'main',
        builder: (context, state) => const RoleBasedMainNavigation(),
      ),

      // ⭐ Driver Order Detail (API cũ)
      GoRoute(
        path: '${RouteNames.orderDetail}/:orderID',
        name: 'orderDetail',
        builder: (context, state) {
          final orderID = state.pathParameters['orderID']!;
          return OrderDetailPage(orderID: orderID);
        },
      ),

      // ⭐ NEW: Operator Order Detail (API mới với full data)
      GoRoute(
        path: '/operator-order-detail/:orderID',
        name: 'operatorOrderDetail',
        builder: (context, state) {
          final orderID = state.pathParameters['orderID']!;
          return OperatorOrderDetailPage(orderID: orderID);
        },
      ),
    ],

    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.login),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    },
  );
}