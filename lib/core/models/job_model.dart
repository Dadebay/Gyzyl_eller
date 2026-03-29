class JobResponseModel {
  final bool success;
  final JobData data;

  JobResponseModel({required this.success, required this.data});

  factory JobResponseModel.fromJson(Map<String, dynamic> json) {
    return JobResponseModel(
      success: json['success'] ?? false,
      data: JobData.fromJson(json['data'] ?? {}),
    );
  }
}

class JobData {
  final int count;
  final List<JobModel> jobs;

  JobData({required this.count, required this.jobs});

  factory JobData.fromJson(Map<String, dynamic> json) {
    return JobData(
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      jobs: (json['jobs'] as List? ?? [])
          .map((item) => JobModel.fromJson(item))
          .toList(),
    );
  }
}

class JobDetailResponseModel {
  final bool success;
  final JobModel job;

  JobDetailResponseModel({required this.success, required this.job});

  factory JobDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return JobDetailResponseModel(
      success: json['success'] ?? false,
      job: JobModel.fromJson(json['data'] ?? {}),
    );
  }
}

class JobModel {
  final int id;
  final int catId;
  final String name;
  final String desc;
  final int minPrice;
  final int maxPrice;
  final int status;
  final int welayatId;
  final int etrapId;
  final String address;
  final String? phone;
  final String createdAt;
  final String whenToDo;
  final String? startDate;
  final String? endDate;
  final String categoryName;
  final String welayat;
  final String etrap;
  final String username;
  final String? image;
  final List<String> images;
  final List<JobFileModel> files;
  final List<String> catPath;
  final List<JobAnswer> answers;
  final int? responsesCount;
  final int? viewCount;
  final String? position;
  final int? requestId;
  final bool finished;
  final bool selected;

  JobModel({
    required this.id,
    required this.catId,
    required this.name,
    required this.desc,
    required this.minPrice,
    required this.maxPrice,
    required this.status,
    required this.welayatId,
    required this.etrapId,
    required this.address,
    this.phone,
    required this.createdAt,
    required this.whenToDo,
    this.startDate,
    this.endDate,
    required this.categoryName,
    required this.welayat,
    required this.etrap,
    required this.username,
    this.image,
    this.images = const [],
    this.files = const [],
    this.catPath = const [],
    this.answers = const [],
    this.responsesCount,
    this.viewCount,
    this.position,
    this.requestId,
    this.finished = false,
    this.selected = false,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? 0,
      catId: json['cat_id'] ?? 0,
      name: json['name'] ?? '',
      desc: json['desc'] ?? '',
      minPrice: json['min_price'] ?? 0,
      maxPrice: json['max_price'] ?? 0,
      status: json['status'] ?? 0,
      welayatId: json['welayat_id'] ?? 0,
      etrapId: json['etrap_id'] ?? 0,
      address: json['address'] ?? '',
      phone: json['phone']?.toString(),
      createdAt: json['created_at'] ?? '',
      whenToDo: json['when_to_do'] ?? '',
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      categoryName: json['category_name']?.toString().isNotEmpty == true
          ? json['category_name']
          : (json['cat_name']?.toString().isNotEmpty == true
              ? json['cat_name']
              : (json['category'] != null && json['category'] is Map && json['category']['name'] != null
                  ? json['category']['name']
                  : (json['cat_path'] is List && (json['cat_path'] as List).isNotEmpty
                      ? (json['cat_path'] as List).last.toString()
                      : ''))),
      welayat: json['welayat'] ?? '',
      etrap: json['etrap'] ?? '',
      username: json['username'] ?? '',
      image: json['image']?.toString(),
      images: (json['images'] as List? ?? []).map((e) => e.toString()).toList(),
      files: (json['files'] as List? ?? [])
          .map((item) => JobFileModel.fromJson(item))
          .toList(),
      catPath: (json['cat_path'] as List? ?? []).map((e) => e.toString()).toList(),
      answers: (json['answers'] as List? ?? [])
          .map((item) => JobAnswer.fromJson(item))
          .toList(),
      responsesCount: int.tryParse((json['responses_count'] ?? json['request_count'] ?? json['responses'])?.toString() ?? '0') ?? 0,
      viewCount: int.tryParse(json['view_count']?.toString() ?? '0') ?? 0,
      position: json['position']?.toString(),
      requestId: json['request_id'] != null
          ? int.tryParse(json['request_id'].toString())
          : (json['requestId'] != null
              ? int.tryParse(json['requestId'].toString())
              : null),
      finished: json['finished'] ?? false,
      selected: json['selected'] ?? false,
    );
  }
}

class JobAnswer {
  final int questionId;
  final String question;
  final String type;
  final String? formName;
  final int? formId;
  final List<JobAnswerOption>? options;
  final String? value;
  final String? date;
  final String? time;
  final int? locationId;
  final String? lat;
  final String? lng;

  JobAnswer({
    required this.questionId,
    required this.question,
    required this.type,
    this.formName,
    this.formId,
    this.options,
    this.value,
    this.date,
    this.time,
    this.locationId,
    this.lat,
    this.lng,
  });

  factory JobAnswer.fromJson(Map<String, dynamic> json) {
    return JobAnswer(
      questionId: json['question_id'] ?? 0,
      question: json['question'] ?? '',
      type: json['type'] ?? '',
      formName: json['form_name']?.toString(),
      formId: json['form_id'],
      options: (json['options'] as List?)
          ?.map((e) => JobAnswerOption.fromJson(e))
          .toList(),
      value: json['value']?.toString(),
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      locationId: json['location_id'] != null
          ? int.tryParse(json['location_id'].toString())
          : null,
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
    );
  }
}

class JobAnswerOption {
  final String optionName;

  JobAnswerOption({required this.optionName});

  factory JobAnswerOption.fromJson(Map<String, dynamic> json) {
    return JobAnswerOption(
      optionName: json['option_name'] ?? '',
    );
  }
}
class JobFileModel {
  final int id;
  final String file;
  final String fileType;

  JobFileModel({required this.id, required this.file, required this.fileType});

  factory JobFileModel.fromJson(Map<String, dynamic> json) {
    return JobFileModel(
      id: json['id'] ?? 0,
      file: json['file'] ?? '',
      fileType: json['file_type'] ?? '',
    );
  }
}
