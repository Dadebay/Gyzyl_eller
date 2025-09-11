import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';

class ProfileAvatar extends StatelessWidget {
  final SpecialProfileController controller;
  const ProfileAvatar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() => CircleAvatar(
            radius: 50,
            backgroundImage: controller.imageUrl.value != null
                ? NetworkImage(controller.name.value)
                : null,
          )),
    );
  }
}
