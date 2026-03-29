import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';

class SelectedImages extends StatelessWidget {
  final SpecialProfileController controller;
  const SelectedImages({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.images.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.images.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  controller.images[index],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
