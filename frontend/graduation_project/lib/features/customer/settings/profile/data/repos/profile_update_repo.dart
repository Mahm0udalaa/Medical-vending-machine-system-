import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/networking/api.service.dart';

import '../models/profile_update_model.dart';

class ProfileUpdateRepo {
  final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ProfileUpdateRepo({required this.dio});

  Future<String?> updateProfile(ProfileUpdateModel model) async {
    try {
      final id = await _storage.read(key: 'id');
      if (id == null) throw Exception('User ID not found');

      final response = await ApiService.dio.put(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Customer/$id',
        data: model.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['message'] == "Current password is incorrect") {
            throw Exception("Current password is incorrect");
          }
        }
        return null; // success
      } else {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response?.data;

        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          throw Exception(errorData['message']);
        } else if (errorData is List && errorData.isNotEmpty) {
          throw Exception(errorData.first.toString());
        } else {
          throw Exception('Unexpected error occurred ${e.response?.statusCode}');
        }
      } else {
        throw Exception('Network error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
