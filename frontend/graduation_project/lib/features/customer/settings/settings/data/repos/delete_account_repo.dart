import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/networking/api.service.dart';

class DeleteAccountRepo {
  final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  DeleteAccountRepo({required this.dio});

  Future<void> deleteAccount() async {
    final id = await _storage.read(key: 'id');
    if (id == null) throw Exception('User ID not found');
    final response = await ApiService.dio.delete(
      'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Customer/$id',
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete account');
    }
  }
} 