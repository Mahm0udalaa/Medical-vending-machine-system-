import 'package:graduation_project/core/networking/api.service.dart';
import 'package:graduation_project/features/admin/medicine/data/models/machine_medicine_model.dart';
import 'package:dio/dio.dart';

class MachineMedicineRepo {
  Future<Map<String, dynamic>> addMedicineToMachine(MachineMedicineModel model) async {
    try {
      final response = await ApiService.dio.post(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/MachineMedicine',
        data: model.toJson(),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Medicine added to machine successfully'};
      } else {
        return {'success': false, 'message': 'Unexpected error'};
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (e.response?.statusCode == 404) {
          return {'success': false, 'message': 'Medicine not found'};
        }
        if (data is Map<String, dynamic> && data['message'] != null) {
          return {'success': false, 'message': data['message']};
        }
        return {'success': false, 'message': 'Error: ${e.response?.statusCode}'};
      }
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }
} 