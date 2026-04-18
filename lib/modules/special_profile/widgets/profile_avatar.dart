import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/modules/settings_profile/controllers/settings_controller.dart';

class ProfileAvatar extends StatelessWidget {
  final SpecialProfileController controller;
  const ProfileAvatar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController =
        Get.find<SettingsController>();
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              children: [
                Obx(
                  () => Container(
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: controller.selectedProfileImage.value !=
                              null
                          ? FileImage(controller.selectedProfileImage.value!)
                          : (controller.profile.value.imageUrl != null
                              ? NetworkImage(controller.profile.value.imageUrl!)
                              : null),
                      child: controller.isUploadingProfileImage.value
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.4),
                            )
                          : (controller.selectedProfileImage.value == null &&
                                  controller.profile.value.imageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 50,
                                )
                              : null),
                    ),
                  ),
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
}
