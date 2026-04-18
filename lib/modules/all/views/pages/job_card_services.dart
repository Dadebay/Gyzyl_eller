import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/models/job_model.dart';
import 'package:gyzyleller/modules/all/views/pages/info_row.dart';
import 'package:gyzyleller/modules/all/views/pages/job_detail_view.dart';
import 'package:gyzyleller/modules/all/views/pages/new_tag.dart';
import 'package:gyzyleller/modules/all/views/pages/small_info.dart';
import 'package:gyzyleller/modules/all/views/pages/info_row_red.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/dialogs/dialogs_utils.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final bool isNew;
  final bool showDelete;
  final VoidCallback? onDeleted;
  final String? customTagLabel;
  final Color? customTagTextColor;
  final Color? customTagBgColor;
  final Widget? customTagIcon;
  final bool hideTag;
  final bool fromAllView;
  final bool fromTaskView;
  final int taskTabIndex; // 0 = sol (requested), 1 = sag (processing)
  final VoidCallback? onOpened;

  const JobCard({
    super.key,
    required this.job,
    this.isNew = false,
    this.showDelete = false,
    this.onDeleted,
    this.customTagLabel,
    this.customTagTextColor,
    this.customTagBgColor,
    this.customTagIcon,
    this.hideTag = false,
    this.fromAllView = false,
    this.fromTaskView = false,
    this.taskTabIndex = 0,
    this.onOpened,
  });

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      final month = 'month_${dateTime.month}'.tr;
      return "${dateTime.day} $month ${dateTime.year}, ${DateFormat('HH:mm').format(dateTime)}";
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateStatus(BuildContext context, JobModel job) {
    if (job.whenToDo == 'date_today' || job.whenToDo == 'date_tomorrow') {
      if (job.startDate != null && job.startDate!.isNotEmpty) {
        try {
          final taskDate = DateTime.parse(job.startDate!);
          final dateFormat = DateFormat(
              'EEEE, dd MMMM', Localizations.localeOf(context).toString());
          final timeStr = DateFormat('HH:mm').format(taskDate);
          return "${job.whenToDo.tr} (${dateFormat.format(taskDate)}) $timeStr";
        } catch (_) {}
      }
      return job.whenToDo.tr;
    }

    if (job.startDate != null && job.startDate!.isNotEmpty) {
      try {
        final taskDate = DateTime.parse(job.startDate!);
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final dateFormat = DateFormat(
            'EEEE, dd MMMM', Localizations.localeOf(context).toString());

        if (taskDate.year == now.year &&
            taskDate.month == now.month &&
            taskDate.day == now.day) {
          return "${"date_today".tr} (${dateFormat.format(now)}) ${DateFormat('HH:mm').format(taskDate)}";
        }

        if (taskDate.year == tomorrow.year &&
            taskDate.month == tomorrow.month &&
            taskDate.day == tomorrow.day) {
          return "${"date_tomorrow".tr} (${dateFormat.format(tomorrow)}) ${DateFormat('HH:mm').format(taskDate)}";
        }

        final range = _formatDateRange(job.startDate, job.endDate);
        if (range.isNotEmpty) return range;
      } catch (_) {}
    }

    if (job.whenToDo == 'urgent' || job.whenToDo.isEmpty) {
      return 'urgent_label'.tr;
    }

    if (job.whenToDo == 'special_date') {
      return 'i_will_choose_date'.tr;
    }

    return job.whenToDo.tr;
  }

  String _formatDateRange(String? start, String? end) {
    if (start == null && end == null) return '';
    if (start != null && (end == null || start == end)) {
      try {
        final date = DateTime.parse(start);
        return DateFormat('dd.MM.yyyy HH:mm').format(date);
      } catch (_) {
        return start;
      }
    }
    try {
      final startDate = DateTime.parse(start!);
      final endDate = DateTime.parse(end!);
      final formatter = DateFormat('dd.MM.yyyy');
      if (startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day) {
        return "${DateFormat('dd.MM.yyyy HH:mm').format(startDate)} - ${DateFormat('HH:mm').format(endDate)}";
      }
      return "${formatter.format(startDate)} - ${formatter.format(endDate)}";
    } catch (_) {
      return "${start ?? ''} - ${end ?? ''}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canDeleteJob = showDelete && job.status != 3;
    return InkWell(
      onTap: () {
        onOpened?.call();
        Get.to(
          () => const JobDetailView(),
          arguments: {
            'id': job.id,
            'responsesCount': job.responsesCount,
            'canDelete': canDeleteJob,
            'fromAllView': fromAllView,
            'fromTaskView': fromTaskView,
            'taskTabIndex': taskTabIndex,
          },
        );
      },
      child: Card(
        color: ColorConstants.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_formatDate(job.createdAt),
                      style: const TextStyle(
                          color: ColorConstants.secondary, fontSize: 13)),
                  const Spacer(),
                  if (canDeleteJob)
                    GestureDetector(
                      onTap: () async {
                        final deleted = await DialogUtils()
                            .showDeleteJobDialog(context, job.id);
                        if (deleted == true && onDeleted != null) {
                          onDeleted!();
                        }
                      },
                      child: SvgPicture.asset(IconConstants.deletee),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(job.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.fonts)),
              const SizedBox(height: 10),
              NewTag(
                status: job.status,
                hideTag: hideTag,
                customLabel: customTagLabel,
                customTextColor: customTagTextColor,
                customBgColor: customTagBgColor,
                customIcon: customTagIcon,
              ),
              const SizedBox(height: 10),
              const Divider(height: 2, color: ColorConstants.background),
              const SizedBox(height: 12),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorConstants.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: InfoRowRed(
                          icon: IconConstants.calendar,
                          text: _formatDateStatus(context, job),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text("job_date_label".tr,
                      style: const TextStyle(
                          color: ColorConstants.fonts, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              InfoRow(icon: IconConstants.grid, text: job.categoryName),
              const SizedBox(height: 6),
              InfoRow(
                icon: IconConstants.locationHouse,
                text: "${job.welayat}, ${job.etrap}",
              ),
              const SizedBox(height: 6),
              const Divider(height: 2, color: ColorConstants.background),
              const SizedBox(height: 6),
              Row(
                children: [
                  SmallInfo(
                    icon: IconConstants.payment,
                    text: (job.minPrice == 0 && job.maxPrice == 0)
                        ? 'not_priced'.tr
                        : '${job.minPrice} TMT - ${job.maxPrice} TMT',
                  ),
                  const SizedBox(width: 16),
                  SmallInfo(
                    icon: IconConstants.builder,
                    text: "${job.responsesCount ?? 0}",
                    color: ColorConstants.secondary,
                  ),
                  const SizedBox(width: 16),
                  SmallInfo(
                      icon: IconConstants.eye, text: "${job.viewCount ?? 0}"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
