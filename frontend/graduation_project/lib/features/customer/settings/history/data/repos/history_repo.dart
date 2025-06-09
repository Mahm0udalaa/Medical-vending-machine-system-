import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/features/customer/settings/history/data/models/history_model.dart';

class HistoryRepo {
  final Dio dio;
  final FlutterSecureStorage storage;

  HistoryRepo({required this.dio, required this.storage});

  Future<List<PurchaseHistoryModel>> fetchHistory() async {
    try {
      final customerId = await storage.read(key: 'id');
      if (customerId == null) throw Exception('No customer id found');
      final response = await dio.get(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Customer/$customerId/history',
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => PurchaseHistoryModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch history');
      }
    } catch (e) {
      throw Exception(' $e');
    }
  }
}
