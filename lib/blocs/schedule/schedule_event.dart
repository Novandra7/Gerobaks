import 'package:bank_sha/models/waste_item.dart';
import 'package:equatable/equatable.dart';

/// Schedule Events untuk BLoC pattern
abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch schedules from API
class ScheduleFetch extends ScheduleEvent {
  final int? assignedTo;
  final String? status;
  final int page;
  final int perPage;
  final String? fallbackUserId;

  const ScheduleFetch({
    this.assignedTo,
    this.status,
    this.page = 1,
    this.perPage = 50,
    this.fallbackUserId,
  });

  @override
  List<Object?> get props => [
    assignedTo,
    status,
    page,
    perPage,
    fallbackUserId,
  ];
}

/// Create new schedule with multiple waste items
class ScheduleCreate extends ScheduleEvent {
  final String date;
  final String time;
  final String address;
  final double latitude;
  final double longitude;
  final List<WasteItem> wasteItems;
  final String? notes;
  final String? contactName;
  final String? contactPhone;

  const ScheduleCreate({
    required this.date,
    required this.time,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.wasteItems,
    this.notes,
    this.contactName,
    this.contactPhone,
  });

  @override
  List<Object?> get props => [
    date,
    time,
    address,
    latitude,
    longitude,
    wasteItems,
    notes,
    contactName,
    contactPhone,
  ];
}

/// Update existing schedule
class ScheduleUpdate extends ScheduleEvent {
  final String scheduleId;
  final String? date;
  final String? time;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<WasteItem>? wasteItems;
  final String? notes;
  final String? status;

  const ScheduleUpdate({
    required this.scheduleId,
    this.date,
    this.time,
    this.address,
    this.latitude,
    this.longitude,
    this.wasteItems,
    this.notes,
    this.status,
  });

  @override
  List<Object?> get props => [
    scheduleId,
    date,
    time,
    address,
    latitude,
    longitude,
    wasteItems,
    notes,
    status,
  ];
}

/// Delete schedule
class ScheduleDelete extends ScheduleEvent {
  final String scheduleId;

  const ScheduleDelete(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

/// Add waste item to temporary list (for form state)
class ScheduleAddWasteItem extends ScheduleEvent {
  final WasteItem wasteItem;

  const ScheduleAddWasteItem(this.wasteItem);

  @override
  List<Object?> get props => [wasteItem];
}

/// Remove waste item from temporary list
class ScheduleRemoveWasteItem extends ScheduleEvent {
  final int index;

  const ScheduleRemoveWasteItem(this.index);

  @override
  List<Object?> get props => [index];
}

/// Update waste item in temporary list
class ScheduleUpdateWasteItem extends ScheduleEvent {
  final int index;
  final WasteItem wasteItem;

  const ScheduleUpdateWasteItem(this.index, this.wasteItem);

  @override
  List<Object?> get props => [index, wasteItem];
}

/// Clear temporary waste items list
class ScheduleClearWasteItems extends ScheduleEvent {
  const ScheduleClearWasteItems();
}

/// Reset schedule form to initial state
class ScheduleResetForm extends ScheduleEvent {
  const ScheduleResetForm();
}

// ============================================================================
// MITRA-SPECIFIC EVENTS
// ============================================================================

/// Fetch schedules for Mitra (assigned schedules)
class ScheduleFetchMitra extends ScheduleEvent {
  final String? status; // pending, accepted, in_progress, completed
  final DateTime? date;
  final int page;
  final int perPage;

  const ScheduleFetchMitra({
    this.status,
    this.date,
    this.page = 1,
    this.perPage = 50,
  });

  @override
  List<Object?> get props => [status, date, page, perPage];
}

/// Mitra accepts a pending schedule
class ScheduleAccept extends ScheduleEvent {
  final String scheduleId;

  const ScheduleAccept(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

/// Mitra starts the pickup (changes status to in_progress)
class ScheduleStart extends ScheduleEvent {
  final String scheduleId;

  const ScheduleStart(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

/// Mitra completes the pickup
class ScheduleComplete extends ScheduleEvent {
  final String scheduleId;
  final double? actualWeight; // Actual weight collected (optional)
  final String? notes; // Completion notes (optional)

  const ScheduleComplete({
    required this.scheduleId,
    this.actualWeight,
    this.notes,
  });

  @override
  List<Object?> get props => [scheduleId, actualWeight, notes];
}

/// Mitra cancels/rejects a schedule
class ScheduleCancel extends ScheduleEvent {
  final String scheduleId;
  final String? reason;

  const ScheduleCancel({required this.scheduleId, this.reason});

  @override
  List<Object?> get props => [scheduleId, reason];
}
