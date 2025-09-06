import 'package:flutter/material.dart';
import 'package:nalogistics_app/app.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/config/dependency_injection.dart';

void main() {
  // runApp(const NALogisticsDriverApp());
  runApp(
    MultiProvider(
      providers: DependencyInjection.providers,
      child: const NALogisticsDriverApp(),
    ),
  );
}