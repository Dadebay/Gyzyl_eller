import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/core/models/my_tasks_status.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:hugeicons/hugeicons.dart';

class NewTag extends StatelessWidget {
  final int? status;
  const NewTag({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();

    final myStatus = MyTasksStatus.fromApiValue(status);

    Widget? statusIcon;
    Color textColor;
    Color bgColor;

    switch (myStatus) {
      case MyTasksStatus.garasylyan:
        statusIcon = const HugeIcon(
          icon: HugeIcons.strokeRoundedEdit01,
          size: 14,
          color: Color(0xFFF29C1F),
        );
        textColor = const Color(0xFFF29C1F);
        bgColor = const Color(0xFFFFF4E5);
        break;
      case MyTasksStatus.aktiw:
        statusIcon = SvgPicture.asset(
          'assets/icons/aktiw.svg',
          width: 14,
          height: 14,
          colorFilter:
              const ColorFilter.mode(Color(0xFF165500), BlendMode.srcIn),
        );
        textColor = const Color(0xFF165500);
        bgColor = const Color.fromARGB(255, 120, 229, 118);
        break;
      case MyTasksStatus.retEdilen:
        statusIcon = const HugeIcon(
          icon: HugeIcons.strokeRoundedInformationCircle,
          size: 14,
          color: Color(0xFFE17A00),
        );
        textColor = const Color(0xFFE17A00);
        bgColor = const Color(0xFFFFEFDD);
        break;
      case MyTasksStatus.hunarmenSaylandy:
        statusIcon = const HugeIcon(
          icon: HugeIcons.strokeRoundedUserCheck01,
          size: 14,
          color: Color(0xFF165500),
        );
        textColor = const Color(0xFF165500);
        bgColor = const Color.fromARGB(255, 120, 229, 118);
        break;
      case MyTasksStatus.tamamlanan:
        statusIcon = const HugeIcon(
          icon: HugeIcons.strokeRoundedHelpCircle,
          size: 14,
          color: Colors.white,
        );
        textColor = Colors.white;
        bgColor = const Color(0xFFFFB960);
        break;
      case MyTasksStatus.pozulan:
      case MyTasksStatus.arhiw:
        statusIcon = const HugeIcon(
          icon: HugeIcons.strokeRoundedCancel01,
          size: 14,
          color: Color(0xFF9E9E9E),
        );
        textColor = const Color(0xFF9E9E9E);
        bgColor = const Color(0xFFF5F5F5);
        break;
      case MyTasksStatus.mohletiGecen:
        statusIcon = const HugeIcon(
          icon: HugeIcons.strokeRoundedTimer02,
          size: 14,
          color: Color(0xFFEB5757),
        );
        textColor = const Color(0xFFEB5757);
        bgColor = const Color(0xFFFFEBEE);
        break;
      default:
        statusIcon = const HugeIcon(
          icon: HugeIcons.strokeRoundedCircle,
          size: 14,
          color: ColorConstants.kPrimaryColor2,
        );
        textColor = ColorConstants.kPrimaryColor2;
        bgColor = ColorConstants.kPrimaryColor2.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          statusIcon,
          const SizedBox(width: 4),
          Text(myStatus.displayName,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }
}
