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
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Professional profile screen shown when masters API returns data.
/// Matches the design of `HunarmenScreen` (ayterek/service_profile_screen.dart)
/// with real API data for reviews, images, rating, bio, etc.
class SpecialProfile extends StatefulWidget {
  const SpecialProfile({super.key});

  @override
  State<SpecialProfile> createState() => _SpecialProfileState();
}

class _SpecialProfileState extends State<SpecialProfile> {
  // ── Controller ──────────────────────────────────────────────────────────
  final SpecialProfileController _controller =
      Get.put(SpecialProfileController(), permanent: true);

  // ── State ────────────────────────────────────────────────────────────────
  bool _isExpanded = false;
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = false;
  final ApiService _apiService = ApiService();

  // ── Computed image list (full absolute URLs) ─────────────────────────────
  /// Converts raw server file paths to absolute image URLs.
  List<String> _buildAbsoluteUrls(List<String> rawPaths) {
    return rawPaths.map((path) {
      if (path.startsWith('http')) return path;
      if (path.startsWith('/')) path = path.substring(1);
      return '${ApiConstants.imageURL}$path';
    }).toList();
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
      print(
          '⚠️ [SpecialProfile] _fetchReviews → userId is null/empty, skipping review fetch');
      return;
    }

    print('📡 [SpecialProfile] _fetchReviews → userId: $userId');

    setState(() => _isLoadingReviews = true);
    try {
      final rawList = await _apiService.getMasterReviews(userId);
      if (mounted) {
        final reviews = rawList
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList();
        print(
            '✅ [SpecialProfile] _fetchReviews → ${reviews.length} reviews parsed');
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      print('❌ [SpecialProfile] _fetchReviews error: $e');
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  /// The short (3-line) version of the bio text.
  String get _shortText {
    final p = _controller.profile.value;
    return p.shortBio?.isNotEmpty == true ? p.shortBio! : (p.longBio ?? '');
  }

  /// The full bio text used when expanded.
  String get _fullText {
    final p = _controller.profile.value;
    return p.longBio?.isNotEmpty == true ? p.longBio! : _shortText;
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

              // ── Profile header ─────────────────────────────────────────
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

              // ── Location badge ────────────────────────────────────────
              if (profile.welayat.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: ColorConstants.greyColor),
                    const SizedBox(width: 4),
                    Text(
                      profile.etrap.isNotEmpty
                          ? '${profile.welayat}, ${profile.etrap}'
                          : profile.welayat,
                      style: const TextStyle(
                          fontSize: 14, color: ColorConstants.greyColor),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 10),

              // ── Bio section ───────────────────────────────────────────
              _buildBioCard(context),

              // ── Images / works grid ────────────────────────────────────
              if (serverImages.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildImagesSection(serverImages),
              ],

              // ── Reviews section ────────────────────────────────────────
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

  // ── Widgets ──────────────────────────────────────────────────────────────

  /// AppBar with title and edit action button.
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
        iconSize: 20,
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.arrow_back_ios,
            color: ColorConstants.kPrimaryColor2),
      ),
      actions: [
        IconButton(
          onPressed: () => Get.to(() => const SpecialProfileEditView()),
          iconSize: 20,
          padding: EdgeInsets.zero,
          icon: SvgPicture.asset(IconConstants.edit, width: 24, height: 24),
        ),
      ],
    );
  }

  /// Floating edit button at the bottom that navigates to the edit screen.

  /// Bio card with expand / collapse behaviour.
  Widget _buildBioCard(BuildContext context) {
    final text = _fullText;
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final span = TextSpan(
            text: 'Bio: $text',
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
          )..layout(maxWidth: constraints.maxWidth);

          if (!tp.didExceedMaxLines) {
            // Short text – render as-is without toggle.
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
                    text: text,
                    style: const TextStyle(
                        fontSize: 14, color: ColorConstants.blackColor),
                  ),
                ],
              ),
            );
          }

          // Long text – show collapse / expand toggle.
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
                  text: _isExpanded ? _fullText : _shortText,
                  style: const TextStyle(
                      fontSize: 14, color: ColorConstants.blackColor),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        _isExpanded ? 'gizle'.tr : 'dolyac'.tr,
                        style: const TextStyle(
                            fontSize: 13,
                            color: ColorConstants.blue,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            maxLines: _isExpanded ? null : 3,
            overflow:
                _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          );
        },
      ),
    );
  }

  /// Works / diplomas / certificates image grid.
  Widget _buildImagesSection(List<String> rawPaths) {
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
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey[200]),
                ),
              ),
            );
          },
        ),
      ],
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
