import 'package:dio/dio.dart';
import '../models/machine_medicine_model.dart';

class MachineMedicineRepo {
  final Dio dio;
  MachineMedicineRepo({required this.dio});

  Future<List<MachineMedicineModel>> fetchMachineMedicines(int machineId) async {
    try {
      final response = await dio.get(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/MachineMedicine/machine/$machineId',
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => MachineMedicineModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load machine medicines');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
} 