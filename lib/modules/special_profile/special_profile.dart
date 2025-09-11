import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'widgets/profile_header.dart';
import 'widgets/bio_section.dart';
import 'widgets/works_section.dart';
import 'widgets/reviews_section.dart';
import 'package:gyzyleller/modules/special_profile/widgets/special_profile_app_bar.dart';

class SpecialProfile extends StatelessWidget {
  SpecialProfile({super.key});
  final SpecialProfileController controller =
      Get.put(SpecialProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SpecialProfileAppBar(),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileHeader(
              name: controller.name.value,
              imageUrl: controller.imageUrl.value,
              shortBio: controller.shortBio.value,
            ),
            const SizedBox(height: 16),
            BioSection(
                longBio: controller.longBio.value,
                province: controller.province.value),
            const SizedBox(height: 16),
            WorksSection(images: controller.images),
            const SizedBox(height: 16),
            const ReviewsSection(),
          ],
        ),
      ),
    );
  }
}
