import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';

class ProfileAvatar extends StatelessWidget {
  final SpecialProfileController controller;
  final TextEditingController? nameController;
  const ProfileAvatar(
      {super.key, required this.controller, this.nameController});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              children: [
                Obx(
                  () => CircleAvatar(
                    radius: 50,
                    backgroundImage: controller.selectedProfileImage.value !=
                            null
                        ? FileImage(controller.selectedProfileImage.value!)
                        : (controller.profile.value.imageUrl != null
                            ? NetworkImage(controller.profile.value.imageUrl!)
                            : null),
                    child: controller.selectedProfileImage.value == null &&
                            controller.profile.value.imageUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: controller.showEditOptions,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: ColorConstants.redColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => GestureDetector(
              onTap: () {
                controller.toggleEditName(nameController?.text);
              },
              child: controller.isEditingName.value && nameController != null
                  ? SizedBox(
                      width: 150,
                      child: TextField(
                        controller: nameController,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                        onSubmitted: (newValue) {
                          controller.toggleEditName(newValue);
                        },
                      ),
                    )
                  : Text(
                      controller.profile.value.name ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
