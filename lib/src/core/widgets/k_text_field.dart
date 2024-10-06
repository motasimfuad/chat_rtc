import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class KTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final String? Function(String?)? validator;

  const KTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        errorStyle: const TextStyle(
          color: AppColors.danger,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.primary.shade300,
        ),
        filled: true,
        fillColor: AppColors.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }
}
