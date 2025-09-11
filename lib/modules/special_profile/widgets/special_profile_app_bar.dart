import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';

class SpecialProfileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  SpecialProfileAppBar({super.key});
  final SpecialProfileController controller =
      Get.find<SpecialProfileController>();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorConstants.background,
      title: Text(
        "specialist_profile_title".tr,
        style: TextStyle(color: ColorConstants.fonts),
      ),
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        iconSize: 20,
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.arrow_back_ios,
          color: ColorConstants.kPrimaryColor2,
        ),
      ),
      foregroundColor: Colors.black,
      actions: [
        IconButton(
          onPressed: () {},
          iconSize: 20,
          padding: EdgeInsets.zero,
          icon: SvgPicture.asset(
            IconConstants.edit,
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
