import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gyzyleller/core/services/api.dart';

class CallApi {
  Future<http.Response> postToken(
    Map<String, dynamic> data,
    String apiUrl,
    String token,
  ) async {
    // 🔗 URL Birleştirme - Çift / işaretini engeller
    final baseUrl = Api().urlLink.endsWith('/')
        ? Api().urlLink.substring(0, Api().urlLink.length - 1)
        : Api().urlLink;
    final path = apiUrl.startsWith('/') ? apiUrl : '/$apiUrl';
    final fullUrl = '$baseUrl$path';

    print('--- 🚀 FCM API CALL START ---');
    print('ℹ️ METHOD: POST');
    print('🌐 FULL URL: $fullUrl');
    print('📦 BODY: ${jsonEncode(data)}');

    final response = await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setTokenHeaders(token),
    );

    print('✅ [API-POST] Status: ${response.statusCode}');
    print('✅ [API-POST] Response: ${response.body}');
    print('--- 🏁 FCM API CALL END ---');
    return response;
  }

  Future<http.Response> putToken(
    Map<String, dynamic> data,
    String apiUrl,
    String token,
  ) async {
    // 🔗 URL Birleştirme - Çift / işaretini engeller
    final baseUrl = Api().urlLink.endsWith('/')
        ? Api().urlLink.substring(0, Api().urlLink.length - 1)
        : Api().urlLink;
    final path = apiUrl.startsWith('/') ? apiUrl : '/$apiUrl';
    final fullUrl = '$baseUrl$path';

    print('--- 🚀 FCM API CALL START ---');
    print('ℹ️ METHOD: PUT');
    print('🌐 FULL URL: $fullUrl');
    print('📦 BODY: ${jsonEncode(data)}');

    final response = await http.put(
      Uri.parse(fullUrl),
      body: jsonEncode(data),
      headers: _setTokenHeaders(token),
    );

    print('✅ [API-PUT] Status: ${response.statusCode}');
    print('✅ [API-PUT] Response: ${response.body}');
    print('--- 🏁 FCM API CALL END ---');
    return response;
  }

  Map<String, String> _setTokenHeaders(String token) => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
