// import 'dart:io';
// import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
// import 'package:gyzyleller/modules/special_profile/widgets/special_profile_form.dart';
// import 'package:gyzyleller/shared/extensions/packages.dart';
// import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

// class SpecialProfileEdit extends StatelessWidget {
//   final String name;
//   final String? imageUrl;
//   final String shortBio;
//   final String longBio;
//   final String province;
//   final List<File> images;

//   SpecialProfileEdit({
//     super.key,
//     required this.name,
//     this.imageUrl,
//     required this.shortBio,
//     required this.longBio,
//     required this.province,
//     required this.images,
//   });
//   final SpecialProfileController specialProfileController =
//       Get.find<SpecialProfileController>();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'edit_specialist_profile'.tr,
//         showBackButton: true,
//         centerTitle: true,
//         showElevation: false,
//       ),
//       body: SpecialProfileForm(
//         submitButtonText: 'save_changes'.tr,
//         initialShortBio: shortBio,
//         initialLongBio: longBio,
//         initialProvince: province,
//         initialImages: images,
//         onSubmit: (newShortBio, newLongBio, newProvince, newImages) {
//           specialProfileController.setProfileData(
//             name: name,
//             imageUrl: imageUrl,
//             shortBio: newShortBio,
//             longBio: newLongBio,
//             province: newProvince ?? '',
//             images: newImages,
//           );
//           Get.back();
//         },
//       ),
//     );
//   }
// }
