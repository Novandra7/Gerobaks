import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/models/waste_item.dart';
import 'package:equatable/equatable.dart';

/// Schedule States untuk BLoC pattern
abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

/// Loading state (fetching schedules)
class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

/// Success state dengan list schedules
class ScheduleSuccess extends ScheduleState {
  final List<ScheduleModel> schedules;

  const ScheduleSuccess(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

/// Failed state dengan error message
class ScheduleFailed extends ScheduleState {
  final String error;

  const ScheduleFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// Creating schedule state
class ScheduleCreating extends ScheduleState {
  const ScheduleCreating();
}

/// Schedule created successfully
class ScheduleCreated extends ScheduleState {
  final ScheduleModel schedule;

  const ScheduleCreated(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

/// Schedule creation failed
class ScheduleCreateFailed extends ScheduleState {
  final String error;

  const ScheduleCreateFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// Updating schedule state
class ScheduleUpdating extends ScheduleState {
  const ScheduleUpdating();
}

/// Schedule updated successfully
class ScheduleUpdated extends ScheduleState {
  final ScheduleModel schedule;

  const ScheduleUpdated(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

/// Schedule update failed
class ScheduleUpdateFailed extends ScheduleState {
  final String error;

  const ScheduleUpdateFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// Deleting schedule state
class ScheduleDeleting extends ScheduleState {
  const ScheduleDeleting();
}

/// Schedule deleted successfully
class ScheduleDeleted extends ScheduleState {
  final String scheduleId;

  const ScheduleDeleted(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

/// Schedule deletion failed
class ScheduleDeleteFailed extends ScheduleState {
  final String error;

  const ScheduleDeleteFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// Form state - managing waste items in form
class ScheduleFormState extends ScheduleState {
  final List<WasteItem> wasteItems;
  final double totalEstimatedWeight;
  final bool isValid;

  const ScheduleFormState({
    required this.wasteItems,
    required this.totalEstimatedWeight,
    required this.isValid,
  });

  factory ScheduleFormState.initial() {
    return const ScheduleFormState(
      wasteItems: [],
      totalEstimatedWeight: 0.0,
      isValid: false,
    );
  }

  ScheduleFormState copyWith({
    List<WasteItem>? wasteItems,
    double? totalEstimatedWeight,
    bool? isValid,
  }) {
    final items = wasteItems ?? this.wasteItems;
    final total =
        totalEstimatedWeight ??
        items.fold<double>(0.0, (sum, item) => sum + item.estimatedWeight);

    return ScheduleFormState(
      wasteItems: items,
      totalEstimatedWeight: total,
      isValid: isValid ?? items.isNotEmpty,
    );
  }

  @override
  List<Object?> get props => [wasteItems, totalEstimatedWeight, isValid];
}
