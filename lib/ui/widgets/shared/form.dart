import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
  final String title;
  final bool obscureText;
  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;

  const CustomFormField({
    super.key,
    required this.title,
    this.obscureText = false,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.onTap,
    this.readOnly = false,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.obscureText;
  }

  void _toggleObscured() {
    setState(() {
      isObscured = !isObscured;
    });
  }

  // Method untuk mendapatkan icon berdasarkan title
  IconData _getDefaultIcon() {
    final title = widget.title.toLowerCase();
    if (title.contains('email')) {
      return Icons.email_outlined;
    } else if (title.contains('password')) {
      return Icons.lock_outline;
    } else if (title.contains('phone') || title.contains('handphone') || title.contains('telepon')) {
      return Icons.phone_outlined;
    } else if (title.contains('name') || title.contains('nama')) {
      return Icons.person_outline;
    } else if (title.contains('address') || title.contains('alamat')) {
      return Icons.location_on_outlined;
    } else if (title.contains('date') || title.contains('tanggal')) {
      return Icons.calendar_today_outlined;
    } else if (title.contains('time') || title.contains('waktu') || title.contains('jam')) {
      return Icons.access_time_outlined;
    } else {
      return Icons.text_fields_outlined;
    }
  }

  // Method untuk mendapatkan hint text default
  String _getDefaultHint() {
    if (widget.hintText != null) return widget.hintText!;
    
    final title = widget.title.toLowerCase();
    if (title.contains('email')) {
      return 'Masukkan email address';
    } else if (title.contains('password')) {
      return 'Masukkan password';
    } else if (title.contains('verifikasi') && title.contains('password')) {
      return 'Masukkan ulang password';
    } else if (title.contains('phone') || title.contains('handphone')) {
      return 'Masukkan nomor handphone';
    } else if (title.contains('name') || title.contains('nama')) {
      return 'Masukkan ${widget.title.toLowerCase()}';
    } else {
      return 'Masukkan ${widget.title.toLowerCase()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: blackTextStyle.copyWith(
            fontSize: 14,
            fontWeight: medium,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: isObscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          style: blackTextStyle.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: _getDefaultHint(),
            hintStyle: greyTextStyle.copyWith(fontSize: 14),
            prefixIcon: Icon(
              widget.prefixIcon ?? _getDefaultIcon(),
              color: greyColor,
              size: 20,
            ),
            suffixIcon: widget.suffixIcon ?? (widget.obscureText
                ? IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility_off : Icons.visibility,
                      color: greyColor,
                      size: 20,
                    ),
                    onPressed: _toggleObscured,
                  )
                : null),
            filled: true,
            fillColor: lightBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: greyColor.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: greyColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: greenColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: redcolor,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: redcolor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class CustomFormJadwal extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final bool obscureText;
  final bool readOnly;
  final String? hintText;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomFormJadwal({
    super.key,
    required this.title,
    this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.keyboardType,
    this.validator,
  });

  // Method untuk mendapatkan icon berdasarkan title
  IconData _getDefaultIcon() {
    final title = this.title.toLowerCase();
    if (title.contains('email')) {
      return Icons.email_outlined;
    } else if (title.contains('password')) {
      return Icons.lock_outline;
    } else if (title.contains('phone') || title.contains('handphone') || title.contains('telepon')) {
      return Icons.phone_outlined;
    } else if (title.contains('name') || title.contains('nama')) {
      return Icons.person_outline;
    } else if (title.contains('address') || title.contains('alamat')) {
      return Icons.location_on_outlined;
    } else if (title.contains('date') || title.contains('tanggal')) {
      return Icons.calendar_today_outlined;
    } else if (title.contains('time') || title.contains('waktu') || title.contains('jam')) {
      return Icons.access_time_outlined;
    } else if (title.contains('kategori') || title.contains('jenis')) {
      return Icons.category_outlined;
    } else if (title.contains('deskripsi') || title.contains('keterangan')) {
      return Icons.description_outlined;
    } else {
      return Icons.text_fields_outlined;
    }
  }

  // Method untuk mendapatkan hint text default
  String _getDefaultHint() {
    if (hintText != null) return hintText!;
    
    final titleLower = title.toLowerCase();
    if (titleLower.contains('pilih')) {
      return 'Pilih ${title.toLowerCase().replaceAll('pilih ', '')}';
    } else if (titleLower.contains('tanggal')) {
      return 'Pilih tanggal';
    } else if (titleLower.contains('waktu') || titleLower.contains('jam')) {
      return 'Pilih waktu';
    } else {
      return 'Masukkan ${title.toLowerCase()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: blackTextStyle.copyWith(
            fontSize: 14,
            fontWeight: medium,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          style: blackTextStyle.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: _getDefaultHint(),
            hintStyle: greyTextStyle.copyWith(fontSize: 14),
            prefixIcon: Icon(
              prefixIcon ?? _getDefaultIcon(),
              color: greyColor,
              size: 20,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: lightBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: greyColor.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: greyColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: greenColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: redcolor,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: redcolor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
