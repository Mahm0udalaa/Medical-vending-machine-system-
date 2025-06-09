import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/networking/api.service.dart';
import 'package:graduation_project/features/admin/admin_home/data/models/machine_model.dart';

class MachinesRepo {
  final String _baseUrl = 'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<List<MachineModel>> getMachines() async {
    final adminId = await storage.read(key: 'id');
    if (adminId == null) throw Exception('No admin id found');
    final response = await ApiService.dio.get('$_baseUrl/VendingMachine/admin/$adminId');
    return (response.data as List)
        .map((json) => MachineModel.fromJson(json))
        .toList();
  }
}
