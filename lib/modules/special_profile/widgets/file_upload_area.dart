// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter_svg/svg.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';

class FileUploadSection extends StatefulWidget {
  const FileUploadSection({super.key});

  @override
  State<FileUploadSection> createState() => _FileUploadSectionState();
}

class _FileUploadSectionState extends State<FileUploadSection> {
  final List<Map<String, dynamic>> images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        final String extension = file.path.split('.').last.toLowerCase();

        if (extension == 'png' || extension == 'jpg' || extension == 'jpeg') {
          final Map<String, dynamic> newImage = {
            "name": file.name,
            "size": "${(await file.length() / 1024).toStringAsFixed(0)} kb",
            "progress": 0.0,
            "loading": true,
            "path": file.path,
          };

          setState(() {
            images.add(newImage);
          });

          _simulateUpload(newImage);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${file.name} - diňe PNG we JPG formatlar kabul edilýär'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _simulateUpload(Map<String, dynamic> image) {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (image["progress"] < 1.0) {
          image["progress"] += 0.1;
        } else {
          image["loading"] = false;
          timer.cancel();
        }
      });
    });
  }

  void _removeImage(Map<String, dynamic> image) {
    setState(() {
      images.remove(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------- Upload Box ----------------
        GestureDetector(
          onTap: _pickImages,
          child: DottedBorder(
            color: ColorConstants.greyColor,
            strokeWidth: 1.5,
            dashPattern: const [6, 5],
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorConstants.whiteColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(IconConstants.uploadfoto),
                  const SizedBox(height: 8),
                  Text(
                    'click_to_upload'.tr,
                    style: const TextStyle(
                        color: ColorConstants.kPrimaryColor2, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'PNG, JPG',
                    style: TextStyle(
                        color: ColorConstants.secondary, fontSize: 12),
                  ),
                  Text(
                    '${'max_file_size'.tr} 2/8',
                    style: const TextStyle(
                        color: ColorConstants.secondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ---------------- Images List ----------------
        if (images.isNotEmpty)
          Column(
            children: images.map((img) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(img["path"]),
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            img["name"],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            img["size"] +
                                (img["loading"] ? " / loading" : " / complete"),
                            style: const TextStyle(
                              color: ColorConstants.greyColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: img["progress"],
                              minHeight: 5,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation(
                                img["loading"]
                                    ? ColorConstants.kPrimaryColor2
                                    : ColorConstants.background,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeImage(img),
                      child: const Icon(Icons.close, size: 22),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
