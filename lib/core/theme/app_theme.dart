import 'package:flutter/material.dart';

/// 应用主题。
class AppTheme {
  AppTheme._();

  static const Color brandGreen = Color(0xFF00C853);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: brandGreen),
        scaffoldBackgroundColor: const Color(0xFFF5F7F9),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandGreen,
          brightness: Brightness.dark,
        ),
      );
}
