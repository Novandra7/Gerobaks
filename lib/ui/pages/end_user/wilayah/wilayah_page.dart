import 'package:bank_sha/ui/pages/end_user/wilayah/wilayah_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/ui/widgets/shared/appbar_improved.dart';
import '../../../../blocs/tracking/tracking_bloc.dart';

class WilayahPage extends StatelessWidget {
  const WilayahPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;
    
    return BlocProvider(
      create: (_) => TrackingBloc(),
      child: Scaffold(
        appBar: const CustomAppHeaderImproved(
          title: 'Lokasi',
          showIconWithTitle: false, // Tidak menampilkan icon di samping judul
        ),
        body: WilayahContent(
          horizontalPadding: horizontalPadding,
        ),
      ),
    );
  }
}
