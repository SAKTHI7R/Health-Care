import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF42A5F5);
  static const Color secondary = Color(0xFF1976D2);
  static const Color background = Colors.white;
  static const Color card = Color(0xFFF5F5F5);
  static const Color text = Colors.black87;
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkText = Colors.white;
}

class AppTextStyles {
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'Poppins',
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: 'Poppins',
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
  );
}

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Poppins',
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  iconTheme: const IconThemeData(color: AppColors.text),
  cardColor: AppColors.card,
  dividerColor: Colors.grey.shade300,
  dialogBackgroundColor: AppColors.background,
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
  ),
  textTheme: ThemeData.light().textTheme.copyWith(
        headlineSmall: AppTextStyles.headlineSmall,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyMedium: AppTextStyles.bodyMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      textStyle: AppTextStyles.titleSmall,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.secondary,
      textStyle: AppTextStyles.bodyMedium,
    ),
  ),
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.background,
    onSurface: AppColors.text,
    onPrimary: Colors.white,
    error: Colors.red,
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.darkBackground,
  fontFamily: 'Poppins',
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  iconTheme: const IconThemeData(color: AppColors.darkText),
  cardColor: AppColors.darkCard,
  dividerColor: Colors.grey.shade700,
  dialogBackgroundColor: AppColors.darkCard,
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
  ),
  textTheme: ThemeData.dark().textTheme.copyWith(
        headlineSmall:
            AppTextStyles.headlineSmall.copyWith(color: AppColors.darkText),
        titleMedium:
            AppTextStyles.titleMedium.copyWith(color: AppColors.darkText),
        titleSmall:
            AppTextStyles.titleSmall.copyWith(color: AppColors.darkText),
        bodyMedium:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.darkText),
        labelSmall:
            AppTextStyles.labelSmall.copyWith(color: AppColors.darkText),
      ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      textStyle: AppTextStyles.titleSmall,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.secondary,
      textStyle: AppTextStyles.bodyMedium,
    ),
  ),
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.darkBackground,
    onSurface: AppColors.darkText,
    onPrimary: Colors.white,
    error: Colors.red,
  ),
);
