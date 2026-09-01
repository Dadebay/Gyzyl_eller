// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
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
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';

/// Dedicated tag widget shown when an unread "price-set" (MASTER_REPLY)
/// notification exists for this job. Badge and this tag are driven by the
/// same reactive source (counterResponse.masterReplyCount) so they always
/// appear and disappear together.
class BahaGoyulanTag extends StatelessWidget {
  const BahaGoyulanTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedMoney03,
                size: 14,
                color: Color(0xFFE65100),
              ),
              const SizedBox(width: 4),
              Text(
                'status_price_set'.tr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE65100),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
  final int taskTabIndex;
  final VoidCallback? onOpened;

  /// When true, shows [BahaGoyulanTag] in place of the normal status tag.
  /// Driven by the same reactive signal as the notification badge so both
  /// appear and disappear at exactly the same time.
  final bool showPriceSetTag;

  /// Override the notification badge count shown on the card.
  /// When provided, this value takes priority over [job.notificationCount].
  /// Pass a reactive value (from JobNotificationController) so the badge
  /// updates without needing a full list rebuild.
  final int? notificationCountOverride;

  const JobCard({
    super.key,
    required this.job,
    this.isNew = false,
    required this.showDelete,
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
    this.showPriceSetTag = false,
    this.notificationCountOverride,
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

  @override
  Widget build(BuildContext context) {
    final int? myId = AuthStorage().getUserId();
    final bool isOtherSelected = job.status == 3 &&
        job.selectedUserId != null &&
        myId != null &&
        job.selectedUserId != myId;

    // status 3: başka usta seçildi, status 7: süresi doldu (expired)
    final bool isExpired = job.status == 7;
    final bool canDeleteJob = showDelete &&
        (job.status != 3 || isOtherSelected || job.finished || isExpired);
    return InkWell(
      onTap: () {
        print(showDelete);
        print(job.status);
        print(canDeleteJob);
        onOpened?.call();
        Get.to(
          () => const JobDetailView(),
          arguments: {
            'id': job.id,
            'responsesCount': job.responsesCount,
            'canDelete': canDeleteJob,
            'showDelete': showDelete,
            'fromAllView': fromAllView,
            'fromTaskView': fromTaskView,
            'taskTabIndex': taskTabIndex,
          },
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: ColorConstants.whiteColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      const SizedBox(
                        width: 10,
                      ),
                      Builder(builder: (context) {
                        final effectiveCount = notificationCountOverride ??
                            (job.notificationCount ?? 0);
                        if (effectiveCount <= 0) return const SizedBox.shrink();
                        return Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '$effectiveCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                          ),
                        );
                      }),
                      const Spacer(),
                      if (canDeleteJob)
                        GestureDetector(
                          onTap: () async {
                            final bool isProposal =
                                fromTaskView && taskTabIndex == 0;
                            final deleted = await DialogUtils()
                                .showDeleteJobDialog(context, job.id,
                                    isRequest: isProposal);
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
                  showPriceSetTag
                      ? const BahaGoyulanTag()
                      : NewTag(
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
                            child: _DateStatusRow(job: job),
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
                          icon: IconConstants.eye,
                          text: "${job.viewCount ?? 0}"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateStatusRow extends StatefulWidget {
  final JobModel job;
  const _DateStatusRow({required this.job});

  @override
  State<_DateStatusRow> createState() => _DateStatusRowState();
}

class _DateStatusRowState extends State<_DateStatusRow> {
  static final Map<int, String> _globalDateCache = {};
  static final Map<int, Future<String?>> _inflightDateRequests = {};
  static final List<Completer<void>> _dateFetchWaitQueue = [];
  static int _activeDateFetches = 0;
  static const int _maxConcurrentDateFetches = 2;

  String? _resolvedDate;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    final job = widget.job;

    if (_globalDateCache.containsKey(job.id)) {
      _resolvedDate = _globalDateCache[job.id];
    }

    final isInvalidDate = job.startDate == null ||
        job.startDate!.isEmpty ||
        job.startDate == 'null';

    final needsFetch = job.whenToDo == 'special_date' &&
        isInvalidDate &&
        job.answers.every((a) => a.date == null || a.date!.isEmpty);

    if (needsFetch && _resolvedDate == null) {
      _fetchDate();
    }
  }

  @override
  void didUpdateWidget(covariant _DateStatusRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.job.id != widget.job.id ||
        oldWidget.job.startDate != widget.job.startDate ||
        oldWidget.job.whenToDo != widget.job.whenToDo) {
      setState(() {
        _resolvedDate = _globalDateCache[widget.job.id];
      });

      final isInvalidDate = widget.job.startDate == null ||
          widget.job.startDate!.isEmpty ||
          widget.job.startDate == 'null';

      final needsFetch = widget.job.whenToDo == 'special_date' &&
          isInvalidDate &&
          widget.job.answers.every((a) => a.date == null || a.date!.isEmpty);

      if (needsFetch && _resolvedDate == null) {
        _fetchDate();
      }
    }
  }

  Future<void> _fetchDate() async {
    if (_isFetching) return;
    _isFetching = true;

    final jobId = widget.job.id;

    if (_globalDateCache.containsKey(jobId)) {
      if (mounted) {
        setState(() {
          _resolvedDate = _globalDateCache[jobId];
        });
      }
      _isFetching = false;
      return;
    }

    try {
      Future<String?> request = _inflightDateRequests[jobId] ??
          _withDateFetchSlot(() => _loadDateFromDetail(jobId));

      _inflightDateRequests[jobId] = request;

      final foundDate = await request;
      if (identical(_inflightDateRequests[jobId], request)) {
        _inflightDateRequests.remove(jobId);
      }

      if (!mounted) {
        _isFetching = false;
        return;
      }

      if (foundDate != null && foundDate.isNotEmpty) {
        setState(() {
          _resolvedDate = foundDate;
        });
      }
    } catch (_) {
      _inflightDateRequests.remove(jobId);
    } finally {
      _isFetching = false;
    }
  }

  Future<T> _withDateFetchSlot<T>(Future<T> Function() action) async {
    if (_activeDateFetches >= _maxConcurrentDateFetches) {
      final completer = Completer<void>();
      _dateFetchWaitQueue.add(completer);
      await completer.future;
    }

    _activeDateFetches++;
    try {
      return await action();
    } finally {
      _activeDateFetches--;
      if (_dateFetchWaitQueue.isNotEmpty) {
        _dateFetchWaitQueue.removeAt(0).complete();
      }
    }
  }

  Future<String?> _loadDateFromDetail(int jobId) async {
    final detail = await MyJobsService().getJobDetail(jobId);

    String? foundDate;
    for (final answer in detail.job.answers) {
      if (answer.date != null &&
          answer.date!.isNotEmpty &&
          answer.date != 'null') {
        foundDate = _formatAnswerDate(answer.date!, answer.time);
        break;
      }
    }

    if (foundDate == null &&
        detail.job.startDate != null &&
        detail.job.startDate!.isNotEmpty &&
        detail.job.startDate != 'null') {
      foundDate = _formatDateRange(detail.job.startDate, detail.job.endDate);
    }

    if (foundDate != null && foundDate.isNotEmpty) {
      _globalDateCache[jobId] = foundDate;
    }
    return foundDate;
  }

  String _formatAnswerDate(String dateStr, String? timeStr) {
    try {
      final date = DateTime.parse(dateStr);
      return _formatSingleDateTime(date, explicitTime: timeStr);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    String text = _resolvedDate ?? _formatDateStatus(context, widget.job);
    if (_resolvedDate == null && _isFetching) {
      text = '...';
    }
    return InfoRowRed(icon: IconConstants.calendar, text: text);
  }

  String _formatSingleDateTime(DateTime date, {String? explicitTime}) {
    final d = date.toLocal();
    final weekday = 'weekday_${d.weekday}'.tr;
    final month = 'month_${d.month}'.tr;
    final dayPart = '$weekday, ${d.day.toString().padLeft(2, '0')} $month';

    return dayPart; // time kaldırıldı
  }

  String _formatDateStatus(BuildContext context, JobModel job) {
    if (job.whenToDo == 'during_the_week') {
      if (job.startDate != null &&
          job.startDate!.isNotEmpty &&
          job.startDate != 'null' &&
          job.endDate != null &&
          job.endDate!.isNotEmpty &&
          job.endDate != 'null') {
        final range = _formatDateRange(job.startDate, job.endDate);
        if (range.isNotEmpty) return range;
      }
      return job.whenToDo.tr;
    }

    if (job.whenToDo == 'date_today' || job.whenToDo == 'date_tomorrow') {
      if (job.startDate != null &&
          job.startDate!.isNotEmpty &&
          job.startDate != 'null') {
        try {
          final taskDate = DateTime.parse(job.startDate!);
          return "${job.whenToDo.tr} (${_formatSingleDateTime(taskDate)})";
        } catch (_) {}
      }
      return job.whenToDo.tr;
    }

    // Skip generic startDate handling for special_date tasks to avoid showing date_today incorrectly
    if (job.whenToDo != 'special_date' &&
        job.startDate != null &&
        job.startDate!.isNotEmpty &&
        job.startDate != 'null') {
      try {
        final taskDate = DateTime.parse(job.startDate!);
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));

        if (taskDate.year == now.year &&
            taskDate.month == now.month &&
            taskDate.day == now.day) {
          return "${"date_today".tr} (${_formatSingleDateTime(taskDate)})";
        }

        if (taskDate.year == tomorrow.year &&
            taskDate.month == tomorrow.month &&
            taskDate.day == tomorrow.day) {
          return "${"date_tomorrow".tr} (${_formatSingleDateTime(taskDate)})";
        }

        final range = _formatDateRange(job.startDate, job.endDate);
        if (range.isNotEmpty) return range;
      } catch (_) {}
    }

    if (job.whenToDo == 'urgent' || job.whenToDo.isEmpty) {
      return 'urgent_label'.tr;
    }

    if (job.whenToDo == 'special_date') {
      // Try to get date from answers first
      for (final answer in job.answers) {
        if (answer.date != null && answer.date!.isNotEmpty) {
          final range = _formatDateRange(answer.date, null);
          if (range.isNotEmpty) return range;
        }
      }
      // If no answer date, fallback to job's start and end dates
      if (job.startDate != null &&
          job.startDate!.isNotEmpty &&
          job.startDate != 'null') {
        final range = _formatDateRange(job.startDate, job.endDate);
        if (range.isNotEmpty) return range;
      }
      return 'i_will_choose_date'.tr;
    }

    return job.whenToDo.tr;
  }

  String _formatDateRange(String? start, String? end) {
    if ((start == null || start == 'null') && (end == null || end == 'null')) {
      return '';
    }
    if (start != null &&
        start != 'null' &&
        (end == null || end == 'null' || start == end)) {
      try {
        final date = DateTime.parse(start);
        return _formatSingleDateTime(date);
      } catch (_) {
        return start;
      }
    }
    try {
      final startDate = DateTime.parse(start!);
      final endDate = DateTime.parse(end!);
      if (startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day) {
        return _formatSingleDateTime(startDate);
      }
      // Different days: plain dd.MM.yyyy - dd.MM.yyyy (no weekday)
      final fmt = DateFormat('dd.MM.yyyy');
      return '${fmt.format(startDate)} - ${fmt.format(endDate)}';
    } catch (_) {
      return "${start ?? ''} - ${end ?? ''}";
    }
  }
}
