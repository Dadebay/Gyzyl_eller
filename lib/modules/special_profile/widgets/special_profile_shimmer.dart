// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SpecialProfileShimmer extends StatefulWidget {
  const SpecialProfileShimmer({super.key});

  @override
  State<SpecialProfileShimmer> createState() => _SpecialProfileShimmerState();
}

class _SpecialProfileShimmerState extends State<SpecialProfileShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildHeaderShimmer(),
              const SizedBox(height: 15),
              _buildBioShimmer(),
              const SizedBox(height: 20),
              _buildSectionHeaderShimmer(),
              const SizedBox(height: 15),
              _buildGridShimmer(),
              const SizedBox(height: 20),
              _buildSectionHeaderShimmer(),
              const SizedBox(height: 15),
              _buildReviewShimmer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderShimmer() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _shimmerBox(width: 70, height: 45),
            _shimmerBox(width: 100, height: 100, isCircle: true),
            _shimmerBox(width: 70, height: 45),
          ],
        ),
        const SizedBox(height: 15),
        _shimmerBox(width: 160, height: 22),
        const SizedBox(height: 8),
        _shimmerBox(width: 120, height: 16),
        const SizedBox(height: 8),
        _shimmerBox(width: 100, height: 16),
        const SizedBox(height: 12),
        _shimmerBox(width: 140, height: 20),
      ],
    );
  }

  Widget _buildBioShimmer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBox(width: 35, height: 14),
              const SizedBox(width: 8),
              Expanded(child: _shimmerBox(height: 14)),
            ],
          ),
          const SizedBox(height: 8),
          _shimmerBox(width: double.infinity, height: 13),
          const SizedBox(height: 6),
          _shimmerBox(width: double.infinity, height: 13),
          const SizedBox(height: 6),
          _shimmerBox(width: 180, height: 13),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderShimmer() {
    return Row(
      children: [
        _shimmerBox(width: 24, height: 24, isCircle: true),
        const SizedBox(width: 10),
        _shimmerBox(width: 100, height: 18),
      ],
    );
  }

  Widget _buildGridShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 140,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, __) => _shimmerBox(borderRadius: 12),
    );
  }

  Widget _buildReviewShimmer() {
    return Column(
      children: [
        _shimmerBox(width: double.infinity, height: 90, borderRadius: 12),
        const SizedBox(height: 10),
        _shimmerBox(width: double.infinity, height: 90, borderRadius: 12),
      ],
    );
  }

  Widget _shimmerBox({
    double? width,
    double? height,
    double borderRadius = 8,
    bool isCircle = false,
  }) {
    final double stop1 = (_controller.value - 0.3).clamp(0.0, 1.0);
    final double stop2 = _controller.value.clamp(0.0, 1.0);
    final double stop3 = (_controller.value + 0.3).clamp(0.0, 1.0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!.withOpacity(0.6),
            Colors.grey[100]!.withOpacity(0.3),
            Colors.grey[300]!.withOpacity(0.6),
          ],
          stops: [stop1, stop2, stop3],
        ),
      ),
    );
  }
}
