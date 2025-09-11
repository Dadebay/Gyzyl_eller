import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/all/controllers/job_detail_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

class JobDetailsPage extends GetView<JobDetailController> {
  JobDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(JobDetailController());
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Giňişleýin'.tr,
        showBackButton: true,
        centerTitle: true,
        showElevation: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateCard(controller),
                  const SizedBox(height: 16),
                  Text(
                    'Işiň gysgaça ady'.tr,
                    style: TextStyle(
                        color: ColorConstants.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        controller.jobShortTitle.value,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    controller: controller,
                    title: controller.jobAdditionalInfoTitle.value,
                    content: controller.jobAdditionalInfoContent.value,
                    isAdditional: true,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    controller: controller,
                    title: controller.jobNeededTitle.value,
                    content: controller.jobNeededContent.value,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Faýllar we suratlar'.tr,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.blue),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Column(
                        children: controller.jobFiles
                            .map((file) => _buildFileItem(file))
                            .toList(),
                      )),
                  const SizedBox(height: 16),
                  _buildImageGallery(controller),
                  const SizedBox(height: 24),
                  Text(
                    'Başga maglumatlar'.tr,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 12),
                  _buildOtherInfoSection(),
                  const SizedBox(height: 16),
                  _buildPriceInfo(),
                ],
              ),
            ),
          ),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildDateCard(JobDetailController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SvgPicture.asset(IconConstants.calendar),
          const SizedBox(width: 5),
          Obx(() => Text(
                controller.jobDate.value,
                style: TextStyle(
                    color: ColorConstants.fonts,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              )),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required JobDetailController controller,
    required String title,
    required String content,
    bool isAdditional = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorConstants.fonts,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: ColorConstants.fonts,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(String fileName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.description, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Text(
            fileName,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(JobDetailController controller) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: controller.pageController,
            itemCount: controller.pageCount,
            itemBuilder: (context, pageIndex) {
              final int firstIndex = pageIndex * 2;
              final int secondIndex = firstIndex + 1;

              return Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          controller.jobImages[firstIndex],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  if (secondIndex < controller.jobImages.length)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            controller.jobImages[secondIndex],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(child: SizedBox()),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(controller.pageCount, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: controller.currentPage.value == index ? 20 : 6,
                  decoration: BoxDecoration(
                    color: controller.currentPage.value == index
                        ? Colors.red
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            )),
      ],
    );
  }

  Widget _buildOtherInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.background,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOtherInfoRow(Icons.access_time_filled, 'Täze'.tr),
          Divider(height: 1, color: Colors.grey[200]),
          _buildOtherInfoRow(Icons.calendar_today, '24.05.2023 - 28.05.2023',
              trailingText: 'işiň senesi'.tr),
          Divider(height: 1, color: Colors.grey[200]),
          _buildOtherInfoRow(
              Icons.work_outline, 'Santehnika we Elektrikler / Aşhana'.tr,
              trailingWidget: Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  Text('10',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  SizedBox(width: 8),
                  Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[600]),
                  Text('48',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildOtherInfoRow(IconData icon, String text,
      {String? trailingText, Widget? trailingWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          if (trailingWidget != null) trailingWidget,
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Açık mavi arka plan
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue[900], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Işiň bahasy 10%. Müşderi tarapyndan saýlanan bolsaňyz, pul balansyňyzdan alnar.'
                  .tr,
              style: TextStyle(color: Colors.blue[900], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SizedBox(
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
            'Teklip etmek'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
