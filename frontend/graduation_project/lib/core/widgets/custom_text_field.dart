import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.keyboardType,
    this.icon,
    this.autoFocus,
    required this.hintText,
    this.onChanged,
    required this.isPassword,
    this.validator,
    this.controller,
    this.focusNode,
    this.onSubmitted,
  });

  final IconData? icon;
  final bool? autoFocus;
  final String hintText;
  final Function(String)? onChanged;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final void Function(String)? onSubmitted; 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        autofocus: autoFocus ?? false,
        focusNode: focusNode,
        controller: controller,
        obscureText: isPassword,
        onChanged: onChanged,
        validator: validator,
        keyboardType: keyboardType,
        onFieldSubmitted: onSubmitted, 

        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xff6C7278))
              : null,
          label: Text(hintText),
          labelStyle: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
          errorStyle: const TextStyle(
            color: Color(0xffFF6B6B),
            fontSize: 12,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xff8C8C8C),
            fontSize: 16,
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(226, 255, 255, 255),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color.fromARGB(255, 2, 45, 19), width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xffFF6B6B), width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xffFF6B6B), width: 2.0),
          ),
        ),
      ),
    );
  }
}
