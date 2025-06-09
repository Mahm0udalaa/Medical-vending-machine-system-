import 'package:dio/dio.dart';

class NewPasswordRepo {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    const String url = 'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/auth/reset-password';

    try {
      final response = await _dio.post(
        url,
        data: {
          "email": email,
          "code": code,
          "newPassword": newPassword,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          "success": true,
          "message": response.data['message'] ?? "Password reset successfully",
        };
      } else {
        return {
          "success": false,
          "message": response.data['message'] ?? "Unexpected error occurred",
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errors = e.response?.data['errors'];
        if (errors != null && errors['NewPassword'] != null) {
          return {
            "success": false,
            "message": errors['NewPassword'][0],
          };
        }
      }
      return {
        "success": false,
        "message": "Connection error: ${e.message}",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "An error occurred: $e",
      };
    }
  }
}
