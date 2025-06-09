import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/networking/api.service.dart';

import '../models/all_medicines_cart_model.dart';

class AllMedicinesCartRepo {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<CartMedicineModel>> fetchCartMedicines() async {
    final id = await _storage.read(key: 'id');
    if (id == null) throw Exception('User ID not found');
    try {
      final response = await ApiService.dio.get(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Cart/$id',
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => CartMedicineModel.fromJson(e)).toList();
      } else if (response.statusCode == 404 && response.data == 'No items found for this customer.') {
        return [];
      } else {
        throw Exception('Failed to load cart');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 && e.response?.data == 'No items found for this customer.') {
        return [];
      }
      throw Exception('Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteCartMedicine(int medicineId) async {
    final id = await _storage.read(key: 'id');
    if (id == null) throw Exception('User ID not found');
    try {
      final response = await ApiService.dio.delete(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Cart',
        queryParameters: {
          'customerId': id,
          'medicineId': medicineId,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete item from cart');
      }
    } on DioException catch (e) {
      throw Exception('e: ${e.message}, status code: ${e.response?.statusCode}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> deleteAllCartMedicines() async {
    final id = await _storage.read(key: 'id');
    if (id == null) throw Exception('User ID not found');
    try {
      final response = await ApiService.dio.delete(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Cart/customer/$id',
      );
      if (response.statusCode == 200) {
        return response.data['message'] ?? 'All cart items deleted successfully.';
      } else {
        throw Exception('Failed to delete all items from cart');
      }
    } on DioException catch (e) {
      throw Exception('e: ${e.message}, status code: ${e.response?.statusCode}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> updateCartMedicineQuantity({required int medicineId, required int quantity}) async {
    final id = await _storage.read(key: 'id');
    if (id == null) throw Exception('User ID not found');
    try {
      final response = await ApiService.dio.put(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Cart/$id/$medicineId',
        data: {
          // 'customerId': int.parse(id),
          // 'medicineId': medicineId,
          'quantity': quantity,
        },
      );
      if (response.statusCode == 200) {
        return response.data['message'] ?? 'Quantity updated successfully.';
      } else {
        throw Exception('Failed to update quantity');
      }
    } on DioException catch (e) {
      throw Exception('e: ${e.message}, status code: ${e.response?.statusCode}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
