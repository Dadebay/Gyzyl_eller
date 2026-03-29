import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/core/models/my_tasks_status.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class NewTag extends StatelessWidget {
  final int? status;
  const NewTag({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();

    final myStatus = MyTasksStatus.fromApiValue(status);

    IconData? iconData;
    String? svgIcon;
    Color textColor;
    Color bgColor;

    switch (myStatus) {
      case MyTasksStatus.garasylyan:
        iconData = Icons.edit_outlined;
        textColor = const Color(0xFFF29C1F);
        bgColor = const Color(0xFFFFF4E5);
        break;
      case MyTasksStatus.aktiw:
        svgIcon = 'assets/icons/aktiw.svg';
        textColor = const Color(0xFF165500);
        bgColor = const Color.fromARGB(255, 120, 229, 118);
        break;
      case MyTasksStatus.retEdilen:
        iconData = Icons.info_outline;
        textColor = const Color(0xFFE17A00);
        bgColor = const Color(0xFFFFEFDD);
        break;
      case MyTasksStatus.hunarmenSaylandy:
        iconData = Icons.check_circle_outline;
        textColor = const Color(0xFF165500);
        bgColor = const Color.fromARGB(255, 120, 229, 118);
        break;
      case MyTasksStatus.tamamlanan:
        iconData = Icons.help_outline;
        textColor = Colors.white;
        bgColor = const Color(0xFFFFB960);
        break;
      case MyTasksStatus.pozulan:
      case MyTasksStatus.arhiw:
        iconData = Icons.cancel_outlined;
        textColor = const Color(0xFF9E9E9E);
        bgColor = const Color(0xFFF5F5F5);
        break;
      case MyTasksStatus.mohletiGecen:
        iconData = Icons.timer_off_outlined;
        textColor = const Color(0xFFEB5757);
        bgColor = const Color(0xFFFFEBEE);
        break;
      default:
        iconData = Icons.circle;
        textColor = ColorConstants.kPrimaryColor2;
        bgColor = ColorConstants.kPrimaryColor2.withOpacity(0.1);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgIcon != null)
              SvgPicture.asset(svgIcon,
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn))
            else if (iconData != null)
              Icon(iconData, color: textColor, size: 14),
            const SizedBox(width: 4),
            Text(myStatus.displayName,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
          ],
        ),
      ),
    );
  }
}
