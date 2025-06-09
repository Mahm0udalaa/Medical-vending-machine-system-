class CategoryModel {
  final int categoryId;
  final String categoryName;
  final String? description;
  final int? medicineCount;
  final String? imagePath;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.medicineCount,
    this.imagePath,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      description: json['description'],
      medicineCount: json['medicineCount'],
      imagePath: json['imagePath'],
    );
  }
} 