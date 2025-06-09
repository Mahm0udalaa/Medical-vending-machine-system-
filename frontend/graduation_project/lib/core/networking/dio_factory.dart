import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioFactory {
  DioFactory._();

  static Dio? _dio;

  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _userTokenKey = 'userToken';

  static Future<Dio> getDio() async {
    if (_dio == null) {
      _dio = Dio();

      const timeOut = Duration(seconds: 30);
      _dio!
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut;

      await _addDioHeaders();
      _addDioInterceptor();
    }

    return _dio!;
  }

  static Future<void> _addDioHeaders() async {
    final token = await _secureStorage.read(key: _userTokenKey);

    _dio?.options.headers = {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static void setTokenIntoHeaderAfterLogin(String token) {
    final acceptHeader = _dio?.options.headers['Accept'] ?? 'application/json';

    _dio?.options.headers = {
      'Accept': acceptHeader,
      'Authorization': 'Bearer $token',
    };

    // حفظ التوكن في الـ secure storage
    _secureStorage.write(key: _userTokenKey, value: token);
  }

  static void _addDioInterceptor() {
    _dio?.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
  }
}
