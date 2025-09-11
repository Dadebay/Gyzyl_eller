import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
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

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        buildTaskCard(
          date: "27 august 2023, 16:31",
          title: "Aşhanadaky smesitel we turba akýar",
          status: "Hünärmen saýlandy",
          statusColor: ColorConstants.successtatus,
        ),
        buildTaskCard(
          date: "27 august 2023, 16:31",
          title: "Aşhanadaky smesitel we turba akýar",
          status: "Ýumuş ýatyryldy",
          statusColor: ColorConstants.kPrimaryColor2.withOpacity(0.3),
        ),
        buildTaskCard(
          date: "27 august 2023, 16:31",
          title: "Aşhanadaky smesitel we turba akýar",
          status: null,
          statusColor: null,
        ),
      ],
    );
  }
}

Widget buildTaskCard({
  required String date,
  required String title,
  String? status,
  Color? statusColor,
}) {
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
              style: TextStyle(color: ColorConstants.secondary, fontSize: 13)),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorConstants.fonts,
              )),
          if (status != null) ...[
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusColor == ColorConstants.successtatus
                        ? Icons.check
                        : Icons.close,
                    color: ColorConstants.fonts,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(status,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.fonts)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Divider(
            height: 2,
            color: ColorConstants.background,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorConstants.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    SvgPicture.asset(
                      IconConstants.calendar,
                    ),
                    SizedBox(width: 4),
                    Text("24.05.2023 - 28.05.2023",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                  ])),
              SizedBox(
                width: 10,
              ),
              Text("işiň senesi",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                SvgPicture.asset(
                  IconConstants.grid,
                ),
                SizedBox(width: 4),
                Text("Gurlushyk we abatlayysh",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                SvgPicture.asset(
                  IconConstants.locationHouse,
                ),
                SizedBox(width: 4),
                Text("Aşgabat, Mir 7/2, Jaý 9, Otag 32",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Divider(
            height: 2,
            color: ColorConstants.background,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                SvgPicture.asset(IconConstants.payment),
                SizedBox(width: 4),
                Text("750 TMT - 8000 TMT",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                SizedBox(width: 16),
                SvgPicture.asset(IconConstants.builder),
                SizedBox(width: 4),
                Text("15",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                SizedBox(width: 16),
                SvgPicture.asset(
                  IconConstants.eye,
                  height: 16,
                  width: 16,
                  color: ColorConstants.secondary,
                ),
                SizedBox(width: 4),
                Text("48", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
