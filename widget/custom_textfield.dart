import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Function() onPressed;
  final bool readOnly;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.hintText,
    required this.controller,
    required this.keyboardType,
    required this.onPressed,
    this.readOnly = false,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
          fontSize: 21, fontWeight: FontWeight.w500, color: Colors.black),
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
      ),
      onTap: onPressed,
      validator: validator,
    );
  }
}
