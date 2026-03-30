import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gyzyleller/core/services/api.dart';
import '../../shared/extensions/packages.dart';

enum HttpMethod { get, post, put, delete }

class ApiService {
  final _auth = AuthStorage();

  Future<dynamic> getRequest(String endpoint,
      {bool requiresToken = true,
      void Function(dynamic)? handleSuccess}) async {
    try {
      final token = _auth.token;
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (requiresToken && token != null) 'Authorization': 'Bearer $token',
      };
      final fullUrl = '${Api().urlLink}$endpoint';

      final response = await http.get(Uri.parse(fullUrl), headers: headers);
      final decodedBody = utf8.decode(response.bodyBytes);

      print('-----------------------------------------');
      print('🌐 API GET REQUEST 🌐');
      print('URL: $fullUrl');
      print('Token: $token');
      print('Status Code: ${response.statusCode}');
      print('-----------------------------------------');

      if (response.statusCode == 200) {
        final responseJson =
            decodedBody.isNotEmpty ? json.decode(decodedBody) : {};
        handleSuccess?.call(responseJson);
        return responseJson;
      } else {
        print('Response Body: $decodedBody');
        final responseJson =
            decodedBody.isNotEmpty ? json.decode(decodedBody) : {};
        _handleApiError(response.statusCode,
            responseJson['message']?.toString() ?? 'anErrorOccurred'.tr);
        return null;
      }
    } on SocketException catch (e) {
      print('SocketException: $e');

      return null;
    } catch (e) {
      print('ApiService Error in getRequest: $e');
      return null;
    }
  }

  Future<dynamic> postMultipartRequest(
      String endpoint, Map<String, dynamic> body,
      {List<XFile>? xFiles, String fileField = 'photo'}) async {
    List<http.MultipartFile> multipartFiles = [];
    if (xFiles != null) {
      for (XFile file in xFiles) {
        multipartFiles
            .add(await http.MultipartFile.fromPath(fileField, file.path));
      }
    }

    return handleApiRequest(
      endpoint,
      body: body,
      method: 'POST',
      requiresToken: true,
      isForm: true,
      multipartFiles: multipartFiles.isNotEmpty ? multipartFiles : null,
    );
  }

  Future<dynamic> putMultipartRequest(
    String endpoint,
    Map<String, dynamic> body, {
    List<XFile>? files,
  }) async {
    List<http.MultipartFile> multipartFiles = [];
    if (files != null) {
      for (XFile file in files) {
        multipartFiles.add(await http.MultipartFile.fromPath('img', file.path));
      }
    }

    return handleApiRequest(
      endpoint,
      body: body,
      method: 'PUT',
      requiresToken: true,
      isForm: false,
    );
  }

  Future<dynamic> handleApiRequest(String endpoint,
      {required Map<String, dynamic> body,
      required String method,
      required bool requiresToken,
      bool isForm = false,
      List<http.MultipartFile>? multipartFiles}) async {
    try {
      final token = _auth.token;
      final uriString =
          endpoint.startsWith('http') ? endpoint : '${Api().urlLink}$endpoint';

      final uri = Uri.parse(uriString);
      late http.BaseRequest request;

      if (isForm) {
        request = http.MultipartRequest(method, uri);
        body.forEach((key, value) {
          (request as http.MultipartRequest).fields[key] = value.toString();
        });

        if (multipartFiles != null) {
          (request as http.MultipartRequest).files.addAll(multipartFiles);
        }
      } else {
        request = http.Request(method, uri);
        request.headers[HttpHeaders.contentTypeHeader] =
            'application/json; charset=UTF-8';
        if (body.isNotEmpty) {
          (request as http.Request).body = jsonEncode(body);
        }
      }

      if (requiresToken && token != null) {
        request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final statusCode = streamedResponse.statusCode;

      print('-----------------------------------------');
      print('🌐 API POST/PUT REQUEST 🌐');
      print('URL: ${uri.toString()}');
      print('Status Code: $statusCode');
      print('Response Body: $responseBody');
      print('-----------------------------------------');

      if (statusCode >= 200 && statusCode < 300) {
        if (responseBody.isEmpty) {
          return statusCode;
        }
        return json.decode(responseBody);
      } else {
        dynamic errorJson;
        try {
          errorJson = json.decode(responseBody);
        } catch (e) {
          errorJson = {'message': 'Server returned a non-JSON response.'};
        }
        if (statusCode == 409) {
        } else {
          String message = 'anErrorOccurred'.tr;
          if (errorJson is Map<String, dynamic> &&
              errorJson.containsKey('message')) {
            message = errorJson['message']?.toString() ?? message;
          } else if (errorJson is String) {
            message = errorJson;
          }

          _handleApiError(statusCode, message);
        }
        return statusCode;
      }
    } on SocketException {
      CustomWidgets.showSnackBar('Internet Hatası'.tr,
          'Internet baglanşygyňyzy barlaň'.tr, Colors.red);
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  void _handleApiError(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        break;
      case 401:
        break;
      case 403:
        break;
      case 404:
        break;
      case 405:
        break;
      case 500:
        break;

      default:
    }
  }

  /// Fetches reviews for a master profile by their user ID.
  /// Calls `master-reviews/{userId}` and returns a list of raw JSON maps.
  Future<List<dynamic>> getMasterReviews(String userId,
      {String? column, String? direction}) async {
    String endpoint = 'api/master-reviews/$userId';
    final Map<String, String> queryParams = {};
    if (column != null) queryParams['column'] = column;
    if (direction != null) queryParams['direction'] = direction;
    if (queryParams.isNotEmpty) {
      endpoint += '?${Uri(queryParameters: queryParams).query}';
    }
    print('📡 [ApiService] getMasterReviews → $endpoint');
    try {
      final response = await getRequest(endpoint);
      if (response != null && response['data'] != null) {
        final list = response['data'] as List<dynamic>;
        print(
            '✅ [ApiService] getMasterReviews → ${list.length} reviews received');
        return list;
      }
      print('⚠️ [ApiService] getMasterReviews → response[data] is null');
      return [];
    } catch (e) {
      print('❌ [ApiService] getMasterReviews error: $e');
      return [];
    }
  }
}
