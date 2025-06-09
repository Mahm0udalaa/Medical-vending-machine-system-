import 'package:dio/dio.dart';
import 'package:graduation_project/core/networking/api.service.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_refill_model.dart';

class MedicineRefillRepo {
  Future<Map<String, dynamic>> refillMedicine(MedicineRefillModel model) async {
    try {
      final response = await ApiService.dio.put(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/MachineMedicine',
        data: model.toJson(),
      );
      if (response.statusCode == 204) {
        return {'success': true, 'message': 'Quantity updated'};
      } else {
        return {'success': false, 'message': 'Unexpected response: ${response.statusCode}'};
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data['message'] != null) {
          return {'success': false, 'message': data['message']};
        }
        if (data is Map<String, dynamic> && data['title'] != null) {
          return {'success': false, 'message': data['title']};
        }
        if (data is Map<String, dynamic> && data['errors'] != null) {
          final errors = data['errors'];
          if (errors is Map<String, dynamic>) {
            final firstKey = errors.keys.first;
            final firstError = errors[firstKey];
            if (firstError is List && firstError.isNotEmpty) {
              return {'success': false, 'message': firstError.first};
            }
          }
        }
      }
      return {'success': false, 'message': 'An error occurred while updating quantity'};
    }
  }
}
