import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/ui/pages/end_user/tracking/tracking_content.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import '../../../../blocs/tracking/tracking_bloc.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrackingBloc(),
      child: const Scaffold(
        appBar: CutomAppTracking(), // ✅ Tetap pakai AppBar kamu
        body: TrackingContent(),
      ),
    );
  }
}
