import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

final class CustomDarkTheme {
  final ThemeData themeData = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.dark,
    colorScheme: CustomColorScheme.darkColorScheme,
    scaffoldBackgroundColor: const Color(0xff121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff121212),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: ColorConstants.blackColor,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardTheme(
      color: const Color(0xff1E1E1E),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xff2C2C2C),
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      displayMedium: TextStyle(color: Colors.white),
      displaySmall: TextStyle(color: Colors.white),
      headlineLarge:
          TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      headlineMedium: TextStyle(color: Colors.white),
      headlineSmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white70),
      titleSmall: TextStyle(color: Colors.white70),
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
      bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
      labelLarge: TextStyle(color: Colors.white),
      labelMedium: TextStyle(color: Colors.white70),
      labelSmall: TextStyle(color: Colors.white60),
    ),
  );
}
