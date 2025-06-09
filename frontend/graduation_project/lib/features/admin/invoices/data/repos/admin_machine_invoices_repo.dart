import 'package:dio/dio.dart';
import 'package:graduation_project/features/admin/invoices/data/models/admin_invoice_model.dart';

class AdminMachineInvoicesRepo {
  final Dio dio;
  AdminMachineInvoicesRepo(this.dio);

  Future<List<AdminInvoiceModel>> fetchInvoices(int machineId) async {
    try {
      final response = await dio.get('https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Admin/machines/$machineId/purchases');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => AdminInvoiceModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load invoices');
      }
    } catch (e) {
      throw Exception('Error fetching invoices: $e');
    }
  }
} 