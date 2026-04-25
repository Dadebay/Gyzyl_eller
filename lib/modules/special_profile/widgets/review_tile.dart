// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/models/review_model.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'full_screen_image_page.dart';

/// A single review card displayed in the professional profile review section.
class ReviewTile extends StatefulWidget {
  final ReviewModel review;
  final bool? isOwner;

  const ReviewTile({super.key, required this.review, this.isOwner});

  @override
  State<ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends State<ReviewTile> {
  bool _isExpanded = false;
  late List<ReviewReply> _localReplies;

  ReviewModel get review => widget.review;

  @override
  void initState() {
    super.initState();
    _localReplies = List.from(widget.review.replies);
  }

  @override
  void didUpdateWidget(covariant ReviewTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.review != oldWidget.review) {
      _localReplies = List.from(widget.review.replies);
    }
  }

  String get _formattedDate {
    try {
      return DateFormat('dd.MM.yyyy').format(review.createdAt.toLocal());
    } catch (_) {
      return '';
    }
  }

  bool get _isOwner {
    if (Get.isRegistered<SpecialProfileController>()) {
      final ctrl = Get.find<SpecialProfileController>();
      final result = ctrl.isMyProfile;
      print('🔍 [ReviewTile._isOwner] isMyProfile=$result');
      print(
          '🔍 [ReviewTile._isOwner] profile.userId=${ctrl.profile.value.userId}');
      print('🔍 [ReviewTile._isOwner] profile.id=${ctrl.profile.value.id}');
      return result;
    }
    print('🔍 [ReviewTile._isOwner] SpecialProfileController NOT registered');
    return false;
  }

  void _showReplyDialog() {
    final TextEditingController textController = TextEditingController();
    Get.dialog(
      StatefulBuilder(builder: (context, setDialogState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('reply_to_review'.tr,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.fonts)),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  maxLines: 4,
                  maxLength: 300,
                  onChanged: (value) => setDialogState(() {}),
                  decoration: InputDecoration(
                    hintText: 'write_reply'.tr,
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: ColorConstants.background,
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${textController.text.length}/300",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('cancel'.tr,
                          style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (textController.text.trim().isEmpty) return;
                        final savedText = textController.text.trim();
                        Get.back();
                        final success =
                            await Get.find<SpecialProfileController>()
                                .replyToReview(review.id, savedText);
                        if (success && mounted) {
                          setState(() {
                            _localReplies.add(ReviewReply(
                              id: '',
                              reviewId: review.id,
                              reply: savedText,
                              createdAt: DateTime.now(),
                            ));
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.kPrimaryColor2,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('send'.tr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author row: avatar + name + stars ─────────────────────────
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: (review.image != null && review.image!.isNotEmpty)
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                FullScreenImagePage(imageUrl: review.image!),
                          ),
                        );
                      }
                    : null,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      (review.image != null && review.image!.isNotEmpty)
                          ? NetworkImage(review.image!) as ImageProvider
                          : null,
                  child: (review.image == null || review.image!.isEmpty)
                      ? const HugeIcon(
                          icon: HugeIcons.strokeRoundedUser,
                          color: ColorConstants.greyColor,
                          size: 20,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.username,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: ColorConstants.fonts),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Stars
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    color:
                        i < review.rating ? Colors.amber : Colors.grey.shade300,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Review text ───────────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final span = TextSpan(
                text: review.review,
                style: const TextStyle(
                    fontSize: 14, color: ColorConstants.fonts, height: 1.4),
              );
              final tp = TextPainter(
                text: span,
                maxLines: 3,
                textDirection: TextDirection.ltr,
              );
              tp.layout(maxWidth: constraints.maxWidth);

              if (tp.didExceedMaxLines) {
                return RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: _isExpanded
                          ? review.review
                          : "${review.review.substring(0, tp.getPositionForOffset(Offset(constraints.maxWidth, tp.height)).offset - 12)}...",
                      style: const TextStyle(
                          fontSize: 14,
                          color: ColorConstants.fonts,
                          height: 1.4),
                    ),
                    const WidgetSpan(child: SizedBox(width: 5)),
                    TextSpan(
                      text: " ${_isExpanded ? "gizle".tr : "dolyac".tr}",
                      style: const TextStyle(
                          fontSize: 12,
                          color: ColorConstants.blue,
                          fontWeight: FontWeight.w500),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() => _isExpanded = !_isExpanded);
                        },
                    ),
                  ]),
                );
              } else {
                return Text(
                  review.review,
                  style: const TextStyle(
                      fontSize: 14, color: ColorConstants.fonts, height: 1.4),
                );
              }
            },
          ),

          const SizedBox(height: 4),

          // ── Date ──────────────────────────────────────────────────────
          Text(
            _formattedDate,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),

          // ── Master reply (if any) ─────────────────────────────────────
          Builder(builder: (_) {
            print(
                '🔍 [ReviewTile.build] reviewId=${review.id}, _localReplies.length=${_localReplies.length}, _isOwner=$_isOwner');
            return const SizedBox.shrink();
          }),
          if (_localReplies.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(top: 12, left: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColorConstants.background,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.subdirectory_arrow_right_rounded,
                        size: 16,
                        color: ColorConstants.kPrimaryColor2,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'master_reply'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: ColorConstants.kPrimaryColor2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _localReplies.first.reply,
                    style: const TextStyle(
                        fontSize: 14, color: ColorConstants.fonts, height: 1.4),
                  ),
                ],
              ),
            ),
          ] else if (_isOwner) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: _showReplyDialog,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorConstants.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: ColorConstants.secondary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.reply_rounded,
                        size: 16,
                        color: ColorConstants.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'reply'.tr,
                        style: const TextStyle(
                            color: ColorConstants.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer placeholder shown while reviews are loading.
class ReviewTileShimmer extends StatelessWidget {
  const ReviewTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar shimmer
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              // Name shimmer
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              // Stars shimmer
              Container(
                width: 70,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 180,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
