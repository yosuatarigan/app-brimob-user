import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      style: GoogleFonts.roboto(
        fontSize: 14,
        color: AppColors.darkNavy,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: AppColors.darkGray,
        ),
        hintStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: AppColors.darkGray.withOpacity(0.6),
        ),
        prefixIcon: prefixIcon != null 
            ? Icon(
                prefixIcon,
                color: AppColors.primaryBlue,
                size: 20,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: AppColors.darkGray.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: AppColors.darkGray.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: AppColors.darkGray.withOpacity(0.2),
          ),
        ),
        filled: true,
        fillColor: enabled ? AppColors.white : AppColors.lightGray.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingM,
        ),
        errorStyle: GoogleFonts.roboto(
          fontSize: 12,
          color: Colors.red,
        ),
      ),
      dropdownColor: AppColors.white,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: enabled ? AppColors.primaryBlue : AppColors.darkGray.withOpacity(0.5),
      ),
      isExpanded: true,
    );
  }
}