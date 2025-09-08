import 'package:bank_sha/ui/pages/end_user/profile/List/settings/change_password.dart';
import 'package:bank_sha/ui/pages/end_user/profile/List/settings/terms_and_condtions.dart';
import 'package:bank_sha/ui/pages/end_user/profile/List/settings/notification_settings.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppNotif(title: 'Settings', showBackButton: true),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppMenu(
              iconURL: 'assets/ic_notification.png',
              title: 'Pengaturan Notifikasi',
              page: const NotificationSettings(),
            ),
            CustomAppMenu(
              iconURL: 'assets/ic_setting.png',
              title: 'Ganti Password',
              page:
                  const ChangePassword(), // Ganti dengan halaman tujuan sebenarnya
            ),
            CustomAppMenu(
              iconURL: 'assets/ic_profile_profile.png',
              title: 'Terms And Conditions',
              page:
                  TermsAndCondtions(), // Ganti dengan halaman tujuan sebenarnya
            ),
            CustomAppMenu(
              iconURL: 'assets/ic_profile_profile.png',
              title: 'Hapus Account',
              page: Container(), // Ganti dengan halaman tujuan sebenarnya
            ),
          ],
        ),
      ),
    );
  }
}
