import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nalogistics_app/presentation/pages/splash/splash_page.dart';
import 'package:nalogistics_app/presentation/pages/auth/login_page.dart';
import 'package:nalogistics_app/presentation/pages/main/main_navigation_page.dart';
import 'package:nalogistics_app/presentation/pages/main/simple_main_navigation.dart';
import 'package:nalogistics_app/presentation/pages/orders/order_detail_page.dart';
import 'package:nalogistics_app/presentation/routes/route_names.dart';
import 'package:nalogistics_app/presentation/pages/auth/api_login_page.dart';
import 'package:nalogistics_app/presentation/pages/splash/api_splash_page.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
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
        // builder: (context, state) => const SimpleMainNavigationPage(),
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
  );
}