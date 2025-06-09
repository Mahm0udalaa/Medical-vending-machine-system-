import 'package:dio/dio.dart';
import '../models/register_request.dart';

abstract class RegisterRepo {
  Future<String> register(RegisterRequestModel model);
}

class RegisterRepoImpl extends RegisterRepo {
  final Dio dio = Dio();

  @override
  Future<String> register(RegisterRequestModel model) async {
    const url = 'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/auth/register';

    try {
      final response = await dio.post(url, data: model.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['message'] ?? "Registration successful";
      } else {
        final message = response.data['message'] ?? 'Registration failed';
        throw Exception(message);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception("Connection timeout. Please try again.");
      } else if (e.type == DioExceptionType.unknown) {
        throw Exception("Please check your internet connection.");
      } else if (e.response != null) {
        final errorMsg = e.response?.data['message'] ?? "Invalid data or user already exists";
        throw Exception(errorMsg);
      } else {
        throw Exception("Something went wrong. Try again later.");
      }
    } catch (e) {
      throw Exception("Unexpected error: ${e.toString()}");
    }
  }
}
