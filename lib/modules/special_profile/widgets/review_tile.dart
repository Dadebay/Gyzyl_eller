// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/models/review_model.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:gyzyleller/core/services/api_constants.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';

String _resolveImageUrl(String path) {
  if (path.startsWith('http')) return path;
  final clean = path.startsWith('/') ? path.substring(1) : path;
  return '${ApiConstants.imageURL}$clean';
}

/// A single review card displayed in the professional profile review section.
class ReviewTile extends StatefulWidget {
  final ReviewModel review;
  final bool? isOwner;
  final Future<bool> Function(String reviewId, String replyText)? onReply;
  final Future<bool> Function(String reviewId, String reviewText)? onEditReview;
  final bool hideReplyEdit;

  const ReviewTile({
    super.key,
    required this.review,
    this.isOwner,
    this.onReply,
    this.onEditReview,
    this.hideReplyEdit = false,
  });

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

  Widget _buildInitialAvatar({double size = 16}) {
    return Center(
      child: Text(
        () {
          final name = review.username.trim();
          if (name.isEmpty) return '?';
          for (int i = 0; i < name.length; i++) {
            final char = name[i];
            if (RegExp(r'[a-zA-Z0-9\u0400-\u04FF]').hasMatch(char)) {
              return char.toUpperCase();
            }
          }
          return name[0].toUpperCase();
        }(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  bool get _isOwner {
    if (widget.isOwner != null) return widget.isOwner!;
    if (Get.isRegistered<SpecialProfileController>()) {
      return Get.find<SpecialProfileController>().isMyProfile;
    }
    return false;
  }

  bool get _isAuthor {
    if (!AuthStorage().isLoggedIn) return false;
    final currentUserId = AuthStorage().getUserId()?.toString();
    return review.userId.isNotEmpty && review.userId == currentUserId;
  }

  bool get _isReplyAuthor {
    if (!_isOwner) return false;
    // Reply author is the profile owner (master)
    return true;
  }

  void _showReviewEditDialog() {
    final TextEditingController textController =
        TextEditingController(text: review.review);
    int localRating = review.rating;
    bool isSending = false;
    Get.bottomSheet(
      StatefulBuilder(builder: (context, setDialogState) {
        return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                // bottom:
                //     (MediaQuery.of(context).viewInsets.bottom > 0 ? 30 : 10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('edit_review'.tr,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.fonts)),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: ColorConstants.noUserBackground[
                                    (int.tryParse(review.userId) ?? 0) % 4],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: (review.image != null &&
                                        review.image!.isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            _resolveImageUrl(review.image!),
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            _buildInitialAvatar(size: 18),
                                      )
                                    : _buildInitialAvatar(size: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.username,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: ColorConstants.fonts),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Rating stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        final isFilled = starIndex <= localRating;
                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              localRating = starIndex;
                            });
                          },
                          iconSize: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isFilled ? Icons.star : Icons.star_border,
                            color:
                                isFilled ? Colors.amber : Colors.grey.shade300,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: textController,
                      maxLines: 4,
                      maxLength: 300,
                      onChanged: (value) => setDialogState(() {}),
                      decoration: InputDecoration(
                        hintText: 'write_review'.tr,
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
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
                          onPressed: isSending ? null : () => Get.back(),
                          child: Text('cancel'.tr,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isSending
                              ? null
                              : () async {
                                  if (textController.text.trim().isEmpty)
                                    return;
                                  final savedText = textController.text.trim();
                                  try {
                                    if (review.jobId.isEmpty) {
                                      print('❌ [ReviewTile] jobId is empty!');
                                      setDialogState(() => isSending = false);
                                      return;
                                    }

                                    setDialogState(() => isSending = true);
                                    bool success = false;

                                    final isRegistered = Get.isRegistered<
                                        SpecialProfileController>();
                                    print(
                                        '🔵 [ReviewTile] isRegistered: $isRegistered');

                                    if (isRegistered) {
                                      print(
                                          '🔵 [ReviewTile] Calling editReviewWithRating...');
                                      success = await Get.find<
                                              SpecialProfileController>()
                                          .editReviewWithRating(
                                        review.jobId,
                                        localRating,
                                        savedText,
                                      );
                                      print(
                                          '🔵 [ReviewTile] editReviewWithRating returned: $success');
                                    } else {
                                      print(
                                          '⚠️ [ReviewTile] Controller not registered, trying to call directly...');
                                      // Fallback: call service directly
                                      try {
                                        final response = await MyJobsService()
                                            .editReviewWithRating(
                                          review.jobId,
                                          localRating,
                                          savedText,
                                        );
                                        print(
                                            '🔵 [ReviewTile] Direct service call response: $response');
                                        success = response != null;
                                      } catch (e) {
                                        print(
                                            '❌ [ReviewTile] Direct service call failed: $e');
                                      }
                                    }

                                    if (success) {
                                      print(
                                          '🔵 [ReviewTile] Success! Closing dialog...');

                                      // Optimistic update: Update the review immediately
                                      if (mounted) {
                                        setState(() {
                                          review.review = savedText;
                                        });
                                      }

                                      Get.back();

                                      // Refresh reviews from parent controller in background
                                      if (Get.isRegistered<
                                          SpecialProfileController>()) {
                                        Get.find<SpecialProfileController>()
                                            .fetchReviews();
                                      }
                                    } else {
                                      print(
                                          '❌ [ReviewTile] Failed! Resetting isSending...');
                                      setDialogState(() => isSending = false);
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      setDialogState(() => isSending = false);
                                    }
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
                          child: isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text('save'.tr,
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
            ));
      }),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _showReplyDialog({String? initialText}) {
    final TextEditingController textController =
        TextEditingController(text: initialText);
    bool isSending = false;
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
                      onPressed: isSending ? null : () => Get.back(),
                      child: Text('cancel'.tr,
                          style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              print('🔵 [ReplyDialog] Send button pressed');
                              if (textController.text.trim().isEmpty) {
                                print(
                                    '⚠️ [ReplyDialog] Text is empty, returning');
                                return;
                              }
                              final savedText = textController.text.trim();
                              print('🔵 [ReplyDialog] savedText: "$savedText"');
                              print(
                                  '🔵 [ReplyDialog] review.id: "${review.id}"');
                              print(
                                  '🔵 [ReplyDialog] initialText: $initialText');
                              print(
                                  '🔵 [ReplyDialog] widget.onReply != null: ${widget.onReply != null}');
                              print(
                                  '🔵 [ReplyDialog] SpecialProfileController registered: ${Get.isRegistered<SpecialProfileController>()}');
                              try {
                                setDialogState(() => isSending = true);
                                bool success = false;
                                if (widget.onReply != null) {
                                  print(
                                      '🔵 [ReplyDialog] Calling widget.onReply...');
                                  success = await widget.onReply!(
                                      review.id, savedText);
                                  print(
                                      '🔵 [ReplyDialog] widget.onReply returned: $success');
                                } else if (Get.isRegistered<
                                    SpecialProfileController>()) {
                                  print(
                                      '🔵 [ReplyDialog] Calling replyToReview...');
                                  success =
                                      await Get.find<SpecialProfileController>()
                                          .replyToReview(review.id, savedText);
                                  print(
                                      '🔵 [ReplyDialog] replyToReview returned: $success');
                                } else {
                                  print(
                                      '❌ [ReplyDialog] No handler available! widget.onReply is null and SpecialProfileController not registered');
                                }

                                if (success) {
                                  print(
                                      '✅ [ReplyDialog] Success! Updating local replies...');
                                  if (mounted) {
                                    setState(() {
                                      if (initialText == null) {
                                        _localReplies.add(ReviewReply(
                                          id: '',
                                          reviewId: review.id,
                                          reply: savedText,
                                          createdAt: DateTime.now(),
                                        ));
                                        print(
                                            '✅ [ReplyDialog] Added new reply to _localReplies');
                                      } else {
                                        if (_localReplies.isNotEmpty) {
                                          _localReplies[0] = ReviewReply(
                                            id: _localReplies[0].id,
                                            reviewId: _localReplies[0].reviewId,
                                            reply: savedText,
                                            createdAt:
                                                _localReplies[0].createdAt,
                                          );
                                          print(
                                              '✅ [ReplyDialog] Updated existing reply in _localReplies');
                                        }
                                      }
                                    });
                                  }
                                } else {
                                  print(
                                      '❌ [ReplyDialog] success=false, resetting isSending');
                                  setDialogState(() => isSending = false);
                                }
                              } catch (e, st) {
                                print('❌ [ReplyDialog] Exception: $e');
                                print('❌ [ReplyDialog] StackTrace: $st');
                                if (mounted) {
                                  setDialogState(() => isSending = false);
                                }
                              }
                              print('🔵 [ReplyDialog] Popping dialog');
                              Navigator.of(context).pop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.kPrimaryColor2,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('send'.tr,
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
          GestureDetector(
            onTap: review.userId.isNotEmpty
                ? () {
                    // Get.to(
                    //   () => const SpecialProfile(),
                    //   arguments: {
                    //     'id': review.userId,
                    //     'username': review.username,
                    //     'image': review.image ?? '',
                    //   },
                    // );
                  }
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorConstants.noUserBackground[
                            (int.tryParse(review.userId) ?? 0) % 4],
                      ),
                      child: ClipOval(
                        child:
                            (review.image != null && review.image!.isNotEmpty)
                                ? CachedNetworkImage(
                                    imageUrl: _resolveImageUrl(review.image!),
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        _buildInitialAvatar(size: 16),
                                  )
                                : _buildInitialAvatar(size: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.review.username,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: ColorConstants.fonts),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stars
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_isAuthor && widget.onEditReview != null) ...[
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => _showReviewEditDialog(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: ColorConstants.kPrimaryColor2
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'my_review'.tr,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: ColorConstants.kPrimaryColor2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const HugeIcon(
                                      icon: HugeIcons.strokeRoundedPencilEdit01,
                                      size: 12,
                                      color: ColorConstants.kPrimaryColor2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                Icons.star,
                                color: i < review.rating
                                    ? Colors.amber
                                    : Colors.grey.shade300,
                                size: 14,
                              ),
                            ),
                          ),
                        ]),
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
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
                      if (_isReplyAuthor && !widget.hideReplyEdit)
                        GestureDetector(
                          onTap: () => _showReplyDialog(
                              initialText: _localReplies.first.reply),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: ColorConstants.kPrimaryColor2
                                  .withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedPencilEdit01,
                              size: 14,
                              color: ColorConstants.kPrimaryColor2,
                            ),
                          ),
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
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedMailReply01,
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
