import 'package:gyzyleller/core/services/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/constants/list_constants.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/home/controllers/home_controller.dart';
import 'package:gyzyleller/modules/home/views/bottomnavbar/custom_bottom_nav_extension.dart';
import 'package:gyzyleller/modules/user_profile/bindings/profile_edit_number_binding.dart';
import 'package:gyzyleller/modules/user_profile/controllers/settings_controller.dart';
import 'package:gyzyleller/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:gyzyleller/modules/user_profile/views/profile_edit_number.dart';
import 'package:gyzyleller/shared/dialogs/dialogs_utils.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

class ProfileEditView extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileEditView({super.key, required this.userData});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(text: '***********');
  final HomeController homeController = Get.find<HomeController>();
  final SettingsController settingsController = Get.find<SettingsController>();
  final UserProfilController userProfilController =
      Get.find<UserProfilController>();
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData['username'] ?? '';
    _phoneController.text = widget.userData['phone'] ?? '';
    userProfilController.selectedImageFile.value = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera, size: 35),
              title:
                  Text('select_by_camera'.tr, style: TextStyle(fontSize: 18)),
              onTap: () async {
                Get.back();
                final XFile? pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                userProfilController.onImageSelected(pickedFile);
              },
            ),
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.image, size: 30),
              ),
              title:
                  Text('select_by_gallery'.tr, style: TextStyle(fontSize: 18)),
              onTap: () async {
                Get.back();
                final XFile? pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                userProfilController.onImageSelected(pickedFile);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: CustomAppBar(
        title: 'my_profile'.tr,
        showBackButton: true,
        centerTitle: true,
        showElevation: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    backgroundImage: widget.userData['image'] != null
                        ? NetworkImage(
                            ApiConstants.imageURL + widget.userData['image'])
                        : null,
                    child: widget.userData['image'] == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: ColorConstants.whiteColor,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          _showImagePickerOptions();
                        },
                        child: Icon(
                          color: ColorConstants.kPrimaryColor2,
                          Icons.camera_alt,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Adınız Girişi
            _buildInputField(
              controller: _nameController,
              label: 'your_name_label'.tr,
              readOnly: false,
            ),
            const SizedBox(height: 15),

            // Telefon Bilginiz Girişi
            _buildInputField(
              controller: _phoneController,
              label: 'your_phone_number_label'.tr,
              readOnly: true,
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Get.to(() => const PhoneNumberInputScreen(),
                    binding: ProfileEditNumberBinding(),
                    arguments: _phoneController.text);
              },
            ),
            const SizedBox(height: 15),

            _buildInputField(
              controller: _passwordController,
              label: 'password_label'.tr,
              obscureText: true,
              readOnly: true,
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {},
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final bool? confirmLogout =
                      await DialogUtils().showDeleteProfileDialog(context);
                  if (confirmLogout == true) {
                    await settingsController.logout();
                  }
                  ;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC7D3E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child:  Text(
                  'delete_my_profile'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Değişiklikleri kaydetme işlemi
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.kPrimaryColor2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child:  Text(
                  'save_changes'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: homeController.bottomNavBarSelectedIndex.value,
        onTap: (index) async {
          homeController.changePage(index);
        },
        selectedIcons: ListConstants.selectedIcons,
        unselectedIcons: ListConstants.mainIcons,
        labels: ["my_tab".tr, "all_tab".tr, "tasks_tab".tr, "menu_tab".tr],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    bool readOnly = false,
    IconData? trailingIcon,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  readOnly: readOnly,
                  onTap: onTap,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: Colors.red,
                  size: 16,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
