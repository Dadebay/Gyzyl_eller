import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/models/review_model.dart';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/special_profile/widgets/review_tile.dart';
import 'package:hugeicons/hugeicons.dart';

enum ReviewSorting {
  newest('created_at', 'desc'),
  oldest('created_at', 'asc'),
  highestRating('rating', 'desc'),
  lowestRating('rating', 'asc');

  final String column;
  final String direction;
  const ReviewSorting(this.column, this.direction);
}

class AllReviewsScreen extends StatefulWidget {
  final String userId;
  final String? username;

  const AllReviewsScreen({
    super.key,
    required this.userId,
    this.username,
  });

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  final ApiService _apiService = ApiService();
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  ReviewSorting _sorting = ReviewSorting.newest;

  @override
  void initState() {
    super.initState();
    _fetchReviews(_sorting);
  }

  Future<void> _fetchReviews(ReviewSorting sorting) async {
    setState(() {
      _isLoading = true;
      _sorting = sorting;
    });
    try {
      final rawList = await _apiService.getMasterReviews(
        widget.userId,
        column: sorting.column,
        direction: sorting.direction,
      );
      if (mounted) {
        setState(() {
          _reviews = rawList
              .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'sort_reviews'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...ReviewSorting.values.map((s) => RadioListTile<ReviewSorting>(
                      title: Text(_sortLabel(s)),
                      value: s,
                      groupValue: _sorting,
                      activeColor: ColorConstants.kPrimaryColor2,
                      onChanged: (val) {
                        Navigator.pop(context);
                        if (val != null) _fetchReviews(val);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  String _sortLabel(ReviewSorting s) {
    switch (s) {
      case ReviewSorting.newest:
        return 'sort_newest'.tr;
      case ReviewSorting.oldest:
        return 'sort_oldest'.tr;
      case ReviewSorting.highestRating:
        return 'sort_highest_rating'.tr;
      case ReviewSorting.lowestRating:
        return 'sort_lowest_rating'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        backgroundColor: ColorConstants.background,
        title: Text(
          'reviews_section_title'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 26,
            color: ColorConstants.kPrimaryColor2,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedSorting05,
              size: 24,
              color: Colors.black,
            ),
            onPressed: _showSortBottomSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? Center(
                  child: Text(
                    'no_reviews'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ColorConstants.greyColor,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, bottom: 16, top: 5),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    return ReviewTile(review: _reviews[index]);
                  },
                ),
    );
  }
}
