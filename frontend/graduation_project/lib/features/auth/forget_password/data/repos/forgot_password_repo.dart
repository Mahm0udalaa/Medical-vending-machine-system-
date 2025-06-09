import 'package:dio/dio.dart';

class ForgotPasswordRepo {
  final Dio dio;

  ForgotPasswordRepo({required this.dio});

  Future<Map<String, dynamic>> sendResetCode(String email) async {
    try {
      final response = await dio.post(
        "https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/auth/forgot-password",
        data: {"email": email},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {"success": true, "message": response.data['message'] ?? "A password reset code has been sent to your email."};
      } else if (response.statusCode == 404) {
        return {"success": false, "message": "Email does not exist in our system."};
        // return {"success": false, "message": response.data['message'] ?? "Email does not exist in our system."};
      } else {
        return {"success": false, "message": response.data['message'] ?? "Unknown error"};
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && e.response?.data['errors'] != null) {
        final errors = e.response?.data['errors'];
        if (errors != null && errors['Email'] != null) {
          return {"success": false, "message": errors['Email'][0]};
        }
      }
      return {"success": false, "message": "Connection error: ${e.message}"};
    } catch (e) {
      return {"success": false, "message": "An error occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    try {
      final response = await dio.post(
        "https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/auth/verify-reset-code",
        data: {"email": email, "code": code},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {"success": true, "message": response.data['message'] ?? "Code is valid", "email": email, "code": code};
      } else {
        return {"success": false, "message": response.data['message'] ?? "Invalid or expired verification code"};
      }
    } on DioException catch (e) {
      return {"success": false, "message": "Connection error: ${e.message}"};
    } catch (e) {
      return {"success": false, "message": "An error occurred: $e"};
    }
  }
}
