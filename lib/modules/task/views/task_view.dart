import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/task/views/pages/task_list.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';

class TaskView extends StatelessWidget {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ColorConstants.background,
        appBar: AppBar(
          backgroundColor: ColorConstants.background,
          leadingWidth: 100,
          title: const Text(
            "Ýumuşlarym",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
                icon: SizedBox(
                  child: SvgPicture.asset(IconConstants.filter),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
                icon: SizedBox(
                  child: SvgPicture.asset(IconConstants.sort),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {},
              icon: SizedBox(
                child: SvgPicture.asset(IconConstants.notifications),
              ),
            ),
          ],
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(75),
              child: Container(
                padding: EdgeInsets.all(5),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: ColorConstants.kPrimaryColor2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      child: Text(
                        "Tekliplerim",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Işlerim",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
        body: const TabBarView(
          children: [
            TaskList(),
            TaskList(),
          ],
        ),
      ),
    );
  }
}
