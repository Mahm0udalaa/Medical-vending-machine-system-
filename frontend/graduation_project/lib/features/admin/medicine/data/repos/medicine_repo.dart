import 'package:graduation_project/core/networking/api.service.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_basic_model.dart';
import 'package:graduation_project/features/admin/medicine/data/models/new_medicine_model.dart';
import 'package:dio/dio.dart';

class MedicineRepo {
  Future<List<MedicineModel>> getMachineMedicines(int machineId) async {
    try {
      final response = await ApiService.dio.get(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/MachineMedicine/machine/$machineId',
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => MedicineModel.fromJson(e))
            .toList();
      } else if (response.statusCode == 404 ||
                 (response.data is String && response.data.toString().contains('No medicines found'))) {
        return [];
      } else {
        throw Exception('Failed to load medicines');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  Future<void> deleteMedicine(int machineId, int medicineId) async {
    final response = await ApiService.dio.delete(
      'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/MachineMedicine/$machineId/$medicineId',
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete medicine');
    }
  }

  Future<List<MedicineBasicModel>> getAllMedicines() async {
    final response = await ApiService.dio.get(
      'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Medicine',
    );
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((e) => MedicineBasicModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load medicines');
    }
  }

  Future<MedicineBasicModel> addNewMedicine(NewMedicineModel model) async {
    try {
      final formData = FormData.fromMap({
        'MedicineName': model.medicineName,
        'MedicinePrice': model.medicinePrice,
        'Stock': model.stock,
        'ExpirationDate': model.expirationDate,
        'Description': model.description,
        'CategoryId': model.categoryId,
        if (model.imageFile != null)
          'ImageFile': await MultipartFile.fromFile(model.imageFile!.path, filename: model.imageFile!.path.split('/').last),
      });
      final response = await ApiService.dio.post(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Medicine',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return MedicineBasicModel.fromJson(response.data);
      } else {
        throw Exception('Failed to add new medicine');
      }
    } catch (e) {
      rethrow;
    }
  }
}
