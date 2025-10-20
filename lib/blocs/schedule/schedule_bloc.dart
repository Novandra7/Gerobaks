import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/schedule_service.dart';

// Events
abstract class ScheduleEvent {}

class ScheduleFetch extends ScheduleEvent {
  ScheduleFetch({
    this.assignedTo,
    this.status,
    this.page = 1,
    this.perPage = 50,
    this.fallbackUserId,
  });

  final int? assignedTo;
  final String? status;
  final int page;
  final int perPage;
  final String? fallbackUserId;
}

// States
abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleSuccess extends ScheduleState {
  final List<ScheduleModel> schedules;
  ScheduleSuccess(this.schedules);
}

class ScheduleFailed extends ScheduleState {
  final String e;
  ScheduleFailed(this.e);
}

// Bloc
class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc() : super(ScheduleInitial()) {
    on<ScheduleFetch>((event, emit) async {
      try {
        emit(ScheduleLoading());
        final service = ScheduleService();
        final schedules = await service.refreshSchedules(
          page: event.page,
          perPage: event.perPage,
          assignedTo: event.assignedTo,
          status: event.status,
          fallbackUserId: event.fallbackUserId,
        );

        emit(ScheduleSuccess(schedules));
      } catch (e) {
        emit(ScheduleFailed(e.toString()));
      }
    });
  }
}
