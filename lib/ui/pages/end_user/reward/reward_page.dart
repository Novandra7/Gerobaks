import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/end_user/reward/reward_content.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppNotif(title: 'Reward', showBackButton: true),
      backgroundColor: uicolor,
      body: const RewardContent(),
    );
  }
}
