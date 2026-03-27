import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/core/models/metadata_models.dart';
import '../models/job_model.dart';
import '../models/saved_request_model.dart';

class MyJobsService {
  final ApiService _api = ApiService();

  Future<JobResponseModel> getMyJobs({
    int page = 0,
    int limit = 20,
    bool myJobs = false,
    List<int>? catIds,
    List<int>? welayatIds,
    List<int>? etrapIds,
    List<DateTime>? dates,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? minPrice,
    double? maxPrice,
    String? search,
    int? status,
    String? sort,
    bool requestedInput = false,
    bool processingInput = false,
    bool requiresToken = true,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (requestedInput) {
      queryParams['requestedInput'] = 'true';
    }
    if (processingInput) {
      queryParams['processingInput'] = 'true';
    }

    if (sort != null) {
      queryParams['sort'] = sort;
      queryParams['sort_by'] = sort;
    }

    // queryParams['my_jobs'] = myJobs ? 'true' : 'false';

    if (minPrice != null) {
      queryParams['min_price'] = minPrice.toInt().toString();
    }
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice.toInt().toString();
    }

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (status != null) {
      queryParams['status'] = status.toString();
    }

    if (dateFrom != null) {
      queryParams['date_from'] = DateFormat('yyyy-MM-dd').format(dateFrom);
    }
    if (dateTo != null) {
      queryParams['date_to'] = DateFormat('yyyy-MM-dd').format(dateTo);
    }

    if (dates != null && dates.isNotEmpty) {
      queryParams['dates'] =
          dates.map((d) => DateFormat('yyyy-MM-dd').format(d)).join(',');
      // Also set date_from and date_to for compatibility if 2 dates are provided
      if (dates.length >= 2) {
        queryParams['date_from'] = DateFormat('yyyy-MM-dd').format(dates[0]);
        queryParams['date_to'] =
            DateFormat('yyyy-MM-dd').format(dates[dates.length - 1]);
      } else if (dates.length == 1) {
        queryParams['date_from'] = DateFormat('yyyy-MM-dd').format(dates[0]);
        queryParams['date_to'] = DateFormat('yyyy-MM-dd').format(dates[0]);
      }
    }

    if (catIds != null && catIds.isNotEmpty) {
      queryParams['categories'] = catIds.join(',');
    }
    if (welayatIds != null && welayatIds.isNotEmpty) {
      queryParams['welayat_id'] = welayatIds.join(',');
    }
    if (etrapIds != null && etrapIds.isNotEmpty) {
      queryParams['etrap_id'] = etrapIds.join(',');
    }

    final String queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final String endpoint = 'api/jobs?$queryString';

    print('-----------------------------------------');
    print('🚀 GETTING JOBS API 🚀');
    print('Endpoint: $endpoint');
    print('Requires Token: $requiresToken');
    print('-----------------------------------------');

    try {
      final response =
          await _api.getRequest(endpoint, requiresToken: requiresToken);
      print('Jobs API Response: $response');

      if (response != null) {
        final jobResponse = JobResponseModel.fromJson(response);
        print('Parsed Job Count: ${jobResponse.data.jobs.length}');
        return jobResponse;
      } else {
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      print('Error in getMyJobs: $e');
      rethrow;
    }
  }

  Future<JobDetailResponseModel> getJobDetail(int jobId) async {
    final String endpoint = 'api/job/$jobId';

    print('--- Getting Job Detail ---');
    print('Endpoint: $endpoint');

    try {
      final response = await _api.getRequest(endpoint, requiresToken: true);
      print('Job Detail API Response: $response');

      if (response != null) {
        final detailResponse = JobDetailResponseModel.fromJson(response);
        print('Parsed Job Name: ${detailResponse.job.name}');
        return detailResponse;
      } else {
        throw Exception('Failed to load job detail');
      }
    } catch (e) {
      print('Error in getJobDetail: $e');
      rethrow;
    }
  }

  Future<dynamic> deleteJob(int jobId, {String? reason}) async {
    final String endpoint =
        'api/user/masters/jobs/delete/$jobId'; // Adjust endpoint based on API

    try {
      final response = await _api.handleApiRequest(
        endpoint,
        method: 'POST',
        body: {'reason': reason ?? ''},
        requiresToken: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> sendJobRequest(int jobId,
      {required double price, required String comment}) async {
    final String endpoint = 'api/user/job-request/$jobId';

    final body = {
      'price': price,
      'comment': comment,
    };

    print('--- Sending Job Request (POST) ---');
    print('Endpoint: $endpoint');
    print('Request Body: $body');

    try {
      final response = await _api.handleApiRequest(
        endpoint,
        method: 'POST',
        body: body,
        requiresToken: true,
      );
      print('Response: $response');
      return response;
    } catch (e) {
      print('Error in sendJobRequest: $e');
      rethrow;
    }
  }

  Future<List<SavedRequestModel>> getSavedRequests() async {
    const String endpoint = 'api/user/get-saved-requests';
    try {
      print('--- Getting Saved Requests (GET) ---');
      print('Endpoint: $endpoint');
      final response = await _api.getRequest(endpoint, requiresToken: true);
      print('getSavedRequests API Response: $response');
      if (response != null) {
        final data = response['data'] ?? response['rows'];
        if (data is List) {
          return data
              .map((e) => SavedRequestModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error in getSavedRequests: $e');
      return [];
    }
  }

  Future<dynamic> deleteSavedRequest(int id) async {
    final String endpoint = 'api/user/delete-saved-request/$id';
    try {
      print('--- Deleting Saved Request (DELETE/POST) ---');
      print('Endpoint: $endpoint');
      // Using handleApiRequest with POST since many backends use POST for delete/actions
      // If the backend requires DELETE verb, we can adjust.
      final response = await _api.handleApiRequest(
        endpoint,
        method: 'POST',
        body: {},
        requiresToken: true,
      );
      print('deleteSavedRequest API Response: $response');
      return response;
    } catch (e) {
      print('Error in deleteSavedRequest: $e');
      rethrow;
    }
  }

  Future<dynamic> createSavedRequest(String comment) async {
    const String endpoint = 'api/user/create-saved-request';
    try {
      print('--- Creating Saved Request (POST) ---');
      print('Endpoint: $endpoint');
      print('Request Body: {comment: $comment}');
      final response = await _api.handleApiRequest(
        endpoint,
        method: 'POST',
        body: {'comment': comment},
        requiresToken: true,
      );
      print('createSavedRequest API Response: $response');
      return response;
    } catch (e) {
      print('Error in createSavedRequest: $e');
      rethrow;
    }
  }

  Future<double> fetchBalance() async {
    final lang = Get.locale?.languageCode ?? 'tk';
    final String endpoint = 'api/user/$lang/check-balance';

    try {
      final response = await _api.getRequest(endpoint, requiresToken: true);

      if (response != null && response['pocket'] != null) {
        return double.tryParse(response['pocket'].toString()) ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      print('Error in fetchBalance: $e');
      return 0.0;
    }
  }

  Future<bool> markJobDoneByMaster(int idToSend) async {
    // Note: this endpoint usually expects the request_id instead of the job_id
    final String endpoint = 'api/user/job-done-by-master/$idToSend';

    print('--- Mark Job Done By Master (POST) ---');
    print('Endpoint: $endpoint');

    try {
      final response = await _api.handleApiRequest(
        endpoint,
        method: 'POST',
        body: {},
        requiresToken: true,
      );

      print('markJobDoneByMaster API Response: $response');

      if (response is int) {
        return response >= 200 && response < 300;
      }

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) return true;
        if (response['status']?.toString().toLowerCase() == 'success') {
          return true;
        }
      }

      return true;
    } catch (e) {
      print('Error in markJobDoneByMaster: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchPocketLogs({int sort = 0}) async {
    final lang = Get.locale?.languageCode ?? 'tk';
    String endpoint = 'api/user/$lang/get-pocket-logs';
    if (sort == 1) endpoint = '$endpoint?logs=1';
    if (sort == 2) endpoint = '$endpoint?logs=2';

    print('--- Fetching Pocket Logs ---');
    try {
      final response = await _api.getRequest(endpoint, requiresToken: true);
      if (response != null && response['rows'] != null) {
        return response['rows'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error in fetchPocketLogs: $e');
      return [];
    }
  }

  Future<List<dynamic>> getBanks() async {
    final lang = Get.locale?.languageCode ?? 'tk';
    final String endpoint = 'api/user/$lang/get-banks';
    print('--- Fetching Banks (lang: $lang) ---');
    try {
      final response = await _api.getRequest(endpoint, requiresToken: true);
      print('Response from getBanks: $response');
      if (response != null && response['rows'] != null) {
        return response['rows'] as List<dynamic>;
      } else if (response != null && response['data'] != null) {
        return response['data'] as List<dynamic>;
      }
      print('Banks empty or unexpected structure');
      return [];
    } catch (e) {
      print('Error in getBanks: $e');
      return [];
    }
  }

  Future<dynamic> createOrder(
      {required int bankId, required String amount}) async {
    final lang = Get.locale?.languageCode ?? 'tk';
    final String endpoint = 'api/user/$lang/create-order';
    final body = {"bank_id": bankId, "summ": amount, "device": "MOBILE"};
    print('--- Creating Order ---');
    try {
      final response = await _api.handleApiRequest(
        endpoint,
        method: 'POST',
        body: body,
        requiresToken: true,
      );
      return response;
    } catch (e) {
      print('Error in createOrder: $e');
      return null;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    final lang = Get.locale?.languageCode ?? 'tk';
    const String endpoint = 'api/service-cats';
    try {
      print('DEBUG: Fetching categories from $endpoint with lang: $lang');
      final response = await _api.getRequest(endpoint, requiresToken: false);
      print('DEBUG: Categories response: $response');
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((e) => CategoryModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error in getCategories: $e');
      return [];
    }
  }

  Future<List<LocationModel>> getLocations() async {
    final lang = Get.locale?.languageCode ?? 'tk';
    final String endpoint = 'api/$lang/locations';
    try {
      final response = await _api.getRequest(endpoint, requiresToken: false);
      print('--- getLocations raw response: $response');
      if (response != null) {
        // Try 'data' key first, then 'rows'
        final list = response['data'] ?? response['rows'];
        if (list != null) {
          return (list as List).map((e) => LocationModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error in getLocations: $e');
      return [];
    }
  }
}
