import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/presentation/themes/app_theme.dart';
import 'package:nalogistics_app/presentation/routes/app_routes.dart';
import 'package:nalogistics_app/main.dart'; // Import để dùng navigatorKey

class NALogisticsDriverApp extends StatelessWidget {
  const NALogisticsDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      routerConfig: AppRoutes.router,
      debugShowCheckedModeBanner: false,
    );
  }
}