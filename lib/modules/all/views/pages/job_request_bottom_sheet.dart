// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/all/controllers/job_detail_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';

class JobRequestBottomSheet extends StatelessWidget {
  const JobRequestBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final JobDetailController controller = Get.find<JobDetailController>();

    return Obx(() {
      if (controller.showingTemplates.value) {
        return _buildTemplatesView(controller);
      }

      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          // top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Close Button
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Get.back(),
                ),
              ),

              // Illustration
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SvgPicture.asset(
                  IconConstants.teklipugrat,
                  height: 120,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "send_offer_title".tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                "send_offer_desc".tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    color: ColorConstants.secondary,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: ColorConstants.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: controller.priceController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: "0",
                    hintStyle: TextStyle(
                      color: ColorConstants.secondary,
                    ),
                    suffixText: " TMT",
                    suffixStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 15),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Comment Input
              Container(
                decoration: BoxDecoration(
                  color: ColorConstants.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: controller.commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "comment_hint".tr,
                    hintStyle: const TextStyle(
                      color: ColorConstants.secondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              if (controller.showSuccessBanner.value) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "template_saved_msg".tr,
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 16, color: Color(0xFF2E7D32)),
                        onPressed: () =>
                            controller.showSuccessBanner.value = false,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Template and Save buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: ElevatedButton(
                        onPressed: () =>
                            controller.showingTemplates.value = true,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E5BB8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "templates".tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      child: ElevatedButton(
                        onPressed:
                            controller.currentCommentText.value.trim().isEmpty
                                ? null
                                : () => controller.saveTemplate(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.showSuccessBanner.value
                              ? const Color(0xFFE0E0E0)
                              : ColorConstants.kPrimaryColor2,
                          disabledBackgroundColor:
                              ColorConstants.kPrimaryColor2.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "save_template".tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: controller.showSuccessBanner.value
                                ? Colors.grey
                                : Colors.white.withOpacity(controller
                                        .currentCommentText.value
                                        .trim()
                                        .isEmpty
                                    ? 0.7
                                    : 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Submit Button
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.submitJobRequest(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.kPrimaryColor2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "send_offer_title".tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTemplatesView(JobDetailController controller) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      height: Get.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => controller.showingTemplates.value = false,
              ),
               Expanded(
                child: Center(
                  child: Text(
                    "templates".tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingTemplates.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ColorConstants.kPrimaryColor2,
                  ),
                );
              }

              if (controller.templates.isEmpty) {
                return  Center(
                  child: Text(
                    "no_templates".tr,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: controller.templates.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final template = controller.templates[index];
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => controller.selectTemplate(template),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(right: 10, top: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F7FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                template.comment,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => controller.deleteTemplate(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
