// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_local_variable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class FileUploadSection extends StatefulWidget {
  final List<Map<String, dynamic>>? initialFiles;
  final Function(bool hasFiles)? onFilesChanged;
  final Function(List<String> urls)? onUrlsUploaded;
  final Function(List<Map<String, dynamic>> metadata)? onMetadataChanged;

  const FileUploadSection({
    super.key,
    this.initialFiles,
    this.onFilesChanged,
    this.onUrlsUploaded,
    this.onMetadataChanged,
  });

  @override
  State<FileUploadSection> createState() => _FileUploadSectionState();
}

class _FileUploadSectionState extends State<FileUploadSection> {
  final List<Map<String, dynamic>> images = [];
  final List<Map<String, dynamic>> uploadedFiles = [];
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  final List<Map<String, dynamic>> allDeletedFiles = [];
  bool _isProcessingQueue = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFiles != null) {
      for (var f in widget.initialFiles!) {
        final String name = f["filename"] ?? f["name"] ?? "file";
        final String? url = f["url"];
        final bool isImage = _isImageFile(name);

        final Map<String, dynamic> item = {
          ...f,
          "name": name,
          "loading": false,
          "progress": 1.0,
          "isInitial": true,
        };

        if (isImage) {
          images.add(item);
        } else {
          uploadedFiles.add(item);
        }
      }
    }
  }

  bool _isImageFile(String filename) {
    final String ext = filename.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext);
  }

  Future<void> _processUploadQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    while (true) {
      Map<String, dynamic>? nextItem;

      final pendingFile =
          uploadedFiles.cast<Map<String, dynamic>?>().firstWhere(
                (f) => f != null && f["loading"] == true && f["url"] == null,
                orElse: () => null,
              );
      if (pendingFile != null) {
        nextItem = pendingFile;
      } else {
        final pendingImage = images.cast<Map<String, dynamic>?>().firstWhere(
              (img) =>
                  img != null && img["loading"] == true && img["url"] == null,
              orElse: () => null,
            );
        if (pendingImage != null) nextItem = pendingImage;
      }

      if (nextItem == null) break;
      await _uploadFile(nextItem);
    }

    _isProcessingQueue = false;
  }

  Future<void> _uploadFile(Map<String, dynamic> fileMap) async {
    try {
      final String path = fileMap["path"] as String;
      final url = await _apiService.uploadFile(
        path,
        onSendProgress: (sent, total) {
          if (!mounted) return;
          setState(() {
            fileMap["progress"] = total > 0 ? sent / total : 0.0;
          });
        },
      );

      if (!mounted) return;
      setState(() {
        fileMap["loading"] = false;
        fileMap["progress"] = 1.0;
        fileMap["url"] = url;
      });
      _notifyParent();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        uploadedFiles.remove(fileMap);
        images.remove(fileMap);
      });
      _notifyParent();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${fileMap["name"]} - ГЅГјklenip bilinmedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _notifyParent() {
    final bool hasAny = uploadedFiles.isNotEmpty || images.isNotEmpty;
    widget.onFilesChanged?.call(hasAny);

    if (widget.onUrlsUploaded != null) {
      final List<String> urls = [];
      for (var f in uploadedFiles) {
        if (f["url"] != null) urls.add(f["url"] as String);
      }
      for (var img in images) {
        if (img["url"] != null) urls.add(img["url"] as String);
      }
      widget.onUrlsUploaded!(urls);
    }

    if (widget.onMetadataChanged != null) {
      final List<Map<String, dynamic>> metadata = [];
      metadata.addAll(uploadedFiles);
      metadata.addAll(images);
      metadata.addAll(allDeletedFiles);
      widget.onMetadataChanged!(metadata);
    }
  }

  Future<void> _pickImages() async {
    // Check total file count limit (16 max)
    final int currentTotal = images.length + uploadedFiles.length;
    if (currentTotal >= 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('max_files_limit'.tr),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (pickedFiles.isEmpty) return;

    // Calculate how many files can be added
    final int availableSlots = 16 - currentTotal;
    final List<XFile> filesToAdd = pickedFiles.take(availableSlots).toList();

    if (pickedFiles.length > availableSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('max_files_limit_reached'.tr),
          backgroundColor: Colors.orange,
        ),
      );
    }

    for (var file in filesToAdd) {
      final int bytes = await file.length();
      final Map<String, dynamic> newImage = {
        "name": file.name,
        "size": "${(bytes / 1024).toStringAsFixed(0)} kb",
        "progress": 0.0,
        "loading": true,
        "path": file.path,
        "url": null,
      };
      setState(() => images.add(newImage));
    }
    _processUploadQueue();
  }

  Future<void> _pickFiles() async {
    // Check total file count limit (16 max)
    final int currentTotal = images.length + uploadedFiles.length;
    if (currentTotal >= 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('max_files_limit'.tr),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null) return;

    // Calculate how many files can be added
    final int availableSlots = 16 - currentTotal;
    int addedCount = 0;

    for (var file in result.files) {
      if (addedCount >= availableSlots) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('max_files_limit_reached'.tr),
            backgroundColor: Colors.orange,
          ),
        );
        break;
      }

      if (file.path == null) continue;
      final String ext = file.extension?.toLowerCase() ?? '';
      final List<String> allowed = ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'];
      if (!allowed.contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${file.name} - geçersiz format'),
            backgroundColor: Colors.red,
          ),
        );
        continue;
      }
      final Map<String, dynamic> newFile = {
        "name": file.name,
        "size": "${(file.size / 1024).toStringAsFixed(0)} kb",
        "type": ext,
        "progress": 0.0,
        "loading": true,
        "path": file.path,
        "url": null,
      };
      setState(() => uploadedFiles.add(newFile));
      addedCount++;
    }
    _processUploadQueue();
  }

  void _removeImage(Map<String, dynamic> image) {
    setState(() {
      images.remove(image);
      if (image["isInitial"] == true) {
        allDeletedFiles.add({...image, "deleted": true});
      }
    });
    _notifyParent();
  }

  void _removeFile(Map<String, dynamic> file) {
    setState(() {
      uploadedFiles.remove(file);
      if (file["isInitial"] == true) {
        allDeletedFiles.add({...file, "deleted": true});
      }
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------- Upload Box ----------------
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (ctx) => Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.image,
                          color: ColorConstants.kPrimaryColor2),
                      title: Text('pick_image'.tr),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImages();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.insert_drive_file,
                          color: ColorConstants.kPrimaryColor2),
                      title: Text('pick_file'.tr),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickFiles();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
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
                  const SizedBox(height: 3),
                  const Text(
                    'PNG, JPG, PDF, DOC',
                    style: TextStyle(
                        color: ColorConstants.secondary, fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'click_to_upload_max'.tr,
                    style: const TextStyle(
                        color: ColorConstants.kPrimaryColor2, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ---------------- Documents List ----------------
        if (uploadedFiles.isNotEmpty) ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: uploadedFiles.length,
            itemBuilder: (context, index) {
              final file = uploadedFiles[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined,
                        size: 28, color: ColorConstants.kPrimaryColor2),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file["name"] ?? 'file',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.blackColor,
                            ),
                          ),
                          if (file["size"] != null)
                            Text(
                              file["size"] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    ColorConstants.blackColor.withOpacity(0.4),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (file["loading"] == true)
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: file["progress"],
                              strokeWidth: 2,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation(
                                  ColorConstants.kPrimaryColor2),
                            ),
                          ],
                        ),
                      )
                    else
                      IconButton(
                        onPressed: () => _removeFile(file),
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
        ],

        // ---------------- Images List ----------------
        if (images.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show first 4 images in a 2x2 grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final img = images[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: img["path"] != null
                            ? Image.file(
                                File(img["path"] as String),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildImageError();
                                },
                              )
                            : CachedNetworkImage(
                                imageUrl: img["url"] ?? "",
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                ),
                                errorWidget: (context, url, _) =>
                                    _buildImageError(),
                              ),
                      ),
                      // Loading indicator
                      if (img["loading"] == true)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: img["progress"],
                                strokeWidth: 3,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation(
                                    ColorConstants.kPrimaryColor2),
                              ),
                            ),
                          ),
                        ),
                      // Delete button
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => _removeImage(img),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              // "View All" button if more than 4 images
            ],
          ),
      ],
    );
  }

  Widget _buildImageError() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
