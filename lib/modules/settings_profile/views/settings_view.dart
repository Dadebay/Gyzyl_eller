// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/login/bindings/login_binding.dart';
import 'package:gyzyleller/modules/login/views/login_view.dart';
// ignore: unused_import
import 'package:gyzyleller/modules/special_profile/views/special_profile_add.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/settings_controller.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/user_profile_controller.dart';
import 'package:gyzyleller/modules/settings_profile/views/language_page.dart';
import 'package:gyzyleller/modules/settings_profile/views/wallet_view.dart';
import 'package:gyzyleller/modules/onboarding/views/onboarding_view.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/dialogs/contact_us_dialog.dart';
import 'package:gyzyleller/shared/dialogs/dialogs_utils.dart';

class SettingsView extends GetView<SettingsController> {
  final bool showAppBar;
  SettingsView({super.key, this.showAppBar = false});
  @override
  final SettingsController controller = Get.put(SettingsController());
  final UserProfilController profilController = Get.put(UserProfilController());

  String get _langWeb => GetStorage().read('langCode') ?? 'tk';

  void _launchURL(String url) {
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.inAppBrowserView,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: ColorConstants.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Get.back(),
              ),
              title: Text(
                'Settings'.tr,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Obx(() => _buildUserHeader()),
            const SizedBox(height: 20.0),
            Obx(() {
              if (controller.isLoggedIn) {
                return Column(
                  children: [
                    _buildMenuItem(
                      context,
                      controller.hasSpecialProfile.value
                          ? 'professional_profile'.tr
                          : 'create_professional_profile'.tr,
                      IconConstants.new_releases,
                      () {
                        controller.navigateToSpecialProfile();
                      },
                    ),
                    const SizedBox(height: 10.0),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            Obx(() {
              if (!controller.isLoggedIn) return const SizedBox.shrink();
              return Column(
                children: [
                  _buildMenuItemSay(
                    context,
                    'my_account_title'.tr,
                    IconConstants.leaderboard,
                    () {
                      Get.to(() => const WalletView());
                    },
                  ),
                  const SizedBox(height: 10.0),
                ],
              );
            }),
            _buildMenuItem(
              context,
              'language'.tr,
              IconConstants.language,
              () {
                Get.to(() => LanguagePage());
              },
            ),
            const SizedBox(height: 10.0),
            _buildMenuItem(
              context,
              'about'.tr,
              IconConstants.description,
              () {
                _launchURL('${Api().urlSimple}general-rules/$_langWeb');
              },
            ),
            const SizedBox(height: 10.0),
            _buildMenuItem(
              context,
              'faq'.tr,
              IconConstants.questionred,
              () {
                _launchURL('${Api().urlSimple}faq/$_langWeb');
              },
            ),
            const SizedBox(height: 10.0),
            _buildMenuItem(
              context,
              'learn'.tr,
              IconConstants.tour,
              () {
                Get.to(() => const OnboardingScreen(skipTimer: true));
              },
            ),
            const SizedBox(height: 10.0),
            _buildMenuItem(
              context,
              'contact'.tr,
              IconConstants.support,
              () {
                showContactUsDialog(context);
              },
            ),
            const SizedBox(height: 10.0),
            if (controller.isLoggedIn)
              _buildMenuItem(
                context,
                'logout'.tr,
                IconConstants.logout,
                () async {
                  final bool? confirmLogout =
                      await DialogUtils().showDeleteProfileDialog(context);
                  if (confirmLogout == true) {
                    await controller.logout();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
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
          ClipRRect(
            borderRadius: BorderRadius.circular(37),
            child: Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ColorConstants.background,
              ),
              child: (controller.imageUrl != null &&
                      controller.imageUrl!.startsWith('http'))
                  ? CachedNetworkImage(
                      imageUrl: controller.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildImageShimmer(),
                      errorWidget: (context, url, _) => SvgPicture.asset(
                        IconConstants.person,
                        width: 53,
                        height: 54,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        IconConstants.person,
                        width: 53,
                        height: 54,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              controller.username,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          controller.isLoggedIn ? _buildEditButton() : _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Get.to(() => const LoginView(), binding: LoginBinding());
      },
      icon: SvgPicture.asset(
        height: 16,
        width: 16,
        IconConstants.login,
      ),
      label: Text('login_button'.tr),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: ColorConstants.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(102, 32),
      ),
    );
  }

  // Widget _buildEditButton() {
  //   return GestureDetector(
  //     onTap: () {
  //       Get.to(
  //         () => ProfileEditView(userData: controller.user.value!),
  //       );
  //     },
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: ColorConstants.background,
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       padding: const EdgeInsets.all(10),
  //       child: SvgPicture.asset(
  //         IconConstants.edit,
  //         height: 20,
  //         width: 20,
  //         color: Colors.black,
  //       ),
  //     ),
  //   );
  // }
  Widget _buildEditButton() {
    return const SizedBox();
  }

  Widget _buildMenuItem(
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
                IconConstants.expandMore,
                width: 24,
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemSay(
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
              Obx(() => controller.hasSpecialProfile.value
                  ? Text(
                      "${controller.userBalance.value.toStringAsFixed(0)} ŞAÝ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.greyColor,
                      ),
                    )
                  : const SizedBox.shrink()),
              SvgPicture.asset(
                IconConstants.expandMore,
                width: 24,
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageShimmer() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.6),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          color: Colors.grey[200]!.withOpacity(value),
        );
      },
      onEnd: () {},
    );
  }
}
