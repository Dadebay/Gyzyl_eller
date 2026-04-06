import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/services/api_constants.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/controller/special_profile_controller.dart';
import 'package:gyzyleller/modules/special_profile/views/special_profile_edit_view.dart';
import 'package:gyzyleller/modules/special_profile/views/all_reviews_screen.dart';
import 'package:gyzyleller/modules/special_profile/widgets/profile_header.dart';
import 'package:gyzyleller/modules/special_profile/widgets/review_tile.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;

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

  List<String> _buildAbsoluteUrls(List<dynamic> rawFiles) {
    return rawFiles
        .map((e) {
          String? path;
          if (e is Map) {
            path = (e["path"] ?? e["destination"])?.toString();
          } else if (e is String) {
            path = e;
          }

          if (path == null || path.isEmpty) return '';
          if (path.startsWith('http')) return path;
          String cleanPath = path.startsWith('/') ? path.substring(1) : path;
          return '${ApiConstants.imageURL}$cleanPath';
        })
        .where((element) => element.isNotEmpty)
        .toList();
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _controller.fetchReviews();
  }

  String get _shortText {
    final p = _controller.profile.value;
    return p.shortBio ?? '';
  }

  String get _fullText {
    final p = _controller.profile.value;
    return p.longBio ?? '';
  }

  bool _isImage(String path) {
    final String ext = p.extension(path).toLowerCase();
    return ext == '.jpg' ||
        ext == '.jpeg' ||
        ext == '.png' ||
        ext == '.gif' ||
        ext == '.webp';
  }

  Future<void> _openFile(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error opening file: $e');
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        final profile = _controller.profile.value;
        final allFiles = _buildAbsoluteUrls(profile.serverImages);
        final images = allFiles.where((f) => _isImage(f)).toList();
        final documents = allFiles.where((f) => !_isImage(f)).toList();

        return RefreshIndicator(
          onRefresh: () => _controller.refreshProfile(),
          color: ColorConstants.kPrimaryColor2,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                if (images.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildImagesSection(images),
                ],
                if (documents.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildDocumentsSection(documents),
                ],
                if (profile.reviewCount > 0 ||
                    _controller.reviews.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildReviewsSection(profile),
                ],
                const SizedBox(height: 20),
              ],
            ),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        HugeIcon(
          icon: icon,
          color: ColorConstants.blackColor,
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: ColorConstants.blackColor,
          ),
        ),
      ],
    );
  }

  /// Works / diplomas / certificates image grid.
  Widget _buildImagesSection(List<String> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'works_section_title'.tr, HugeIcons.strokeRoundedFiles01),
        const SizedBox(height: 15),
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
                      child:
                          Icon(Icons.image_not_supported, color: Colors.grey),
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

  Widget _buildDocumentsSection(List<String> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...documents.map((docUrl) => _buildDocumentCard(docUrl)),
      ],
    );
  }

  Widget _buildDocumentCard(String docUrl) {
    String fileName = p.basename(docUrl);
    if (fileName.contains('?')) {
      fileName = fileName.split('?').first;
    }

    return InkWell(
      onTap: () => _openFile(docUrl),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file,
                size: 32, color: ColorConstants.kPrimaryColor2),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const Icon(Icons.open_in_new, size: 20, color: Colors.grey),
          ],
        ),
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _buildSectionHeader(
            'reviews_section_title'.tr, HugeIcons.strokeRoundedComment01),
        const SizedBox(height: 15),

        // AnimatedSwitcher: shimmer ↔ loaded reviews
        Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _controller.isLoadingReviews.value
                  ? const Column(
                      key: ValueKey('loading'),
                      children: [
                        ReviewTileShimmer(),
                        ReviewTileShimmer(),
                      ],
                    )
                  : Column(
                      key: const ValueKey('loaded'),
                      children: _controller.reviews
                          .take(2)
                          .map((r) => ReviewTile(review: r))
                          .toList(),
                    ),
            )),

        // "See all" link
        if (_controller.reviews.length > 2) ...[
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
