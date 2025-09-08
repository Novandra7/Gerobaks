import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/form.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppNotif(title: 'Settings', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Konten scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomFormField(
                      title: 'Current Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(title: 'New Password', obscureText: true),
                    const SizedBox(height: 16),
                    CustomFormField(
                      title: 'Confirm Password',
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            // Tombol Save di bawah
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CustomFilledButton(
                  title: 'Save',
                  onPressed: () {
                    Navigator.pushNamed(context, '');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
