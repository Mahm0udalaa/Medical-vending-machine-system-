import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class LoginRepo {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api';

  LoginRepo();

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: request.toJson(),
      );

      final loginResponse = LoginResponseModel.fromJson(response.data);

      await _storage.write(key: 'token', value: loginResponse.token);
      await _storage.write(key: 'refreshToken', value: loginResponse.refreshToken);
      await _storage.write(key: 'role', value: loginResponse.role);
      await _storage.write(key: 'id', value: loginResponse.id.toString());

      return loginResponse;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'] ?? 'Invalid email or password. Please check your credentials and try again';
        throw message;
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw '⏱️ انتهى وقت الاتصال، يرجى المحاولة لاحقًا';
      } else if (e.type == DioExceptionType.cancel) {
        throw '🚫 تم إلغاء الطلب';
      } else if (e.type == DioExceptionType.unknown) {
        throw '📡 خطأ غير معروف، تحقق من اتصال الإنترنت';
      } else {
        throw '⚠️ تحقق من الاتصال بالإنترنت';
      }
    } catch (e) {
      throw '❌ حدث خطأ غير متوقع: ${e.toString()}';
    }
  }

  Future<LoginResponseModel> refreshToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) {
      throw '❗ لا يوجد Refresh Token مخزن';
    }

    try {
      final response = await _dio.post(
        '$_baseUrl/auth/refresh-token',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {'refreshToken': refreshToken},
      );

      final newToken = LoginResponseModel.fromJson(response.data);

      await _storage.write(key: 'token', value: newToken.token);
      await _storage.write(key: 'refreshToken', value: newToken.refreshToken);
      await _storage.write(key: 'role', value: newToken.role);

      return newToken;
    } on DioException catch (e) {
      throw 'فشل تجديد التوكن: ${e.message}';
    }
  }
}
