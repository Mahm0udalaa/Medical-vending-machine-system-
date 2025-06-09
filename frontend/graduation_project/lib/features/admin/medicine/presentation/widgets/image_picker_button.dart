import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerButton extends StatelessWidget {
  final void Function(File?) onImagePicked;
  final File? selectedImage;
  const ImagePickerButton({super.key, required this.onImagePicked, this.selectedImage});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          onImagePicked(File(picked.path));
        } else {
          onImagePicked(null);
        }
      },
      icon: const Icon(Icons.image, color: Colors.grey),
      label: Text(selectedImage != null ? 'Image Selected' : 'Choose Image', style: const TextStyle(color: Colors.grey)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
} 