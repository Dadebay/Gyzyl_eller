import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/services/api_constants.dart';

class WorksSection extends StatelessWidget {
  final List<File> images;
  final List<String> serverImages;

  const WorksSection({super.key, required this.images, required this.serverImages});

  @override
  Widget build(BuildContext context) {
    final totalCount = images.length + serverImages.length;
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.background,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text("${'works_section_title'.tr} $totalCount",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.fonts)),
              ),
              Text("view_all_button".tr,
                  style: const TextStyle(color: ColorConstants.blue)),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCount > 4 ? 4 : totalCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              if (index < serverImages.length) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    ApiConstants.imageURL + serverImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                );
              } else {
                final fileIndex = index - serverImages.length;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(images[fileIndex], fit: BoxFit.cover),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
