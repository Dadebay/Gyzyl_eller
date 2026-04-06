// ignore_for_file: use_build_context_synchronously, deprecated_member_use

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
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (pickedFiles.isEmpty) return;
    for (var file in pickedFiles) {
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
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null) return;
    for (var file in result.files) {
      if (file.path == null) continue;
      final String ext = file.extension?.toLowerCase() ?? '';
      final List<String> allowed = ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'];
      if (!allowed.contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${file.name} - geГ§ersiz format'),
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
                  const SizedBox(height: 5),
                  const Text(
                    'PNG, JPG, PDF, DOC',
                    style: TextStyle(
                        color: ColorConstants.secondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ---------------- Files List ----------------
        if (uploadedFiles.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: uploadedFiles.map((file) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.insert_drive_file,
                            size: 22, color: ColorConstants.kPrimaryColor2),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            file["name"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeFile(file),
                          child: const Icon(Icons.close, size: 16),
                        ),
                      ],
                    ),
                  ),
                  if (file["loading"] == true) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: file["progress"],
                          minHeight: 3,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: const AlwaysStoppedAnimation(
                              ColorConstants.kPrimaryColor2),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

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
                      child: img["path"] != null
                          ? Image.file(
                              File(img["path"] as String),
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildImageError();
                              },
                            )
                          : CachedNetworkImage(
                              imageUrl: img["url"] ?? "",
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[200],
                              ),
                              errorWidget: (context, url, _) =>
                                  _buildImageError(),
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
                            '${img["size"]} / ${img["loading"] ? "loading" : "complete"}',
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
                                img["loading"] == true
                                    ? ColorConstants.kPrimaryColor2
                                    : Colors.green,
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

  Widget _buildImageError() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
