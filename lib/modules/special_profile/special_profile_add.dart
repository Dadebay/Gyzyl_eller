import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';
import 'package:gyzyleller/shared/widgets/custom_elevated_button.dart';

class SpecialProfileAdd extends StatefulWidget {
  const SpecialProfileAdd({super.key});

  @override
  State<SpecialProfileAdd> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<SpecialProfileAdd> {
  final TextEditingController _shortBioController = TextEditingController();
  final TextEditingController _longBioController = TextEditingController();
  String? _selectedProvince;

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
        title: 'Hünärmen profilm'.tr,
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
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/150'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Kerwen Myradow',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(
              controller: _shortBioController,
              hintText: 'Gysgaça özüň barada',
            ),
            const SizedBox(height: 15),

            // Vilayet Seçimi
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

            // Geniş Özgeçmiş Alanı
            _buildTextField(
              controller: _longBioController,
              hintText: 'Ginişleyin özüňiz hakda ýazyň',
              maxLines: 5,
            ),
            const SizedBox(height: 20),

            _buildInfoCard(
              icon: Icons.access_time,
              text: 'Düzgünnamany hökman okap tanyşyň',
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
                        const TextSpan(text: 'Ähli şertleri bilen '),
                        TextSpan(
                          text: 'ylalaşýan',
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
            const Text(
              'Işlerim, diplomlarym, sertifikatlarym',
              style: TextStyle(
                fontSize: 14,
                color: ColorConstants.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildFileUploadArea(),
            const SizedBox(height: 100),
            CustomElevatedButton(
              onPressed: () {},
              text: 'continue_button'.tr,
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
    return DottedBorder(
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
              'Click to upload',
              style:
                  TextStyle(color: ColorConstants.kPrimaryColor2, fontSize: 12),
            ),
            const SizedBox(height: 5),
            Text(
              'PNG, JPG',
              style: TextStyle(color: ColorConstants.secondary, fontSize: 12),
            ),
            Text(
              '(max, 800 X 800px) 2/8',
              style: TextStyle(color: ColorConstants.secondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
