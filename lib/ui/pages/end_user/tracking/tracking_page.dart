import 'package:bank_sha/blocs/tracking/tracking_bloc.dart';
import 'package:bank_sha/services/tracking_service_new.dart';
import 'package:bank_sha/ui/pages/end_user/tracking/tracking_content.dart';
import 'package:bank_sha/ui/pages/end_user/tracking/tracking_page_args.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = TrackingPageArgs.from(
      ModalRoute.of(context)?.settings.arguments,
    );

    return BlocProvider(
      create: (_) => TrackingBloc(
        trackingService: TrackingService(),
        initialScheduleId: args?.scheduleId,
        initialDestination: args?.destination,
      ),
      child: Scaffold(
        appBar: const CutomAppTracking(),
        body: TrackingContent(args: args),
      ),
    );
  }
}
