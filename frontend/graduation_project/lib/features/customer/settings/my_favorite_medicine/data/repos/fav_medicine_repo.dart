import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/networking/api.service.dart';

import '../models/fav_medicine_model.dart';

class FavMedicineRepo {
  final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  FavMedicineRepo({required this.dio});
  
  Future<List<FavMedicineModel>> fetchFavMedicines() async {
    try {
      final userId = await _storage.read(key: 'id');
      if (userId == null) throw Exception('User ID not found');
      final response = await ApiService.dio.get(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/FavoritesMedicine/$userId',
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => FavMedicineModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load favorite medicines');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
