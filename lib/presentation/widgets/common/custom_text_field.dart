import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;

  CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: _isFocused
            ? [AppColors.cardShadow]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText && _isObscured,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        onChanged: widget.onChanged,
        maxLines: widget.maxLines,
        onTap: () => setState(() => _isFocused = true),
        onTapOutside: (_) => setState(() => _isFocused = false),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          filled: true,
          fillColor: _isFocused
              ? Colors.white
              : AppColors.sectionBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.hintText.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.maritimeBlue,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.statusError,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.statusError,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
            widget.prefixIcon,
            color: _isFocused
                ? AppColors.maritimeBlue
                : AppColors.hintText,
            size: 20,
          )
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
            icon: Icon(
              _isObscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.hintText,
              size: 20,
            ),
            onPressed: () => setState(() => _isObscured = !_isObscured),
          )
              : widget.suffixIcon != null
              ? Icon(widget.suffixIcon, size: 20)
              : null,
          labelStyle: TextStyle(
            color: _isFocused
                ? AppColors.maritimeBlue
                : AppColors.hintText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: AppColors.hintText,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}