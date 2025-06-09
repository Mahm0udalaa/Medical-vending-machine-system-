import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/networking/api.service.dart';

class CartRepo {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> addToCart({
    required int machineId,
    required int medicineId,
    required int quantity,
  }) async {
    final customerId = await _storage.read(key: 'id');
    if (customerId == null) throw Exception('User ID not found');
    try {
      final response = await ApiService.dio.post(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Cart',
        data: {
          'customerId': int.parse(customerId),
          'machineId': machineId,
          'medicineId': medicineId,
          'quantity': quantity,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data;
      }
      throw Exception('e: ${e.message}, status code: ${e.response?.statusCode}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
} 