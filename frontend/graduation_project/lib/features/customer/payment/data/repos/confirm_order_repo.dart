import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/features/customer/cart/data/models/all_medicines_cart_model.dart';

class ConfirmOrderRepo {
  final Dio dio;
  final FlutterSecureStorage storage;
  ConfirmOrderRepo({required this.dio, required this.storage});

  Future<Map<String, dynamic>> moveMotorForMedicines(List<CartMedicineModel> medicines) async {
    const deviceId = 'esp32-dispenser';
    List<CartMedicineModel> failed = [];
    List<String> success = [];
    List<String> errorMessages = [];

    for (final med in medicines) {
      try {
        print('Sending → Name: ${med.medicineName}, Slot: ${med.slot}, Quantity: ${med.quantity}');

        final resp = await dio.post(
          'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/vending/test-motor',
          queryParameters: {
            'deviceId': deviceId,
            'slot': med.slot,
            'quantity': med.quantity,
          },
        );
        final data = resp.data;
        if (resp.statusCode == 200 && data['success'] == true && data['message'] == "Slot test command sent successfully.") {
          success.add(med.medicineName);
        } else {
          failed.add(med);
          errorMessages.add('${med.medicineName}: \x1B[31m${data['message'] ?? 'Unknown error'}\x1B[0m');
        }
      } catch (e) {
        failed.add(med);
        errorMessages.add('${med.medicineName}: $e');
      }
      await Future.delayed(const Duration(seconds: 10));
    }

    List<CartMedicineModel> stillFailed = [];
    for (final med in failed) {
      try {
        print('Retrying → Name: ${med.medicineName}, Slot: ${med.slot}, Quantity: ${med.quantity}');

        final resp = await dio.post(
          'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/vending/test-motor',
          queryParameters: {
            'deviceId': deviceId,
            'slot': med.slot,
            'quantity': med.quantity,
          },
        );
        final data = resp.data;
        if (resp.statusCode == 200 && data['success'] == true && data['message'] == "Slot test command sent successfully.") {
          success.add(med.medicineName);
        } else {
          stillFailed.add(med);
          errorMessages.add('${med.medicineName}: \x1B[31m${data['message'] ?? 'Unknown error'}\x1B[0m');
        }
      } catch (e) {
        stillFailed.add(med);
        errorMessages.add('${med.medicineName}: $e');
      }
      await Future.delayed(const Duration(seconds: 10));
    }

    if (stillFailed.isEmpty) {
      return {
        'success': true,
        'message': 'All medicines dispensed successfully: ${success.join(", ")}',
        'failed': [],
        'errors': errorMessages
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to dispense: ${stillFailed.map((e) => e.medicineName).join(", ")}',
        'failed': stillFailed,
        'errors': errorMessages
      };
    }
  }

  Future<Map<String, dynamic>> confirmOrder() async {
    try {
      print('Entering confirmOrder request...');
      final customerId = await storage.read(key: 'id');
      if (customerId == null) {
        return {'success': false, 'message': 'No customer id found'};
      }
      final resp = await dio.post(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Purchase/checkout',
        data: {'customerId': customerId},
      );
      if (resp.statusCode == 200 && (resp.data['StatusCode'] == 200 || resp.data['success'] == true)) {
        return {'success': true, 'message': resp.data['Message'] ?? 'Order confirmed successfully'};
      } else {
        return {'success': false, 'message': resp.data['Message'] ?? 'Failed to confirm order'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error confirming order: $e'};
    }
  }
}
