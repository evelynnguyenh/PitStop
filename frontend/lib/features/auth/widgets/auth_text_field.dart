import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../core/theme/app_colors.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.name,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.initialValue,
    this.textInputAction,
    this.enabled = true,
  });

  final String name;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? initialValue;
  final TextInputAction? textInputAction;
  final bool enabled;

  static final _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primary),
  );

  static final _defaultBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
  );

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      initialValue: initialValue,
      textInputAction: textInputAction,
      enabled: enabled,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        color: Color(0xFF1A1A1A),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: Color(0xFFAAAAAA),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: _defaultBorder,
        enabledBorder: _defaultBorder,
        focusedBorder: _focusedBorder,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCA3131)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCA3131)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
