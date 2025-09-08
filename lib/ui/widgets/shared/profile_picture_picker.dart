import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

class ProfilePicturePicker extends StatelessWidget {
  final String currentPicture;
  final Function(String) onPictureSelected;

  const ProfilePicturePicker({
    super.key,
    required this.currentPicture,
    required this.onPictureSelected,
  });
  
  // Helper method to determine the correct ImageProvider based on the path
  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      // Network image
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      // Asset image
      return AssetImage(path);
    } else {
      // Try asset first, fall back to network if it fails
      try {
        return AssetImage(path);
      } catch (_) {
        // If not asset, try as a file or network path
        return NetworkImage(path);
      }
    }
  }

  void _showPictureOptions(BuildContext context) {
    final List<String> availablePictures = [
      'assets/img_friend1.png',
      'assets/img_friend2.png',
      'assets/img_friend3.png',
      'assets/img_friend4.png',
      'assets/img_profile.png',
    ];
    
    // Check if screen is tablet-sized for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 28 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.green.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_circle,
                    color: greenColor,
                    size: isTablet ? 28 : 24,
                  ),
                  SizedBox(width: isTablet ? 12 : 8),
                  Text(
                    'Pilih Foto Profil',
                    style: blackTextStyle.copyWith(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: semiBold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: isTablet ? 16 : 12,
                runSpacing: isTablet ? 16 : 12,
                children: availablePictures.map((picture) {
                  return Material(
                    elevation: 2,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: greenColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        onPictureSelected(picture);
                        Navigator.pop(context);
                      },
                      customBorder: const CircleBorder(),
                      splashColor: greenColor.withOpacity(0.3),
                      child: CircleAvatar(
                        radius: isTablet ? 40 : 32,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(picture),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16, 
                    vertical: isTablet ? 12 : 8
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Batal',
                  style: greyTextStyle.copyWith(
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if screen is tablet-sized
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final avatarSize = isTablet ? 70.0 : 60.0;
    
    return Stack(
      children: [
        // Interactive profile picture with hover effect
        InkWell(
          onTap: () => _showPictureOptions(context),
          borderRadius: BorderRadius.circular(avatarSize),
          child: Hero(
            tag: 'profile-picture',
            child: Container(
              width: avatarSize * 2,
              height: avatarSize * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: _getImageProvider(currentPicture),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: greenColor.withOpacity(0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Edit button with improved appearance
        Positioned(
          right: 4,
          bottom: 4,
          child: Material(
            color: greenColor,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              onTap: () => _showPictureOptions(context),
              customBorder: const CircleBorder(),
              splashColor: Colors.white24,
              child: Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: whiteColor,
                  size: isTablet ? 22 : 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
