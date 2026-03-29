import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gyzyleller/core/services/api.dart';

class CallApi {
  Future<http.Response> postToken(
    Map<String, dynamic> data,
    String apiUrl,
    String token,
  ) async {
    final fullUrl = '${Api().urlLink}/$apiUrl';
    print('--- FCM API POST START ---');
    print('URL: $fullUrl');
    print('Body: ${jsonEncode(data)}');
    final response = await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setTokenHeaders(token),
    );
    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');
    print('--- FCM API POST END ---');
    return response;
  }

  Future<http.Response> putToken(
    Map<String, dynamic> data,
    String apiUrl,
    String token,
  ) async {
    final fullUrl = '${Api().urlLink}/$apiUrl';
    print('--- FCM API PUT START ---');
    print('URL: $fullUrl');
    print('Body: ${jsonEncode(data)}');
    final response = await http.put(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setTokenHeaders(token),
    );
    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');
    print('--- FCM API PUT END ---');
    return response;
  }

  Map<String, String> _setTokenHeaders(String token) => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
