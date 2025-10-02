import 'package:flutter/material.dart';
import 'package:nalogistics_app/app.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/config/dependency_injection.dart';
import 'package:nalogistics_app/core/services/session_manager.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Initialize Session Manager
  SessionManager().initialize(
    navKey: navigatorKey,
    onTokenExpired: () {
      print('🔔 Token expired callback triggered');
      // Có thể thêm logic khác ở đây như clear cache, stop services, etc.
    },
  );

  runApp(
    MultiProvider(
      providers: DependencyInjection.providers,
      child: const NALogisticsDriverApp(),
    ),
  );
}