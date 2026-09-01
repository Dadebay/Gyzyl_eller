class JobNotificationCounter {
  final String id;
  final String jobId;
  final int typeId;
  final String? description;
  final DateTime? createdAt;

  JobNotificationCounter({
    required this.id,
    required this.jobId,
    required this.typeId,
    this.description,
    this.createdAt,
  });

  factory JobNotificationCounter.fromMap(Map<String, dynamic> map) {
    return JobNotificationCounter(
      // Use .toString() so int/String JSON values both compare correctly
      id: map['id']?.toString() ?? '',
      jobId: map['job_id']?.toString() ?? '',
      typeId: map['type_id'] ?? 0,
      description: map['description'],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'job_id': jobId,
      'type_id': typeId,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  JobNotificationCounter copyWith({
    String? id,
    String? jobId,
    int? typeId,
    String? description,
    DateTime? createdAt,
  }) {
    return JobNotificationCounter(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      typeId: typeId ?? this.typeId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class JobNotificationCounterResponse {
  final int newRequestCount;
  final int requestSelectedCount;
  final int requestFinishedCount;
  final int jobStatusChangedCount;
  final int masterReplyCount;
  final List<JobNotificationCounter> items;

  JobNotificationCounterResponse({
    required this.newRequestCount,
    required this.requestSelectedCount,
    required this.requestFinishedCount,
    required this.jobStatusChangedCount,
    this.masterReplyCount = 0,
    required this.items,
  });

  int get totalCount =>
      newRequestCount +
      requestSelectedCount +
      requestFinishedCount +
      jobStatusChangedCount +
      masterReplyCount;

  Map<String, dynamic> toMap() {
    return {
      'new_request_count': newRequestCount,
      'request_selected_count': requestSelectedCount,
      'request_finished_count': requestFinishedCount,
      'job_status_changed_count': jobStatusChangedCount,
      'master_reply_count': masterReplyCount,
      'items': items.map((i) => i.toMap()).toList(),
    };
  }

  factory JobNotificationCounterResponse.fromMap(Map<String, dynamic> map) {
    int newReq = 0;
    int selected = 0;
    int finished = 0;
    int statusChanged = 0;
    int masterReply = 0;

    final List? byType = map['by_type'] as List?;
    if (byType != null) {
      for (var item in byType) {
        final typeId = item['type_id'];
        final count = item['count'] ?? 0;
        if (typeId == 1) newReq = count;
        if (typeId == 2) selected = count;
        if (typeId == 3) finished = count;
        if (typeId == 4) statusChanged = count;
        if (typeId == 5) masterReply = count;
      }
    }

    return JobNotificationCounterResponse(
      newRequestCount: newReq,
      requestSelectedCount: selected,
      requestFinishedCount: finished,
      jobStatusChangedCount: statusChanged,
      masterReplyCount: masterReply,
      items: (map['items'] as List?)
              ?.map((e) =>
                  JobNotificationCounter.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  JobNotificationCounterResponse copyWith({
    int? newRequestCount,
    int? requestSelectedCount,
    int? requestFinishedCount,
    int? jobStatusChangedCount,
    int? masterReplyCount,
    List<JobNotificationCounter>? items,
  }) {
    return JobNotificationCounterResponse(
      newRequestCount: newRequestCount ?? this.newRequestCount,
      requestSelectedCount: requestSelectedCount ?? this.requestSelectedCount,
      requestFinishedCount: requestFinishedCount ?? this.requestFinishedCount,
      jobStatusChangedCount:
          jobStatusChangedCount ?? this.jobStatusChangedCount,
      masterReplyCount: masterReplyCount ?? this.masterReplyCount,
      items: items ?? this.items,
    );
  }
}
