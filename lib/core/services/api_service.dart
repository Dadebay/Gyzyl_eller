import 'dart:io';
import 'package:http/http.dart' as http;
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
        if (requiresToken && token != null) 'Authorization': 'Bearer $token',
      };
      final fullUrl = ApiConstants.baseUrl + endpoint;
      print('getRequest: Parsing URI: $fullUrl');
      final response = await http.get(Uri.parse(fullUrl), headers: headers);
      final decodedBody = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        final responseJson =
            decodedBody.isNotEmpty ? json.decode(decodedBody) : {};
        handleSuccess?.call(responseJson);
        return responseJson;
      } else {
        final responseJson =
            decodedBody.isNotEmpty ? json.decode(decodedBody) : {};
        _handleApiError(response.statusCode,
            responseJson['message']?.toString() ?? 'anErrorOccurred'.tr);
        return null;
      }
    } on SocketException {
      CustomWidgets.showSnackBar(
          'networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> postMultipartRequest(
      String endpoint, Map<String, dynamic> body,
      {List<XFile>? xFiles}) async {
    List<http.MultipartFile> multipartFiles = [];
    if (xFiles != null) {
      for (XFile file in xFiles) {
        multipartFiles
            .add(await http.MultipartFile.fromPath('photo', file.path));
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
      final uriString = endpoint.startsWith('http')
          ? endpoint
          : '${ApiConstants.baseUrl}$endpoint';
      print('handleApiRequest: Parsing URI: $uriString');
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
          _handleApiError(statusCode,
              errorJson['message']?.toString() ?? 'anErrorOccurred'.tr);
        }
        return statusCode;
      }
    } on SocketException {
      return null;
    }
  }

  void _handleApiError(int statusCode, String message) {
    String errorMessage;
    switch (statusCode) {
      case 400:
        errorMessage = 'invalidNumber'.tr;
        break;
      case 401:
        errorMessage = '${'unauthorized'.tr}: $message';
        break;
      case 403:
        errorMessage = message;
        break;
      case 404:
        errorMessage = '${'notFound'.tr}: $message';
        break;
      case 405:
        errorMessage = 'userDoesNotExist'.tr;
        break;
      case 500:
        errorMessage = '${'serverError'.tr}: $message';
        break;

      default:
        errorMessage = '${'errorStatus'.tr} $statusCode: $message';
    }
    print(errorMessage);
  }
}
