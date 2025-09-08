import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:flutter/material.dart';

class SignUpUplodProfilePage extends StatelessWidget {
  const SignUpUplodProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Container(
            width: 169,
            height: 88,
            margin: const EdgeInsets.only(top: 100, bottom: 50),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img_logo_name.png'),
              ),
            ),
          ),
          Text(
            'Uplod Your Photo',
            style: blackTextStyle.copyWith(fontSize: 22, fontWeight: semiBold),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: whiteColor,
            ),
            child: Column(
              children: [
                // Container(
                //   width: 120,
                //   height: 120,
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: uicolor,
                //   ),
                //   child: Center(
                //     child: Image.asset('assets/ic_uplod.png', width: 32),
                //   ),
                // ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/img_profile.png'),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Lionel Messi',
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: medium,
                  ),
                ),
                const SizedBox(height: 30),
                CustomFilledButton(
                  title: 'Continue',
                  onPressed: () {
                    // Get user data from arguments
                    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
                    if (args != null) {
                      // Pass data to sign-up-success
                      Navigator.pushNamed(
                        context,
                        '/sign-up-success',
                        arguments: args, // Pass all user data
                      );
                    } else {
                      // Show error if data missing
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Data registrasi tidak lengkap'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 35),
        ],
      ),
    );
  }
}
