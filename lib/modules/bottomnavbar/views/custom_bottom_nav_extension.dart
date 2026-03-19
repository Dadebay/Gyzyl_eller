// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<String> unselectedIcons;
  final List<String> selectedIcons;
  final Function(int) onTap;
  final List<String> labels;
  final List<int>? badges;

  const CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.unselectedIcons,
    required this.selectedIcons,
    required this.labels,
    this.badges,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const Color selectedIconColor = ColorConstants.kPrimaryColor2;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        border: Border(
          top: BorderSide(
            color: ColorConstants.kPrimaryColor.withOpacity(.2),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorConstants.kPrimaryColor.withOpacity(.2),
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(selectedIcons.length, (index) {
          final isSelected = index == currentIndex;
          return TweenAnimationBuilder<double>(
            tween: Tween(
                begin: isSelected ? 0.0 : 1.0, end: isSelected ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  color: Colors.transparent,
                  width: 70,
                  height: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SvgPicture.asset(
                            isSelected
                                ? unselectedIcons[index]
                                : selectedIcons[index],
                          ),
                          if (badges != null &&
                              index < badges!.length &&
                              badges![index] > 0)
                            Positioned(
                              top: -12,
                              right: -10,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '${badges![index]}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color.lerp(
                            ColorConstants.kPrimaryColor,
                            selectedIconColor,
                            value,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
