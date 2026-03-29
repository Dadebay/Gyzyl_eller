import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/modules/special_profile/widgets/bio_section.dart';
import 'package:gyzyleller/modules/special_profile/widgets/profile_header.dart';
import 'package:gyzyleller/modules/special_profile/widgets/reviews_section.dart';
import 'package:gyzyleller/modules/special_profile/widgets/special_profile_app_bar.dart';
import '../widgets/works_section.dart';

class SpecialProfile extends StatelessWidget {
  SpecialProfile({super.key});
  final SpecialProfileController controller =
      Get.put(SpecialProfileController(), permanent: true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SpecialProfileAppBar(),
      body: Obx(
        () => Container(
          color: ColorConstants.background,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileHeader(
                name: controller.profile.value.name ?? '',
                imageUrl: controller.profile.value.imageUrl,
                shortBio: controller.profile.value.shortBio ?? '',
              ),
              const SizedBox(height: 16),
              BioSection(
                  longBio: controller.profile.value.longBio ?? '',
                  province:
                      controller.profile.value.welayatId?.toString() ?? ''),
              const SizedBox(height: 16),
              WorksSection(
                images: controller.images,
                serverImages: controller.profile.value.serverImages,
              ),
              const SizedBox(height: 16),
              const ReviewsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
