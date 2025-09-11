import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

final class CustomLightTheme {
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: ColorConstants.background,
              statusBarIconBrightness: Brightness.dark),
        ),
        colorScheme: CustomColorScheme.lightColorScheme,
        scaffoldBackgroundColor: ColorConstants.background,
      );
}
