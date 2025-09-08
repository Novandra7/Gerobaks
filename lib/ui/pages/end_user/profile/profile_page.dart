import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/end_user/profile/profile_content.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/ui/widgets/shared/appbar_improved.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 32.0 : 24.0;
    
    return Scaffold(
      backgroundColor: uicolor,
      appBar: CustomAppHeaderImproved(
        title: 'Profile',
        imageAssetPath: 'assets/ic_edit_profile2.png',
        showIconWithTitle: false, // Tidak menampilkan icon di samping judul
        onActionPressed: () {
          // Handle edit profile action
          Navigator.pushNamed(context, '/my-profile');
        },
      ),
      body: ProfileContent(
        horizontalPadding: horizontalPadding,
      ),
    );
  }
}
