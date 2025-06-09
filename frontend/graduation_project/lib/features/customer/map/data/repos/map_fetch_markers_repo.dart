import 'package:dio/dio.dart';
import 'package:graduation_project/core/networking/api.service.dart';
import 'package:graduation_project/features/customer/map/data/models/fetch_marker_model.dart';

class MapFetchMarkersRepo {
  Future<List<MarkerModel>> fetchMarkers() async {
    try {
      final response = await ApiService.dio.get(
        'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/VendingMachine',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => MarkerModel.fromJson(item)).toList();
      } else {
        throw Exception('Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Handle different Dio exceptions here
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Please try again.');
      } else if (e.type == DioExceptionType.cancel) {
        throw Exception('Request was cancelled. Try again.');
      } else if (e.type == DioExceptionType.badResponse) {
        if (e.response?.statusCode == 401) {
          throw Exception('Unauthorized. Please log in again.');
        } else if (e.response?.statusCode == 404) {
          throw Exception('Data not found.');
        } else if (e.response?.statusCode == 500) {
          throw Exception('Internal server error. Please try later.');
        } else {
          throw Exception('Error: ${e.response?.statusMessage}');
        }
      } else {
        throw Exception('Unexpected error occurred. Please try again.');
      }
    }
  }
}
