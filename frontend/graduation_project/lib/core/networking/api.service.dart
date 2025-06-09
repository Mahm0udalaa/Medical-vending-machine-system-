import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static bool _interceptorAdded = false;

  static Dio get dio {
    if (!_interceptorAdded) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await _storage.read(key: 'token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onError: (e, handler) async {
            if (e.response?.statusCode == 401) {
              final refreshToken = await _storage.read(key: 'refreshToken');
              if (refreshToken != null) {
                try {
                  final refreshResponse = await _dio.post(
                    '/auth/refresh-token',
                    data: {'refreshToken': refreshToken},
                  );

                  final newToken = refreshResponse.data['token'];
                  final newRefreshToken = refreshResponse.data['refreshToken'];

                  await _storage.write(key: 'token', value: newToken);
                  await _storage.write(key: 'refreshToken', value: newRefreshToken);

                  final clonedRequest = e.requestOptions;
                  clonedRequest.headers['Authorization'] = 'Bearer $newToken';

                  final retryResponse = await _dio.fetch(clonedRequest);
                  return handler.resolve(retryResponse);
                } catch (_) {
                  return handler.reject(e);
                }
              }
            }
            return handler.next(e);
          },
        ),
      );
      _interceptorAdded = true;
    }
    return _dio;
  }
}
