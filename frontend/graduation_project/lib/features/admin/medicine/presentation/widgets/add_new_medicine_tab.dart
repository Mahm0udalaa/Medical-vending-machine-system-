import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/admin/medicine/cubit/cubit/add_medicine_cubit.dart';
import 'package:graduation_project/features/admin/medicine/cubit/cubit/medicines_cubit.dart';
import 'package:graduation_project/features/admin/medicine/data/models/category_model.dart';
import 'package:graduation_project/features/admin/medicine/data/models/new_medicine_model.dart';

import 'image_picker_button.dart';

class AddNewMedicineTab extends StatefulWidget {
  final List<CategoryModel> categories;
  const AddNewMedicineTab({super.key, required this.categories});

  @override
  State<AddNewMedicineTab> createState() => _AddNewMedicineTabState();
}

class _AddNewMedicineTabState extends State<AddNewMedicineTab> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _expireController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedImage;
  int? _selectedCategoryId;

  bool _isAlphanumeric(String input) {
    final alphanumeric = RegExp(r'^[a-zA-Z0-9\s]+$');
    return alphanumeric.hasMatch(input);
  }

  bool _isValidDescription(String input) {
    final descRegex = RegExp(r'^[\w\s.,-]+$');
    return descRegex.hasMatch(input);
  }

  bool _isValidDate(String input) {
    try {
      final inputDate = DateTime.parse(input);
      final now = DateTime.now();
      return inputDate.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddMedicineCubit, AddMedicineState>(
      listener: (context, state) {
        if (state is AddMedicineSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Medicine added: ${state.medicine.medicineName}'),
            ),
          );
          _nameController.clear();
          _priceController.clear();
          _stockController.clear();
          _expireController.clear();
          _descController.clear();
          setState(() {
            _selectedCategoryId = null;
            _selectedImage = null;
          });
          context.read<MedicinesCubit>().fetchAllMedicines();
        } else if (state is AddMedicineError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Medicine Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter medicine name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Price',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Stock',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Expire Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _expireController,
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _expireController.text =
                        date.toIso8601String().split('T').first;
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items:
                    widget.categories
                        .map(
                          (cat) => DropdownMenuItem<int>(
                            value: cat.categoryId,
                            child: Text(cat.categoryName),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategoryId = val;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select category',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ImagePickerButton(
                onImagePicked: (file) {
                  setState(() {
                    _selectedImage = file;
                  });
                },
                selectedImage: _selectedImage,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      state is AddMedicineLoading
                          ? null
                          : () {
                            final name = _nameController.text.trim();
                            final priceText = _priceController.text.trim();
                            final stockText = _stockController.text.trim();
                            final expireDate = _expireController.text.trim();
                            final desc = _descController.text.trim();

                            if (name.isEmpty) {
                              _showError('Please enter medicine name');
                              return;
                            }
                            if (!_isAlphanumeric(name)) {
                              _showError(
                                'Medicine name must contain letters and numbers only',
                              );
                              return;
                            }

                            if (priceText.isEmpty) {
                              _showError('Please enter price');
                              return;
                            }
                            if (int.tryParse(priceText) == null) {
                              _showError('Price must be a valid number');
                              return;
                            }

                            if (stockText.isEmpty) {
                              _showError('Please enter stock quantity');
                              return;
                            }
                            if (int.tryParse(stockText) == null) {
                              _showError('Stock must be a valid number');
                              return;
                            }

                            if (expireDate.isEmpty) {
                              _showError('Please select expiration date');
                              return;
                            }
                            if (!_isValidDate(expireDate)) {
                              _showError(
                                'Expiration date must be a future date',
                              );
                              return;
                            }

                            if (desc.isEmpty) {
                              _showError('Please enter description');
                              return;
                            }
                            if (!_isValidDescription(desc)) {
                              _showError(
                                'Description contains invalid characters',
                              );
                              return;
                            }

                            if (_selectedCategoryId == null) {
                              _showError('Please select category');
                              return;
                            }

                            if (_selectedImage == null) {
                              _showError('Please select an image');
                              return;
                            }

                            final model = NewMedicineModel(
                              medicineName: name,
                              medicinePrice: int.parse(priceText),
                              stock: int.parse(stockText),
                              expirationDate: expireDate,
                              description: desc,
                              categoryId: _selectedCategoryId!,
                              imageFile: _selectedImage,
                            );
                            context.read<AddMedicineCubit>().addMedicine(model);
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      state is AddMedicineLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Add Medicine',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
