import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/views/login_screen.dart';

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
      // Strict dark Material 3 ThemeData with deep background and high-contrast typography
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      // Clean routing to the role-selection login screen
      home: const LoginScreen(),
    );
  }
}
