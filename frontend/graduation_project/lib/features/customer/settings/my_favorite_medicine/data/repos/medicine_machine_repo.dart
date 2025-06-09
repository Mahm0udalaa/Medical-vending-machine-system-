import 'package:dio/dio.dart';
import '../models/medicine_machine_model.dart';

class MedicineMachineRepo {
  final Dio dio;
  MedicineMachineRepo({required this.dio});

  Future<List<MedicineMachineModel>> fetchMachinesByMedicine(int medicineId) async {
    try {
      final response = await dio.get(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/MachineMedicine/machines-by-medicine/$medicineId',
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => MedicineMachineModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load machines');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
} 