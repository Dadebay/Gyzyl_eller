import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class WorksSection extends StatelessWidget {
  final List<File> images;

  const WorksSection({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
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
                child: Text("${'works_section_title'.tr} ${images.length}",
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
            itemCount: images.length > 4 ? 4 : images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(images[index], fit: BoxFit.cover),
              );
            },
          ),
        ],
      ),
    );
  }
}
