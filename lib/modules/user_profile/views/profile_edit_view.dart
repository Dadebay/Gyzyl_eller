import 'package:gyzyleller/core/constants/list_constants.dart';
import 'package:gyzyleller/modules/home/controllers/home_controller.dart';
import 'package:gyzyleller/modules/home/views/bottomnavbar/custom_bottom_nav_extension.dart';
import 'package:gyzyleller/modules/user_profile/controllers/settings_controller.dart';
import 'package:gyzyleller/modules/user_profile/controllers/user_profile_controller.dart';
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
            _buildInputField(
              controller: _nameController,
              label: 'your_name_label'.tr,
              readOnly: false,
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.kPrimaryColor2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
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
