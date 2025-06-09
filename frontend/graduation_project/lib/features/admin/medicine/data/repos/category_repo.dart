import 'package:graduation_project/core/networking/api.service.dart';
import 'package:graduation_project/features/admin/medicine/data/models/category_model.dart';

class CategoryRepo {
  Future<List<CategoryModel>> fetchCategories() async {
    final response = await ApiService.dio.get('https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net/api/Category');
    return (response.data as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }
} 