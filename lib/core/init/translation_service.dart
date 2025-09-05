import 'dart:ui';

import 'package:get/get.dart';

class TranslationService extends Translations {
  static final fallbackLocale = const Locale('tk', 'TM');

  static final supportedLocales = [
    const Locale('en', 'US'),
    const Locale('tk', 'TM'),
    const Locale('ru', 'RU'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
        'tk': {
          'language': 'Programmanyň dili',
          'about': 'Ulgam barada',
          'faq': 'Soraglar we jogaplar',
          'learn': 'Gyzyllar öwrenmek',
          'contact': 'Habarlaşmak',
          'save': 'Ýatda Sakla',
        },
        'en': {
          'language': 'App Language',
          'about': 'About the System',
          'faq': 'Questions and Answers',
          'learn': 'Learn Golds',
          'contact': 'Contact Us',
          'save': 'Ýatda Sakla',
        },
        'ru': {
          'language': 'Язык приложения',
          'about': 'О системе',
          'faq': 'Вопросы и ответы',
          'learn': 'Изучение золота',
          'contact': 'Связаться с нами',
          'save': 'Ýatda Sakla',
        },
      };
}
