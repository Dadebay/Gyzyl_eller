import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

final class CustomLightTheme {
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: ColorConstants.whiteColor, statusBarIconBrightness: Brightness.dark),
        ),
        colorScheme: CustomColorScheme.lightColorScheme,
      );
}
