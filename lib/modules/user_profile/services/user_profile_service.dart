import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gyzyleller/core/services/api_constants.dart';
import 'package:gyzyleller/core/services/api_service.dart';
import 'package:gyzyleller/core/services/auth_storage.dart';
import 'package:gyzyleller/modules/user_profile/model/about_us_model.dart';
import 'package:gyzyleller/modules/user_profile/model/user_model.dart';

class UserProfileService {
  final ApiService _apiService = ApiService();

  Future<AboutApiResponse> fetchAboutData() async {
    final response =
        await _apiService.getRequest(ApiConstants.about, requiresToken: false);
    if (response != null) {
      return AboutApiResponse.fromJson(response);
    } else {
      throw Exception('Hakkında verisi alınamadı.');
    }
  }

  Future<UserModel?> updateUser(
      {required int userId, required Map<String, String> data}) async {
    final String endpoint = 'api/users/$userId/';

    final response = await _apiService.handleApiRequest(endpoint,
        body: data, method: 'PUT', requiresToken: true, isForm: true);

    if (response is Map<String, dynamic>) {
      try {
        return UserModel.fromJson(response);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<UserModel?> updateUserProfile({
    File? imageFile,
    // Yükleme yüzdesini takip etmek için callback fonksiyonu
    void Function(int, int)? onSendProgress,
  }) async {
    // Sadece bu metot için bir Dio nesnesi oluşturuyoruz
    final dio = Dio();
    final token = AuthStorage().token; // Token'ı alıyoruz

    final String endpoint = '${ApiConstants.baseUrl}user/ru/upload-image';

    try {
      // Dio'nun FormData yapısını kullanarak multipart verileri hazırlıyoruz
      final formData = FormData.fromMap({
        if (imageFile != null)
          'img': await MultipartFile.fromFile(imageFile.path),
      });

      // Dio ile PUT isteğini gönderiyoruz
      final response = await dio.put(
        endpoint,
        data: formData,
        onSendProgress:
            onSendProgress, // Dio'nun ilerleme takibi özelliğini kullanıyoruz
        options: Options(
          headers: {
            // Token'ı başlığa ekliyoruz
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      // Başarılı olursa, gelen veriyi UserModel'e çevirip döndürüyoruz
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        // Hata durumunda null döndürüyoruz, hata yönetimi DioException bloğunda
        return null;
      }
    } on DioException {
      return null;
    } catch (e) {
      return null;
    }
  }
}
