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
          'login_instruction':
              'Ulgama girmek we kod almak üçin telefon belgiňizi giriziň',
          'phone_number_label': 'Telefon belgiňiz',
          'password_input_label': 'Açar söz',
          'with_all_terms': 'Ähli şertleri bilen ',
          'agreement_text': 'yalasygyny',
          'continue_button': 'Dowam et',
          'onboarding_welcome_title': '"Gyzyl eller" ulgamy bilen tanyşyň.',
          'onboarding_welcome_description':
              'Indi dürli işlerde hünärmenleri (ussalary) bildirişlerde gözlemek gerek däl. Siz diňe ýumuşlary döredýäňiz, hünärmenler bolsa özleri Size tekliplerini iberýärler. Size diňe amatlysyny saýlamak galýar.',
          'onboarding_how_to_create_task': 'Nädip yumuşlary döretmeli',
          'onboarding_how_to_be_executor': 'Nädip ýerine ýetiriji bolmaly',
          'onboarding_publish_task_title': 'Ýumuş çap ediň',
          'onboarding_publish_task_description':
              'Indi wagtyňyzy saryp edip hünärmenleri gözlemek gerek däl.Bir ýumuş dörediň, kategoriýa saýlaň, näme, nirede we haçan etmelidigini düşündiriň we ýumuşyňyzy çap ediň.',
          'onboarding_find_specialist_title': 'Hünärmen tapyň',
          'onboarding_find_specialist_description':
              'Hünärmenler size öz tekliplerini ibererler. Siz bolsa iň amatlysyny saýlarsyňyz.',
          'onboarding_complete_task_title': 'Ýumuşy ýerine ýetiriň',
          'onboarding_complete_task_description':
              'Saýlanan hünärmen bilen şertleşiň we ýumuşy ýerine ýetirmäge rugsat beriň.',
          'onboarding_skip_button': 'Geçmek',
          'language_selection_title': 'Dili Saýlamak',
          'language_selection_instruction': 'Dowam etmek üçin dili saýlaň.',
          'language_option_turkmen': 'Türkmençe',
          'language_option_russian': 'Русский',
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
          'login_instruction':
              'Enter your phone number to log in and get a code',
          'phone_number_label': 'Phone Number',
          'password_input_label': 'Password',
          'with_all_terms': 'With all terms ',
          'agreement_text': 'agreement',
          'continue_button': 'Continue',
          'onboarding_welcome_title':
              'Get acquainted with the "Gyzyl eller" system.',
          'onboarding_welcome_description':
              'Now there is no need to search for specialists (masters) in various jobs through announcements. You just create tasks, and specialists send you their offers. You just have to choose the most suitable one.',
          'onboarding_how_to_create_task': 'How to create tasks',
          'onboarding_how_to_be_executor': 'How to become an executor',
          'onboarding_publish_task_title': 'Publish a task',
          'onboarding_publish_task_description':
              'Now there is no need to spend your time searching for specialists.\nCreate a task, select a category, explain what, where, and when to do it, and publish your task.',
          'onboarding_find_specialist_title': 'Find a specialist',
          'onboarding_find_specialist_description':
              'Specialists will send you their offers. You will choose the most suitable one.',
          'onboarding_complete_task_title': 'Complete the task',
          'onboarding_complete_task_description':
              'Agree with the selected specialist and allow them to complete the task.',
          'onboarding_skip_button': 'Skip',
          'language_selection_title': 'Select Language',
          'language_selection_instruction': 'Select a language to continue.',
          'language_option_turkmen': 'Turkmen',
          'language_option_russian': 'Russian',
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
          'login_instruction':
              'Введите свой номер телефона, чтобы войти и получить код',
          'phone_number_label': 'Номер телефона',
          'password_input_label': 'Пароль',
          'with_all_terms': 'Со всеми условиями ',
          'agreement_text': 'соглашения',
          'continue_button': 'Продолжить',
          'onboarding_welcome_title': 'Познакомьтесь с системой "Gyzyl eller".',
          'onboarding_welcome_description':
              'Теперь нет необходимости искать специалистов (мастеров) по различным работам в объявлениях. Вы просто создаете задания, а специалисты сами присылают Вам свои предложения. Вам остается только выбрать наиболее подходящее.',
          'onboarding_how_to_create_task': 'Как создавать задания',
          'onboarding_how_to_be_executor': 'Как стать исполнителем',
          'onboarding_publish_task_title': 'Опубликовать задание',
          'onboarding_publish_task_description':
              'Теперь не нужно тратить время на поиск специалистов.\nСоздайте задание, выберите категорию, объясните, что, где и когда нужно сделать, и опубликуйте свое задание.',
          'onboarding_find_specialist_title': 'Найти специалиста',
          'onboarding_find_specialist_description':
              'Специалисты пришлют вам свои предложения. Вы выберете наиболее подходящее.',
          'onboarding_complete_task_title': 'Выполнить задание',
          'onboarding_complete_task_description':
              'Договоритесь с выбранным специалистом и разрешите ему выполнить задание.',
          'onboarding_skip_button': 'Пропустить',
          'language_selection_title': 'Выбрать язык',
          'language_selection_instruction': 'Выберите язык для продолжения.',
          'language_option_turkmen': 'Туркменский',
          'language_option_russian': 'Русский',
        },
      };
}
