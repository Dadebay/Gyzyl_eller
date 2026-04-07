// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Habarnama'.tr,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            _buildNotificationSettings(),
            const SizedBox(height: 16),
            const Text(
              '03 Sentyabr 2023',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildNotificationCard(
              title: 'Müşderiden täze hat geldi',
              subtitle: 'Aşhanadaky smesitel akýar',
              time: '10:55',
              isNew: true,
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merdan:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.blue),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Salam Kerwen\nGowmy ýagdaýlaň? Öýde bir iş bardy, näçe manada edip berjek ?',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.fonts),
                  ),
                ],
              ),
            ),
            _buildNotificationCard(
              title: 'Saýlandyňyz',
              subtitle: 'Aşhanadaky smesitel akýar',
              time: '10:55',
              content: const Text(
                  'Ýumuşy ýerine ýetirmäge Sizi saýladylar. 15 ŞAÝ hasabyňyzdan alyndy.'),
            ),
            _buildNotificationCard(
              title: 'Başga hünärmen saýlanyldy',
              subtitle: 'Aşhanadaky smesitel akýar',
              time: '10:55',
              content: const Text(
                  'Ýumuşy ýerine ýetirmäne başga hünärmen saýlanyldy.'),
            ),
            _buildNotificationCard(
              title: 'Ýumuş ýatyryldy',
              subtitle: 'Aşhanadaky smesitel akýar',
              time: '10:55',
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kerwen Myradow.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Ýumuşy pozdy.'),
                ],
              ),
            ),
            _buildNotificationCard(
              title: 'Bahalandyrylyňyz',
              subtitle: 'Aşhanadaky smesitel akýar',
              time: '10:55',
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jeýhun 4.5 ýyldyz berdi.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Töwleme iş gowy tamamladyňyz. Köp sagblouň.'),
                ],
              ),
            ),
            _buildNotificationCard(
              title: 'Hasabyňyzy doldyryň',
              subtitle:
                  'Aşhanadaky smesitel akýar', // This seems like a placeholder
              time: '10:55',
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2 ŞAÝ galdy.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.deepOrange),
                  ),
                  SizedBox(height: 4),
                  Text('Hasabyňyzy doldyrmagy haýyşt edýärin.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            IconConstants.notifications,
            color: ColorConstants.kPrimaryColor2,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Habarnamalary görkezmek',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.fonts,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Täze habarnamalary duýdurmak',
                  style: TextStyle(color: ColorConstants.fonts, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 32,
            height: 16,
            child: Transform.scale(
              scale: 0.9,
              child: Switch(
                value: true,
                onChanged: (bool value) {},
                activeColor: ColorConstants.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required String time,
    bool isNew = false,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: ColorConstants.kPrimaryColor2,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          color: ColorConstants.secondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  if (isNew) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: ColorConstants.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          content,
        ],
      ),
    );
  }
}
