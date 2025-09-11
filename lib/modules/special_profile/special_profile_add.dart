import 'dart:io';

import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/custom_elevated_button.dart';

import 'special_profile.dart';

class SpecialProfileAdd extends StatelessWidget {
  SpecialProfileAdd({super.key});
  final SpecialProfileController controller =
      Get.put(SpecialProfileController());
  @override
  Widget build(BuildContext context) {
    final TextEditingController _shortBioController =
        TextEditingController(text: controller.shortBio.value);
    final TextEditingController _longBioController =
        TextEditingController(text: controller.longBio.value);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'specialist_profile_title'.tr,
        showBackButton: true,
        centerTitle: true,
        showElevation: false,
      ),
      backgroundColor: ColorConstants.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  Obx(() => CircleAvatar(
                        radius: 50,
                        backgroundImage: controller.imageUrl.value != null
                            ? NetworkImage(controller.name.value)
                            : null,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Obx(() => Text(
                    controller.name.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ),
            const SizedBox(height: 30),
            _buildTextField(
              controller: _shortBioController,
              hintText: 'short_bio_hint'.tr,
              onChanged: (value) => controller.shortBio.value = value,
            ),
            const SizedBox(height: 15),
            Obx(() => _buildDropdownField(
                  hintText: 'Welaýat',
                  value: controller.province.value.isEmpty
                      ? null
                      : controller.province.value,
                  items: ['Ahal', 'Balkan', 'Daşoguz', 'Lebap', 'Mary']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    controller.province.value = newValue ?? '';
                  },
                )),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _longBioController,
              hintText: 'long_bio_hint'.tr,
              maxLines: 5,
              onChanged: (value) => controller.longBio.value = value,
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.access_time,
              text: 'read_the_rules'.tr,
              color: ColorConstants.whiteColor,
              textColor: ColorConstants.fonts,
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Text(
              'my_works_title'.tr,
              style: TextStyle(
                fontSize: 14,
                color: ColorConstants.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildFileUploadArea(controller),
            const SizedBox(height: 10),
            _buildSelectedImages(controller),
            const SizedBox(height: 25),
            CustomElevatedButton(
              onPressed: () {
                Get.to(() => SpecialProfile());
              },
              text: 'create_account_button'.tr,
              backgroundColor: ColorConstants.kPrimaryColor2,
              textColor: Colors.white,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hintText),
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.red),
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorConstants.kPrimaryColor2),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadArea(SpecialProfileController controller) {
    return GestureDetector(
      onTap: () => controller.pickImage(),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        dashPattern: const [6, 3],
        color: Colors.grey.shade400,
        strokeWidth: 1.5,
        child: Container(
          color: ColorConstants.whiteColor,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              SvgPicture.asset(
                IconConstants.uploadfoto,
              ),
              const SizedBox(height: 10),
              Text(
                'click_to_upload'.tr,
                style: TextStyle(
                    color: ColorConstants.kPrimaryColor2, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                'PNG, JPG',
                style: TextStyle(color: ColorConstants.secondary, fontSize: 12),
              ),
              Obx(() => Text(
                    '${'max_file_size'.tr} ${controller.images.length}/8',
                    style: TextStyle(
                        color: ColorConstants.secondary, fontSize: 12),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImages(SpecialProfileController controller) {
    return Obx(() => SizedBox(
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
        ));
  }
}
