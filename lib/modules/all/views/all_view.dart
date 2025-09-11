import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/all/views/pages/account_summary_bar.dart';
import 'package:gyzyleller/modules/all/views/pages/job_card.dart';

import 'package:gyzyleller/modules/all/views/pages/job_detail_view.dart';
import 'package:gyzyleller/modules/all/views/pages/searc_view.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';

class AllView extends StatelessWidget {
  const AllView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: _buildAppBar(),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 3,
        itemBuilder: (context, index) {
          return JobCard(
            date: '27 awgust 2023, 16:31',
            title: 'Aşhanadaky smesitel we turba akýar',
            isNew: index == 0,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AccountSummaryBar(
        balanceText: 'Hasabym: 375 TMT',
        onPressed: () => Get.to(JobDetailsPage()),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
    );
  }
}
