import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/all/views/pages/job_detail_view.dart';
import 'package:gyzyleller/modules/all/views/pages/searc_view.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';

class AllView extends StatelessWidget {
  const AllView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        backgroundColor: ColorConstants.background,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(IconConstants.filter),
          onPressed: () {},
        ),
        title: const Text(
          'Hemmesi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(IconConstants.search),
            onPressed: () {
              Get.to(AllSearchView());
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) {
          return JobCard(
            date: '27 awgust 2023, 16:31',
            title: 'Aşhanadaky smesitel we turba akýar',
            isNew: false,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
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
            SizedBox(
              width: 5,
            ),
            Text(
              'Hasabym: 375 TMT',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Get.to(JobDetailsPage());
              },
              icon: SvgPicture.asset(IconConstants.arrowOutward),
              label: const Text(
                'Giňişleýin',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.kPrimaryColor2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String date;
  final String title;
  final bool isNew;

  const JobCard({
    super.key,
    required this.date,
    required this.title,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date,
                style:
                    TextStyle(color: ColorConstants.secondary, fontSize: 13)),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.fonts)),
            if (isNew) ...[
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConstants.kPrimaryColor2.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time,
                        color: ColorConstants.kPrimaryColor2, size: 16),
                    const SizedBox(width: 4),
                    Text('Täze',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.kPrimaryColor2)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Divider(height: 2, color: ColorConstants.background),
            const SizedBox(height: 12),
            _buildInfoRow(IconConstants.calendar, "24.05.2023 - 28.05.2023",
                'işiň senesi'),
            const SizedBox(height: 6),
            _buildInfoRow(IconConstants.grid, "Gurlushyk we abatlayysh", null),
            const SizedBox(height: 6),
            _buildInfoRow(IconConstants.locationHouse,
                "Aşgabat, Mir 7/2, Jaý 9, Otag 32", null),
            const SizedBox(height: 6),
            Divider(height: 2, color: ColorConstants.background),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildSmallInfo(IconConstants.payment, "750 TMT - 8000 TMT"),
                const SizedBox(width: 16),
                _buildSmallInfo(IconConstants.builder, "15"),
                const SizedBox(width: 16),
                _buildSmallInfo(IconConstants.eye, "48"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String icon, String text, String? suffix) {
    return Row(
      children: [
        SvgPicture.asset(icon,
            width: 16, height: 16, color: ColorConstants.secondary),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        if (suffix != null) ...[
          const SizedBox(width: 4),
          Text(suffix,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.secondary)),
        ]
      ],
    );
  }

  Widget _buildSmallInfo(String icon, String text) {
    return Row(
      children: [
        SvgPicture.asset(icon,
            width: 16, height: 16, color: ColorConstants.secondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
