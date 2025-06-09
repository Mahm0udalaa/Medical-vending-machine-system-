import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/features/auth/login/data/repos/login_repo.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LoginRepo _loginRepo = LoginRepo();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // لو رجع Unauthorized (401)
    if (err.response?.statusCode == 401 && !_isRetry(requestOptions)) {
      try {
        final newTokenModel = await _loginRepo.refreshToken();
        final newToken = newTokenModel.token;

        // 🪪 حدّث التوكن في الريكوست القديم
        final newRequestOptions = Options(
          method: requestOptions.method,
          headers: {
            ...requestOptions.headers,
            'Authorization': 'Bearer $newToken',
            'Content-Type': 'application/json',
          },
        );

        // 👇 جرّب نفس الريكوست مرة تانية بالتوكن الجديد
        final dio = Dio();
        final response = await dio.request(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: newRequestOptions,
        );

        return handler.resolve(response);
      } catch (e) {
        return handler.reject(err);
      }
    }

    handler.next(err);
  }

  bool _isRetry(RequestOptions requestOptions) {
    // علشان نتجنب الـ loop في حال فشل الـ refresh كمان
    return requestOptions.headers['retry'] == true;
  }
}
