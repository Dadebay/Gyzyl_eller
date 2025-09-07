import 'dart:io';

import 'package:flutter_svg/svg.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/custom_elevated_button.dart';

import 'special_profile.dart';

class SpecialProfileAdd extends StatefulWidget {
  final String name;
  final String? imageUrl;

  const SpecialProfileAdd({super.key, required this.name, this.imageUrl});

  @override
  State<SpecialProfileAdd> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<SpecialProfileAdd> {
  final TextEditingController _shortBioController = TextEditingController();
  final TextEditingController _longBioController = TextEditingController();
  String? _selectedProvince;
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  bool _termsAccepted = false;

  @override
  void dispose() {
    _shortBioController.dispose();
    _longBioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(widget.imageUrl ?? ''),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(
              controller: _shortBioController,
              hintText: 'short_bio_hint'.tr,
            ),
            const SizedBox(height: 15),
            _buildDropdownField(
              hintText: 'Welaýat',
              value: _selectedProvince,
              items: ['Ahal', 'Balkan', 'Daşoguz', 'Lebap', 'Mary']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProvince = newValue;
                });
              },
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _longBioController,
              hintText: 'long_bio_hint'.tr,
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.access_time,
              text: 'read_the_rules'.tr,
              color: ColorConstants.whiteColor,
              textColor: ColorConstants.fonts,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Transform.scale(
                  scale: 1.4,
                  child: Checkbox(
                    value: _termsAccepted,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _termsAccepted = newValue ?? false;
                      });
                    },
                    activeColor: ColorConstants.whiteColor,
                    fillColor: WidgetStateProperty.all(Colors.white),
                    checkColor: ColorConstants.kPrimaryColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(
                      color: ColorConstants.whiteColor,
                      width: 2,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: ColorConstants.fonts, fontSize: 15),
                      children: [
                        TextSpan(text: 'i_agree_with'.tr),
                        TextSpan(
                          text: 'all_the_terms'.tr,
                          style: const TextStyle(
                            color: ColorConstants.kPrimaryColor2,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.red,
                            decorationThickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
            _buildFileUploadArea(),
            const SizedBox(height: 10),
            _buildSelectedImages(),
            const SizedBox(height: 25),
            CustomElevatedButton(
              onPressed: () {
                Get.to(() => SpecialProfile(
                      name: widget.name,
                      imageUrl: widget.imageUrl,
                      shortBio: _shortBioController.text,
                      longBio: _longBioController.text,
                      province: _selectedProvince ?? '',
                      images: _selectedImages,
                    ));
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

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 8) {
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
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

  Widget _buildFileUploadArea() {
    return GestureDetector(
      onTap: _pickImage,
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
              Text(
                '${'max_file_size'.tr} ${_selectedImages.length}/8',
                style: TextStyle(color: ColorConstants.secondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImages() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(
                _selectedImages[index],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
