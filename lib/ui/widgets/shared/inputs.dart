import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFormField extends StatelessWidget {
  final String title;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool readOnly;
  final int? maxLength;
  final int? maxLines;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final String? initialValue;
  final Color? titleColor;
  final Color? hintColor;
  final Widget? prefixIcon;

  const CustomFormField({
    Key? key,
    required this.title,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.onChanged,
    this.inputFormatters,
    this.validator,
    this.readOnly = false,
    this.maxLength,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.initialValue,
    this.titleColor,
    this.hintColor,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: blackTextStyle.copyWith(
            fontWeight: medium,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          validator: validator,
          readOnly: readOnly,
          maxLength: maxLength,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          focusNode: focusNode,
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: greyTextStyle.copyWith(
              fontWeight: regular,
              color: hintColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: greyColor,
              ),
            ),
            contentPadding: const EdgeInsets.all(12),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}

class CustomDropdownField<T> extends StatelessWidget {
  final String title;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final bool isExpanded;
  final Color? titleColor;
  final Color? hintColor;
  final Widget? icon;
  final String? Function(T?)? validator;

  const CustomDropdownField({
    Key? key,
    required this.title,
    required this.hint,
    this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = true,
    this.titleColor,
    this.hintColor,
    this.icon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: blackTextStyle.copyWith(
            fontWeight: medium,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: isExpanded,
          validator: validator,
          icon: icon ?? const Icon(Icons.arrow_drop_down_rounded),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: greyTextStyle.copyWith(
              fontWeight: regular,
              color: hintColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: greyColor,
              ),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}

class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onSubmitted;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool readOnly;
  final FocusNode? focusNode;

  const CustomSearchField({
    Key? key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      focusNode: focusNode,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: greyTextStyle.copyWith(
          fontWeight: regular,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        prefixIcon: prefixIcon ?? const Icon(Icons.search),
        suffixIcon: suffixIcon,
      ),
      onFieldSubmitted: (value) {
        if (onSubmitted != null) {
          onSubmitted!();
        }
      },
    );
  }
}
