import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/constants/icon_constants.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/login/views/login_view.dart';
import 'package:gyzyleller/modules/user_profile/views/about_view.dart';
import 'package:gyzyleller/modules/user_profile/views/language_page.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: ColorConstants.background,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        IconConstants.person,
                        width: 53,
                        height: 54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  const Expanded(
                    child: Text(
                      'Adyňyz',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.to(LoginView());
                    },
                    icon: SvgPicture.asset(
                      height: 16,
                      width: 16,
                      IconConstants.login,
                    ),
                    label: const Text('Girmek'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: ColorConstants.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: const Size(102, 32),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            buildMenuItem(
              context,
              'language'.tr,
              IconConstants.language,
              () {
                Get.to(LanguagePage());
              },
            ),
            const SizedBox(height: 10.0),
            buildMenuItem(
              context,
              'about'.tr,
              IconConstants.description,
              () {
                Get.to(AboutView());
              },
            ),
            const SizedBox(height: 10.0),
            buildMenuItem(
              context,
              'faq'.tr,
              IconConstants.questionred,
              () {},
            ),
            const SizedBox(height: 10.0),
            buildMenuItem(
              context,
              'learn'.tr,
              IconConstants.tour,
              () {},
            ),
            const SizedBox(height: 10.0),
            buildMenuItem(
              context,
              'contact'.tr,
              IconConstants.support,
              () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(
      BuildContext context, String title, String iconPath, VoidCallback onTap) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.fonts,
                  ),
                ),
              ),
              SvgPicture.asset(
                IconConstants.expand_more,
                width: 24,
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
