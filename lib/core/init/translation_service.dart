import 'dart:ui';

import 'package:get/get.dart';

class TranslationService extends Translations {
  static final fallbackLocale = const Locale('tr', 'TR');

  static final supportedLocales = [
    const Locale('en', 'US'),
    const Locale('tr', 'TR'),
    const Locale('ru', 'RU'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
        'tr': {},
        'en': {},
        'ru': {},
      };
}
