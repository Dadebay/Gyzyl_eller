import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/models/review_model.dart';
import 'package:gyzyleller/core/services/api_constants.dart';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/modules/special_profile/views/special_profile_edit_view.dart';
import 'package:gyzyleller/modules/special_profile/views/all_reviews_screen.dart';
import 'package:gyzyleller/modules/special_profile/widgets/profile_header.dart';
import 'package:gyzyleller/modules/special_profile/widgets/review_tile.dart';
import 'package:hugeicons/hugeicons.dart';

class SpecialProfile extends StatefulWidget {
  const SpecialProfile({super.key});

  @override
  State<SpecialProfile> createState() => _SpecialProfileState();
}

class _SpecialProfileState extends State<SpecialProfile> {
  final SpecialProfileController _controller =
      Get.put(SpecialProfileController(), permanent: true);

  // ── State ────────────────────────────────────────────────────────────────
  bool _isExpanded = false;
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = false;
  final ApiService _apiService = ApiService();

  List<String> _buildAbsoluteUrls(List<dynamic> rawFiles) {
    return rawFiles.map((e) {
      String? path;
      if (e is Map && e["destination"] != null) {
        path = e["destination"].toString();
      } else if (e is String) {
        path = e;
      }

      if (path == null || path.isEmpty) return '';
      if (path.startsWith('http')) return path;
      String cleanPath = path.startsWith('/') ? path.substring(1) : path;
      return '${ApiConstants.imageURL}$cleanPath';
    }).where((element) => element.isNotEmpty).toList();
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  /// Fetches reviews from `master-reviews/{userId}` and converts raw JSON
  /// into [ReviewModel] instances.
  Future<void> _fetchReviews() async {
    final userId = _controller.profile.value.userId;
    if (userId == null || userId.isEmpty) {
      return;
    }

    setState(() => _isLoadingReviews = true);
    try {
      final rawList = await _apiService.getMasterReviews(userId);
      if (mounted) {
        final reviews = rawList
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  String get _shortText {
    final p = _controller.profile.value;
    return p.shortBio ?? '';
  }

  String get _fullText {
    final p = _controller.profile.value;
    return p.longBio ?? '';
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        final profile = _controller.profile.value;
        final serverImages = profile.serverImages;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              ProfileHeader(
                name: profile.name ?? '',
                imageUrl: profile.imageUrl,
                shortBio: _shortText,
                rating: profile.rating,
                reviewCount: profile.reviewCount,
                createdAt: profile.createdAt,
                doneJobsCount: profile.doneJobsCount,
                totalJobsCount: profile.totalJobsCount,
              ),
              const SizedBox(height: 15),
              _buildBioCard(context),
              if (serverImages.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildImagesSection(serverImages),
              ],
              if (profile.reviewCount > 0 || _reviews.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildReviewsSection(profile),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ColorConstants.background,
      title: Text(
        'specialist_profile_title'.tr,
        style: const TextStyle(
            color: ColorConstants.fonts,
            fontSize: 18,
            fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        iconSize: 26,
        padding: EdgeInsets.zero,
        icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: ColorConstants.kPrimaryColor2,
            size: 26.0),
      ),
      actions: [
        IconButton(
          onPressed: () => Get.to(() => const SpecialProfileEditView()),
          iconSize: 20,
          padding: EdgeInsets.zero,
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedEdit02,
              color: ColorConstants.kPrimaryColor2,
              size: 24.0),
        ),
      ],
    );
  }

  Widget _buildBioCard(BuildContext context) {
    final content = _fullText;
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final span = TextSpan(
            text: content,
            style: const TextStyle(
              fontSize: 14,
              color: ColorConstants.blackColor,
              height: 1.4,
            ),
          );
          final tp = TextPainter(
            text: span,
            maxLines: 3,
            textDirection: TextDirection.ltr,
          );
          tp.layout(maxWidth: constraints.maxWidth);

          if (tp.didExceedMaxLines) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Bio: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: ColorConstants.blackColor),
                      ),
                      TextSpan(
                        text: _isExpanded
                            ? content
                            : "${content.substring(0, tp.getPositionForOffset(Offset(constraints.maxWidth, tp.height)).offset - 15)}...",
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColorConstants.blackColor,
                          height: 1.4,
                        ),
                      ),
                      const WidgetSpan(child: SizedBox(width: 5)),
                      TextSpan(
                        text: " ${_isExpanded ? "gizle".tr : "dolyac".tr}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: ColorConstants.blue,
                          fontWeight: FontWeight.w400,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() => _isExpanded = !_isExpanded);
                          },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Bio: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: ColorConstants.blackColor),
                  ),
                  TextSpan(
                    text: content,
                    style: const TextStyle(
                        fontSize: 14,
                        color: ColorConstants.blackColor,
                        height: 1.4),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  /// Works / diplomas / certificates image grid.
  Widget _buildImagesSection(List<dynamic> rawPaths) {
    final images = _buildAbsoluteUrls(rawPaths);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'works_section_title'.tr} ${images.length}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          itemCount: images.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 140,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (_, index) {
            return InkWell(
              onTap: () => _openImageGallery(images, index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildImageShimmer(),
                  errorWidget: (context, url, _) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageShimmer() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.6),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          color: Colors.grey[200]!.withOpacity(value),
        );
      },
      onEnd: () {},
    );
  }

  /// Opens a full-screen gallery view at [initialIndex].
  void _openImageGallery(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImageGalleryScreen(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  /// Reviews section with AnimatedSwitcher + shimmer loading.
  Widget _buildReviewsSection(profile) {
    final totalReviews =
        profile.reviewCount > 0 ? profile.reviewCount : _reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          '${'reviews_section_title'.tr} $totalReviews',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),

        // AnimatedSwitcher: shimmer ↔ loaded reviews
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoadingReviews
              ? const Column(
                  key: ValueKey('loading'),
                  children: [
                    ReviewTileShimmer(),
                    ReviewTileShimmer(),
                  ],
                )
              : Column(
                  key: const ValueKey('loaded'),
                  children: _reviews
                      .take(2) // show first 2, rest via "see all"
                      .map((r) => ReviewTile(review: r))
                      .toList(),
                ),
        ),

        // "See all" link
        if (_reviews.length > 2) ...[
          const SizedBox(height: 5),
          InkWell(
            onTap: () => _showAllReviews(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'view_all_button'.tr,
                  style: const TextStyle(
                      fontSize: 15,
                      color: ColorConstants.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: ColorConstants.blue),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.north_east,
                    size: 18, color: ColorConstants.blue),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Opens the full reviews page.
  void _showAllReviews() {
    final userId = _controller.profile.value.userId;
    if (userId == null || userId.isEmpty) return;
    Get.to(() => AllReviewsScreen(
          userId: userId,
          username: _controller.profile.value.name,
        ));
  }
}

// ── Internal Gallery Screen ──────────────────────────────────────────────────

/// Simple full-screen image gallery with swipe-to-switch pages.
class _ImageGalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImageGalleryScreen({required this.images, required this.initialIndex});

  @override
  State<_ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<_ImageGalleryScreen> {
  late int _current;
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: Colors.white,
              size: 26.0),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_current + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageCtrl,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(
              widget.images[i],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
            ),
          ),
        ),
      ),
    );
  }
}
