import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/networking/api.service.dart';

import '../models/admin_profile_model.dart';

class AdminProfileRepo {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String> updateProfile(AdminProfileModel model) async {
    final adminId = await _storage.read(key: 'id');
    if (adminId == null) throw Exception('Admin ID not found');

    final data = model.toJson();
    if (data.isEmpty) throw Exception('No data to update');

    try {
      final response = await ApiService.dio.put(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Admin/$adminId',
        data: data,
      );

      if (response.statusCode == 204) {
        if (data.length == 1) {
          if (data.containsKey('adminName')) return 'Name updated successfully';
          if (data.containsKey('adminEmail')) return 'Email updated successfully';
          if (data.containsKey('adminPhone')) return 'Phone number updated successfully';
          if (data.containsKey('adminPass')) return 'Password updated successfully';
        }
        return 'Profile updated successfully';
      } else {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;

      // ✅ التعامل مع خطأ بالشكل المطلوب
      if (errorData is Map<String, dynamic>) {
        final message = errorData['Message'] ?? errorData['message'];
        if (message != null) {
          throw Exception(message.toString());
        }
      }

      // ✅ التعامل مع قائمة من الأخطاء إن وجدت
      if (errorData is List && errorData.isNotEmpty) {
        throw Exception(errorData.first.toString());
      }

      throw Exception('Unexpected error occurred ${e.response?.statusCode}\n${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
