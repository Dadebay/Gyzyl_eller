import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/modules/special_profile/widgets/file_upload_area.dart';
import 'package:gyzyleller/modules/special_profile/widgets/info_card.dart';
import 'package:gyzyleller/modules/special_profile/widgets/profile_avatar.dart';

class SpecialProfileEditView extends StatefulWidget {
  const SpecialProfileEditView({super.key});

  @override
  State<SpecialProfileEditView> createState() => _SpecialProfileEditViewState();
}

class _SpecialProfileEditViewState extends State<SpecialProfileEditView> {
  final SpecialProfileController controller =
      Get.find<SpecialProfileController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController shortBioController = TextEditingController();
  final TextEditingController longBioController = TextEditingController();
  final TextEditingController workTejribeController = TextEditingController();

  String? _selectedLegalizationType;

  static const List<String> _legalizationValues = [
    'entrepreneur',
    'individual',
    'private',
    'business_entity',
  ];

  @override
  void initState() {
    super.initState();
    nameController.text = controller.profile.value.name ?? '';
    shortBioController.text = controller.profile.value.shortBio ?? '';
    longBioController.text = controller.profile.value.longBio ?? '';
    _selectedLegalizationType = controller.profile.value.legalizationType;
  }

  @override
  void dispose() {
    nameController.dispose();
    shortBioController.dispose();
    longBioController.dispose();
    workTejribeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios,
              color: ColorConstants.kPrimaryColor2),
        ),
        title: Text(
          "Hünärmen profilim".tr,
          style: const TextStyle(
            color: ColorConstants.fonts,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Get.snackbar("Delete", "Delete action triggered");
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          )
        ],
      ),
      backgroundColor: ColorConstants.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEditableHeader(),
          const SizedBox(height: 16),
          _buildEditableBioSection(),
          const SizedBox(height: 15),
          InfoCard(
            icon: Icons.access_time,
            text: 'read_the_rules'.tr,
            color: ColorConstants.whiteColor,
            textColor: ColorConstants.fonts,
          ),
          const SizedBox(height: 16),
          _buildEditableWorksSection(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            controller.saveMasterProfile(
              name: nameController.text,
              shortBio: shortBioController.text,
              longBio: longBioController.text,
              legalizationType: _selectedLegalizationType ?? '',
              isEdit: true,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.kPrimaryColor2,
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            "save_changes".tr,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableHeader() {
    return Column(
      children: [
        ProfileAvatar(controller: controller, nameController: nameController),
        const SizedBox(height: 30),
        _buildTextField(
          controller: shortBioController,
          hint: "short_bio_hint".tr,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 8),
        _buildLegalizationDropdown(),
        const SizedBox(height: 8),
        _buildTextField(
          controller: workTejribeController,
          hint: "work_tejribe".tr,
          icon: Icons.work_outline,
        ),
      ],
    );
  }

  Widget _buildEditableBioSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: longBioController,
            hint: "long_bio_hint".tr,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableWorksSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('works_section_title'.tr,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.fonts)),
            ],
          ),
          const SizedBox(height: 10),
          const FileUploadSection(),
        ],
      ),
    );
  }

  Widget _buildLegalizationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedLegalizationType,
          hint: Text(
            'legalization_type_hint'.tr,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: ColorConstants.kPrimaryColor2),
          dropdownColor: Colors.white,
          items: _legalizationValues.map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.tr),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLegalizationType = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: ColorConstants.whiteColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        ),
      ),
    );
  }
}
