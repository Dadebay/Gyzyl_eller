import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/sizes/image_sizes.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<String> unselectedIcons;
  final List<String> selectedIcons;
  final Function(int) onTap;
  final List<String> labels;

  CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.unselectedIcons,
    required this.selectedIcons,
    required this.labels,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color selectedIconColor =
        isDarkMode ? colorScheme.onSurface : ColorConstants.kPrimaryColor2;

    return Container(
      height: WidgetSizes.size64.value,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        border: Border(
          top: BorderSide(
            color: colorScheme.shadow.withOpacity(.2),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(.2),
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
                      SvgPicture.asset(
                        isSelected
                            ? unselectedIcons[index]
                            : selectedIcons[index],
                      ),
                      SizedBox(height: 4),
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
