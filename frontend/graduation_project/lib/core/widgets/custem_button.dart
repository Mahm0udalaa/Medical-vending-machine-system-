import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text,
    this.color = Colors.white,
    required this.backgroundcolor,
    super.key,
    this.iconimage,
    this.onPressed,  this.width,  this.height,
  });
  final String text;
  final bool _isLoading = false;
  final Color backgroundcolor;
  final Color color;
  final Widget? iconimage;
  final void Function()? onPressed;
   final double? width;
  final double ?height;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: iconimage ?? SizedBox(),
      onPressed: onPressed ?? () {},
      // _isLoading ? null : _submitForm,
      style: ElevatedButton.styleFrom(
         
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: backgroundcolor,
      ),
      label: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(text, style: TextStyle(color: color, fontSize: 20)),
    );
  }
}
