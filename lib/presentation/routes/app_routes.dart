import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nalogistics_app/presentation/pages/splash/splash_page.dart';
import 'package:nalogistics_app/presentation/pages/auth/login_page.dart';
import 'package:nalogistics_app/presentation/pages/main/main_navigation_page.dart';
import 'package:nalogistics_app/presentation/pages/orders/order_detail_page.dart';
import 'package:nalogistics_app/presentation/routes/route_names.dart';
import 'package:nalogistics_app/presentation/pages/auth/api_login_page.dart';
import 'package:nalogistics_app/presentation/pages/splash/api_splash_page.dart';
import 'package:nalogistics_app/main.dart'; // Import navigatorKey

class AppRoutes {
  static final GoRouter router = GoRouter(
    // ⭐ Set navigator key để SessionManager có thể navigate
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
        builder: (context, state) => const MainNavigationPage(),
      ),
      GoRoute(
        path: '${RouteNames.orderDetail}/:orderID',
        name: 'orderDetail',
        builder: (context, state) {
          final orderID = state.pathParameters['orderID']!;
          return OrderDetailPage(orderID: orderID);
        },
      ),
    ],

    // ⭐ Error handler cho routing errors
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