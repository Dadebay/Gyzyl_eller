import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gyzyleller/modules/splash/splash_screen.dart';

class LanguageController extends GetxController {
  final storage = GetStorage();

  var selectedLanguage = 'tk'.obs;

  @override
  void onInit() {
    super.onInit();
    selectedLanguage.value = storage.read('langCode') ?? 'tk';
  }

  void changeLanguage(String languageCode) {
    Get.updateLocale(Locale(languageCode));
    storage.write('langCode', languageCode);
    selectedLanguage.value = languageCode;
    _updateTopicSubscription(languageCode);
  }

  Future<void> _updateTopicSubscription(String lang) async {
    if (lang == 'ru') {
      await FirebaseMessaging.instance.subscribeToTopic(kMasterTopicRu);
      await FirebaseMessaging.instance.unsubscribeFromTopic(kMasterTopicTk);
    } else {
      await FirebaseMessaging.instance.subscribeToTopic(kMasterTopicTk);
      await FirebaseMessaging.instance.unsubscribeFromTopic(kMasterTopicRu);
    }
  }
}
