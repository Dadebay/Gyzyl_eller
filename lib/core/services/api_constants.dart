import 'api.dart';

class ApiConstants {
  static String get baseUrl => Api().urlLink;
  static String get imageURL => Api().urlImage;

  static const String loginApi = 'api/user/ru/login';
  static const String about = 'functions/about/';
  static const String specialProfileCreate = 'api/user/masters';
  static const String specialProfile = 'api/user/masters/profile';
}
