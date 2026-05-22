// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/settings_controller.dart';
import 'package:gyzyleller/modules/special_profile/widgets/full_screen_image_page.dart';

class ProfileAvatar extends StatelessWidget {
  final SpecialProfileController controller;
  const ProfileAvatar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController =
        Get.isRegistered<SettingsController>()
            ? Get.find<SettingsController>()
            : Get.put(SettingsController());
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              children: [
                Obx(
                  () {
                    final imageUrl = controller.profile.value.imageUrl;
                    final hasNetworkImage =
                        imageUrl != null && imageUrl.isNotEmpty;
                    return GestureDetector(
                      onTap: hasNetworkImage
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FullScreenImagePage(imageUrl: imageUrl),
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (controller.selectedProfileImage.value ==
                                      null &&
                                  !hasNetworkImage)
                              ? ColorConstants.noUserBackground[(int.tryParse(
                                          controller.profile.value.id ?? '0') ??
                                      0) %
                                  4]
                              : Colors.grey[200],
                        ),
                        child: ClipOval(
                          child: controller.isUploadingProfileImage.value
                              ? const Center(
                                  child: SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.4),
                                  ),
                                )
                              : (controller.selectedProfileImage.value != null
                                  ? Image.file(
                                      controller.selectedProfileImage.value!,
                                      fit: BoxFit.cover,
                                    )
                                  : (hasNetworkImage
                                      ? CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              _buildInitial(
                                                  settingsController, 45),
                                        )
                                      : _buildInitial(settingsController, 45))),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () {
                      controller.showEditOptions();
                    },
                    child: Container(
                      height: 34,
                      width: 34,
                      decoration: BoxDecoration(
                        color: ColorConstants.kPrimaryColor2,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: ColorConstants.whiteColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Obx(
            () => Text(
              settingsController.user.value?['username'] ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColorConstants.fonts,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitial(SettingsController settingsController, double fontSize) {
    return Center(
      child: Text(
        () {
          final n = (settingsController.user.value?['username'] ?? '')
              .toString()
              .trim();
          if (n.isEmpty) return '?';
          for (int i = 0; i < n.length; i++) {
            final char = n[i];
            if (RegExp(r'[a-zA-Z0-9\u0400-\u04FF]').hasMatch(char)) {
              return char.toUpperCase();
            }
          }
          return n[0].toUpperCase();
        }(),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
