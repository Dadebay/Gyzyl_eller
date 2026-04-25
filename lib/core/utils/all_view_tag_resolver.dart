// ignore_for_file: deprecated_member_use

import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gyzyleller/core/models/job_model.dart';

class AllViewTagData {
  final bool hideTag;
  final String label;
  final Color textColor;
  final Color bgColor;
  final Widget icon;

  const AllViewTagData({
    this.hideTag = false,
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.icon,
  });
}

class AllViewTagResolver {
  static const String _loginAtKey = 'all_view_login_at';
  static const String _viewedJobsKey = 'all_view_seen_jobs';
  static const String _historicallyNewKey = 'all_view_historically_new_jobs';

  final GetStorage _storage = GetStorage();
  final AuthStorage _authStorage = AuthStorage();

  static final Set<int> _thisSessionNewJobs = {};

  AllViewTagData resolve(JobModel job, {required bool isLoggedIn}) {
    if (job.status == 7) {
      return AllViewTagData(
        label: 'status_expired'.tr,
        textColor: ColorConstants.kPrimaryColor2,
        bgColor: ColorConstants.kPrimaryColor2.withOpacity(0.1),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedTimer02,
          size: 14,
          color: ColorConstants.kPrimaryColor2,
        ),
      );
    }
    if (job.status == 4) {
      return AllViewTagData(
        label: 'status_done'.tr,
        textColor: Colors.black,
        bgColor: Colors.grey.shade200,
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedCheckmarkCircle03,
          size: 14,
          color: Colors.black,
        ),
      );
    }
    if (_isSelectedMasterJob(job)) {
      return AllViewTagData(
        label: 'status_worker_selected'.tr,
        textColor: ColorConstants.blue,
        bgColor: Colors.blue.withOpacity(0.1),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedUserCheck01,
          size: 14,
          color: ColorConstants.blue,
        ),
      );
    }
    bool isNewStatus = isLoggedIn && _isCreatedAfterLogin(job.createdAt);

    if (isNewStatus) {
      final historicallyNew = _readHistoricallyNewJobs();
      if (historicallyNew.contains(job.id)) {
        if (!_thisSessionNewJobs.contains(job.id)) {
          isNewStatus = false; // Seen in a previous session
        }
      } else {
        _thisSessionNewJobs.add(job.id);
        historicallyNew.add(job.id);
        List<int> toSave = historicallyNew.toList();
        if (toSave.length > 2000) {
          toSave = toSave.sublist(toSave.length - 2000);
        }
        _storage.write(_historicallyNewKey, toSave);
      }
    }

    if (isNewStatus && _isViewedWithin24Hours(job.id)) {
      return AllViewTagData(
        label: 'status_viewed'.tr,
        textColor: const Color(0xFF757575),
        bgColor: const Color(0xFFF1F1F1),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedEye,
          size: 14,
          color: Color(0xFF757575),
        ),
      );
    }
    if (isNewStatus) {
      return AllViewTagData(
        label: 'status_new'.tr,
        textColor: ColorConstants.whiteColor,
        bgColor: Colors.blue.withOpacity(0.7),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedSparkles,
          size: 14,
          color: ColorConstants.whiteColor,
        ),
      );
    }
    if (_isViewedWithin24Hours(job.id)) {
      return AllViewTagData(
        label: 'status_viewed'.tr,
        textColor: const Color(0xFF757575),
        bgColor: const Color(0xFFF1F1F1),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedEye,
          size: 14,
          color: Color(0xFF757575),
        ),
      );
    }
    return const AllViewTagData(
      hideTag: true,
      label: 'Statussyz',
      textColor: Color(0xFF616161),
      bgColor: Color(0xFFF5F5F5),
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedCircle,
        size: 14,
        color: Color(0xFF9E9E9E),
      ),
    );
  }

  void markViewed(int jobId) {
    final map = _readViewedMap();
    map[jobId.toString()] = DateTime.now().toIso8601String();
    _storage.write(_viewedJobsKey, map);
  }

  bool _isSelectedMasterJob(JobModel job) {
    if (job.status != 3) return false;
    final user = _authStorage.getUser();
    final currentUserId = int.tryParse((user?['id'] ?? '').toString());
    if (currentUserId == null) return false;
    return job.selectedUserId != null && job.selectedUserId != currentUserId;
  }

  bool _isCreatedAfterLogin(String createdAtRaw) {
    final loginAtRaw = _storage.read<String>(_loginAtKey);
    if (loginAtRaw == null || loginAtRaw.isEmpty) return false;
    final loginAt = DateTime.tryParse(loginAtRaw)?.toUtc();
    // Backend sends created_at without timezone → treat as UTC by appending 'Z'
    final normalizedCreatedAt =
        (createdAtRaw.endsWith('Z') || createdAtRaw.contains('+'))
            ? createdAtRaw
            : '${createdAtRaw}Z';
    final createdAt = DateTime.tryParse(normalizedCreatedAt)?.toUtc();
    if (loginAt == null || createdAt == null) return false;
    return createdAt.isAfter(loginAt);
  }

  bool _isViewedWithin24Hours(int jobId) {
    final map = _readViewedMap();
    final viewedAtRaw = map[jobId.toString()];
    if (viewedAtRaw == null || viewedAtRaw.isEmpty) return false;
    final viewedAt = DateTime.tryParse(viewedAtRaw);
    if (viewedAt == null) return false;
    if (DateTime.now().difference(viewedAt) > const Duration(hours: 24)) {
      map.remove(jobId.toString());
      _storage.write(_viewedJobsKey, map);
      return false;
    }
    return true;
  }

  Map<String, String> _readViewedMap() {
    final dynamic raw = _storage.read(_viewedJobsKey);
    if (raw is! Map) return <String, String>{};
    final result = <String, String>{};
    raw.forEach((key, value) {
      if (key != null && value != null) {
        result[key.toString()] = value.toString();
      }
    });
    return result;
  }

  Set<int> _readHistoricallyNewJobs() {
    final dynamic raw = _storage.read(_historicallyNewKey);
    if (raw is List) {
      return raw.map((e) => int.tryParse(e.toString()) ?? 0).toSet();
    }
    return <int>{};
  }
}
