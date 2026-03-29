import 'package:flutter/material.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

extension ThemeColors on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get redColor => Theme.of(this).colorScheme.error;
  Color get whiteColor => Theme.of(this).colorScheme.onPrimary;
  Color get background => ColorConstants.background;
  Color get blackColor => Theme.of(this).colorScheme.onSecondaryContainer;
  Color get greyColor => ColorConstants.greyColor;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get outlineColor => Theme.of(this).colorScheme.outline;
}

extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}

class AppLocalizations {
  get onboardingTypeSecond => null;

  get onboardingTypeFirst => null;

  String get onboardingTypeSubtitle => 'null';

  String get onboardingTypeTitle => "null";

  static of(BuildContext buildContext) {}
}
