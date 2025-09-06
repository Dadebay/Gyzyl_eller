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
          'create_professional_profile': 'Hünärmen profili döretmek',
          'login_button': 'Girmek',
          'your_name': 'Adyňyz', // Default for username if not logged in
          'my_profile': 'Meniň profilim',
          'your_name_label': 'Adyňyz',
          'your_phone_number_label': 'Telefon belgiňiz',
          'password_label': 'Açar sözi',
          'delete_my_profile': 'Profilimi pozmak',
          'save_changes': 'Ýatda sakla',
          'my_tab': 'Meniňki',
          'all_tab': 'Hemmesi',
          'tasks_tab': 'Yumuşlar',
          'menu_tab': 'Menýu',
          'login_title': 'Içeri gir',
          'login_instruction': 'Ulgama girmek we kod almak üçin telefon belgiňizi giriziň',
          'phone_number_label': 'Telefon belgiňiz',
          'password_input_label': 'Açar söz',
          'with_all_terms': 'Ähli şertleri bilen ',
          'agreement_text': 'yalasygyny',
          'continue_button': 'Dowam et',
        },
        'en': {
          'language': 'App Language',
          'about': 'About the System',
          'faq': 'Questions and Answers',
          'learn': 'Learn Golds',
          'contact': 'Contact Us',
          'save': 'Save', // Corrected
          'create_professional_profile': 'Create Professional Profile',
          'login_button': 'Login',
          'your_name': 'Your Name',
          'my_profile': 'My Profile',
          'your_name_label': 'Your Name',
          'your_phone_number_label': 'Your Phone Number',
          'password_label': 'Password',
          'delete_my_profile': 'Delete My Profile',
          'save_changes': 'Save Changes',
          'my_tab': 'Mine',
          'all_tab': 'All',
          'tasks_tab': 'Tasks',
          'menu_tab': 'Menu',
          'login_title': 'Login',
          'login_instruction': 'Enter your phone number to log in and get a code',
          'phone_number_label': 'Phone Number',
          'password_input_label': 'Password',
          'with_all_terms': 'With all terms ',
          'agreement_text': 'agreement',
          'continue_button': 'Continue',
        },
        'ru': {
          'language': 'Язык приложения',
          'about': 'О системе',
          'faq': 'Вопросы и ответы',
          'learn': 'Изучение золота',
          'contact': 'Связаться с нами',
          'save': 'Сохранить', // Corrected
          'create_professional_profile': 'Создать профиль специалиста',
          'login_button': 'Войти',
          'your_name': 'Ваше имя',
          'my_profile': 'Мой профиль',
          'your_name_label': 'Ваше имя',
          'your_phone_number_label': 'Ваш номер телефона',
          'password_label': 'Пароль',
          'delete_my_profile': 'Удалить мой профиль',
          'save_changes': 'Сохранить изменения',
          'my_tab': 'Мои',
          'all_tab': 'Все',
          'tasks_tab': 'Задачи',
          'menu_tab': 'Меню',
          'login_title': 'Войти',
          'login_instruction': 'Введите свой номер телефона, чтобы войти и получить код',
          'phone_number_label': 'Номер телефона',
          'password_input_label': 'Пароль',
          'with_all_terms': 'Со всеми условиями ',
          'agreement_text': 'соглашения',
          'continue_button': 'Продолжить',
        },
      };
}