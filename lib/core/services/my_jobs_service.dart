// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
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
    double? lat,
    double? lng,
    bool requestedInput = false,
    bool processingInput = false,
    bool selected = false,
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
    if (requestedInput || processingInput || selected) {
      queryParams['selected'] = selected.toString();
    }

    if (sort != null) {
      queryParams['sort'] = sort;
      queryParams['sort_by'] = sort;
    }

    if (lat != null) {
      queryParams['lat'] = lat.toStringAsFixed(6);
      queryParams['latitude'] = lat.toStringAsFixed(6);
      queryParams['user_lat'] = lat.toStringAsFixed(6);
    }
    if (lng != null) {
      queryParams['lng'] = lng.toStringAsFixed(6);
      queryParams['longitude'] = lng.toStringAsFixed(6);
      queryParams['user_lng'] = lng.toStringAsFixed(6);
    }

    if (minPrice != null) {
      queryParams['min_price'] = minPrice.toInt().toString();
    }
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice.toInt().toString();
    }

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = Uri.encodeComponent(search);
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
    if (etrapIds != null && etrapIds.isNotEmpty) {
      queryParams['etrap_ids'] = etrapIds.join(',');
      // Do NOT send welayat_id when etraps are selected — backend treats them
      // as AND conditions which returns 0 results.
    } else if (welayatIds != null && welayatIds.isNotEmpty) {
      queryParams['welayat_id'] = welayatIds.join(',');
    }

    final String queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
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
    final String endpoint = 'api/user/job/delete-done/$jobId';

    print('--- Deleting Job ---');
    print('Job ID: $jobId');
    print('Endpoint: $endpoint');

    try {
      final response = await _api.handleApiRequest(
        endpoint,
        method: 'POST',
        body: {},
        requiresToken: true,
      );
      print('Delete job response: $response');
      return response;
    } catch (e) {
      print('Error deleting job: $e');
      rethrow;
    }
  }

  Future<dynamic> deleteJobRequest(int jobId) async {
    final String endpoint = 'api/user/job/delete-done/$jobId';

    print('--- Deleting Job Request ---');
    print('Job ID: $jobId');
    print('Endpoint: $endpoint');

    try {
      final response = await _api.handleApiRequest(
        endpoint,
        method: 'POST',
        body: {},
        requiresToken: true,
      );
      print('Delete job request response: $response');
      return response;
    } catch (e) {
      print('Error deleting job request: $e');
      rethrow;
    }
  }

  String getSendJobRequestUrl(int jobId) {
    return '${Api().urlLink}api/user/job-request/$jobId';
  }

  Future<dynamic> sendJobRequest(int jobId,
      {required double price, required String comment}) async {
    final String url = getSendJobRequestUrl(jobId);
    final String? token = AuthStorage().token;
    final String langCode = GetStorage().read<String>('langCode') ?? 'tk';

    final Map<String, dynamic> body = {
      'price': price,
      'comment': comment,
    };

    print('--- Sending Job Request (http POST) ---');
    print('URL: $url');
    print('Comment length (chars): ${comment.length}');
    print('Comment UTF-8 bytes: ${utf8.encode(comment).length}');
    print('Body: $body');
    print('Authorization Token: Bearer $token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Content-Language': langCode,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      print('✅ Status: ${response.statusCode}');
      print('✅ Response body: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isNotEmpty
            ? json.decode(response.body)
            : response.statusCode;
      } else {
        throw Exception(
            'Server error ${response.statusCode}: ${response.body}');
      }
    } catch (e, stack) {
      print('========== sendJobRequest ERROR ==========');
      print('Error type: ${e.runtimeType}');
      print('Error: $e');
      print('Stack: $stack');
      print('==========================================');
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
    final body = {"bank_id": bankId, "summ": amount, "device": "DESKTOP"};
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
    final langWeb = GetStorage().read('langCode') ?? 'tk';
    const String endpoint = 'api/service-cats';
    try {
      print('==============================================');
      print('📦 [getCategories] GET $endpoint  lang=$langWeb');
      final response = await _api.getRequest(
        endpoint,
        requiresToken: false,
        headers: {
          'Content-Language': langWeb,
        },
      );
      if (response != null && response['data'] != null) {
        final cats = (response['data'] as List)
            .map((e) => CategoryModel.fromJson(e))
            .toList();
        print('✅ [getCategories] ${cats.length} categories loaded');
        for (final c in cats) {
          print(
              '   cat id=${c.id}  name="${c.name}"  subcats=${c.subcategories.length}');
        }
        print('==============================================');
        return cats;
      }
      print('⚠️ [getCategories] empty or null data');
      print('==============================================');
      return [];
    } catch (e) {
      print('❌ [getCategories] error: $e');
      print('==============================================');
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

  Future<void> saveMasterSearch({
    required List<int> catIds,
    required List<int> etrapIds,
    List<int> welayatIds = const [],
    required double? minPrice,
    required double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    const String endpoint = 'api/user/master/save-search';
    final body = {
      'cats': catIds,
      'etraps': etrapIds,
      'welayats': welayatIds,
      'min_price': minPrice,
      'max_price': maxPrice,
      if (startDate != null)
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
      if (endDate != null) 'end_date': DateFormat('yyyy-MM-dd').format(endDate),
    };
    print('==============================================');
    print('💾 [saveMasterSearch] POST $endpoint');
    print('   cats      : $catIds');
    print('   etraps    : $etrapIds');
    print('   welayats  : $welayatIds');
    print('   min_price : $minPrice');
    print('   max_price : $maxPrice');
    print(
        '   start_date: ${startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : null}');
    print(
        '   end_date  : ${endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : null}');
    print('   full body : $body');
    try {
      final response = await _api.handleApiRequest(
        endpoint,
        method: 'POST',
        body: body,
        requiresToken: true,
      );
      print('✅ [saveMasterSearch] response: $response');
    } catch (e) {
      print('❌ [saveMasterSearch] error: $e');
    }
    print('==============================================');
  }

  Future<Map<String, dynamic>?> getMasterSavedSearch() async {
    const String endpoint = 'api/user/master/save-search';
    print('🚀 [MyJobsService] GET - Fetch Master Saved Search');
    print('Endpoint: $endpoint');
    try {
      final response = await _api.getRequest(endpoint, requiresToken: true);
      print('✅ [filterget] Response: $response');

      if (response != null) {
        final Map<String, dynamic> result = {};

        // The response contains 'data' which is a list. We take the first item if it exists.
        final List? dataList = response['data'] as List?;
        if (dataList == null || dataList.isEmpty) return null;

        final firstItem = dataList.first as Map<String, dynamic>;

        // Parse Categories (extracted from gyzyl_cat_id field)
        final dynamic catsData = firstItem['cats'];
        if (catsData is List) {
          result['cats'] = catsData
              .map((e) =>
                  int.tryParse((e is Map ? e['gyzyl_cat_id'] : e).toString()) ??
                  0)
              .where((id) => id != 0)
              .toList();
        }

        // Parse Etraps (extracted from etrap_id field)
        final dynamic etrapsData = firstItem['etraps'];
        if (etrapsData is List) {
          result['etraps'] = etrapsData
              .map((e) =>
                  int.tryParse((e is Map ? e['etrap_id'] : e).toString()) ?? 0)
              .where((id) => id != 0)
              .toList();
        }

        // Parse Min Price
        final dynamic minPriceData = firstItem['min_price'];
        if (minPriceData != null) {
          result['min_price'] = double.tryParse(minPriceData.toString());
        }

        // Parse Max Price
        final dynamic maxPriceData = firstItem['max_price'];
        if (maxPriceData != null) {
          result['max_price'] = double.tryParse(maxPriceData.toString());
        }

        // Parse Dates
        final dynamic startDateData = firstItem['start_date'];
        if (startDateData != null && startDateData.toString().isNotEmpty) {
          result['start_date'] = startDateData.toString();
        }
        final dynamic endDateData = firstItem['end_date'];
        if (endDateData != null && endDateData.toString().isNotEmpty) {
          result['end_date'] = endDateData.toString();
        }

        return result;
      }
      return null;
    } catch (e) {
      print('Error in getMasterSavedSearch: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMyRequestOnJob(int jobId) async {
    final String endpoint = 'api/user/job-requests/$jobId';
    print('🚀 [MyJobsService] GET - My Request on Job');
    print('Endpoint: $endpoint');
    try {
      final response = await _api.getRequest(endpoint, requiresToken: true);
      print('✅ [MyJobsService] Request Details Response: $response');
      return response;
    } catch (e) {
      print('❌ [MyJobsService] Error in getMyRequestOnJob: $e');
      return null;
    }
  }

  Future<dynamic> editReview(String reviewId, String reviewText) async {
    final String endpoint = 'api/user/master/reply-to-review/$reviewId';
    final body = {
      'review': reviewText,
    };
    print('🚀 [MyJobsService] POST - Edit Review');
    print('Endpoint: $endpoint');
    return await _api.handleApiRequest(
      endpoint,
      method: 'POST',
      body: body,
      requiresToken: true,
    );
  }

  Future<dynamic> editReviewWithRating(
      String jobId, int rating, String reviewText) async {
    // Ayterek uses the same endpoint for both creating and updating reviews
    final String endpoint = 'api/user/job-done-by-user/$jobId';
    final body = {
      'rating': rating,
      'review': reviewText,
    };
    print('🚀 [MyJobsService] POST - Edit Review with Rating');
    print('Endpoint: $endpoint');
    print('Body: $body');
    return await _api.handleApiRequest(
      endpoint,
      method: 'POST',
      body: body,
      requiresToken: true,
    );
  }

  Future<dynamic> replyToReview(String reviewId, String replyText) async {
    final String endpoint = 'api/user/master/reply-to-review/$reviewId';
    final body = {
      'reply': replyText,
    };
    print('🚀 [MyJobsService] POST - Reply to Review');
    print('Endpoint: $endpoint');
    return await _api.handleApiRequest(
      endpoint,
      method: 'POST',
      body: body,
      requiresToken: true,
    );
  }
}
