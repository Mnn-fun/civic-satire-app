import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/views/dashboard_orchestrator.dart';

void main() {
  runApp(
    // Wrapping the application in ProviderScope for Riverpod state management
    const ProviderScope(
      child: CivicSatireApp(),
    ),
  );
}

class CivicSatireApp extends StatelessWidget {
  const CivicSatireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Civic Satire',
      debugShowCheckedModeBanner: false,
      // Strict light Material 3 ThemeData with solid white background and Google Stitch UI
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      // Clean routing via DashboardOrchestrator watching globalAuthProvider
      home: const DashboardOrchestrator(),
    );
  }
}
