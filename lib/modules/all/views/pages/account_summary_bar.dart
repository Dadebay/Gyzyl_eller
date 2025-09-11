import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';

class AccountSummaryBar extends StatelessWidget {
  final String balanceText;
  final VoidCallback onPressed;

  const AccountSummaryBar(
      {super.key, required this.balanceText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 5, right: 10, left: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: ColorConstants.blue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(IconConstants.leaderboard),
          const SizedBox(width: 5),
          Text(balanceText,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: SvgPicture.asset(IconConstants.arrowOutward),
            label: const Text('Giňişleýin',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.kPrimaryColor2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
