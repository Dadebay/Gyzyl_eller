import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/home/controllers/home_controller.dart';
import 'package:gyzyleller/modules/home/views/bottomnavbar/bottom_nav_bar_view.dart';
import 'package:gyzyleller/modules/onboarding/views/lang/lang_view.dart';
import 'package:gyzyleller/shared/constants/image_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  final HomeController controller = Get.put(HomeController());
  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    final box = GetStorage();
    bool isFirstLaunch = box.read('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      await box.write('isFirstLaunch', false);
      Get.off(() => LanguagePageFirst());
    } else {
      Get.off(() => BottomNavBar());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      body: Center(
        child: Image.asset(
          ImageConstants.logoSplash,
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
