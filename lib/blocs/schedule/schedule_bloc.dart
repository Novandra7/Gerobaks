import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/blocs/schedule/schedule_event.dart';
import 'package:bank_sha/blocs/schedule/schedule_state.dart';
import 'package:bank_sha/services/schedule_service.dart';

// Bloc with full CRUD and form management
class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleService _scheduleService;

  // Track current form state for waste items
  ScheduleFormState _currentFormState = ScheduleFormState.initial();

  ScheduleBloc({ScheduleService? scheduleService})
    : _scheduleService = scheduleService ?? ScheduleService(),
      super(const ScheduleInitial()) {
    // API Operations
    on<ScheduleFetch>(_onScheduleFetch);
    on<ScheduleCreate>(_onScheduleCreate);
    on<ScheduleUpdate>(_onScheduleUpdate);
    on<ScheduleDelete>(_onScheduleDelete);

    // Form State Management
    on<ScheduleAddWasteItem>(_onAddWasteItem);
    on<ScheduleRemoveWasteItem>(_onRemoveWasteItem);
    on<ScheduleUpdateWasteItem>(_onUpdateWasteItem);
    on<ScheduleClearWasteItems>(_onClearWasteItems);
    on<ScheduleResetForm>(_onResetForm);

    // Mitra Operations
    on<ScheduleFetchMitra>(_onScheduleFetchMitra);
    on<ScheduleAccept>(_onScheduleAccept);
    on<ScheduleStart>(_onScheduleStart);
    on<ScheduleComplete>(_onScheduleComplete);
    on<ScheduleCancel>(_onScheduleCancel);
  }

  // Fetch schedules
  Future<void> _onScheduleFetch(
    ScheduleFetch event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      emit(const ScheduleLoading());

      final schedules = await _scheduleService.refreshSchedules(
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
  }

  // Create schedule with multiple waste items
  Future<void> _onScheduleCreate(
    ScheduleCreate event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      emit(const ScheduleCreating());

      final schedule = await _scheduleService.createScheduleWithWasteItems(
        date: event.date,
        time: event.time,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
        wasteItems: event.wasteItems,
        notes: event.notes,
      );

      emit(ScheduleCreated(schedule));

      // Clear form state after successful creation
      _currentFormState = ScheduleFormState.initial();
    } catch (e) {
      emit(ScheduleCreateFailed(e.toString()));
    }
  }

  // Update schedule
  Future<void> _onScheduleUpdate(
    ScheduleUpdate event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      emit(const ScheduleUpdating());

      final schedule = await _scheduleService.updateScheduleWithWasteItems(
        scheduleId: event.scheduleId,
        date: event.date,
        time: event.time,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
        wasteItems: event.wasteItems,
        status: event.status,
        notes: event.notes,
      );

      emit(ScheduleUpdated(schedule));
    } catch (e) {
      emit(ScheduleUpdateFailed(e.toString()));
    }
  }

  // Delete schedule
  Future<void> _onScheduleDelete(
    ScheduleDelete event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      emit(const ScheduleDeleting());

      await _scheduleService.deleteSchedule(event.scheduleId);

      emit(ScheduleDeleted(event.scheduleId));
    } catch (e) {
      emit(ScheduleDeleteFailed(e.toString()));
    }
  }

  // Add waste item to temporary form state
  void _onAddWasteItem(
    ScheduleAddWasteItem event,
    Emitter<ScheduleState> emit,
  ) {
    final updatedItems = List.of(_currentFormState.wasteItems)
      ..add(event.wasteItem);

    _currentFormState = _currentFormState.copyWith(wasteItems: updatedItems);

    emit(_currentFormState);
  }

  // Remove waste item by index
  void _onRemoveWasteItem(
    ScheduleRemoveWasteItem event,
    Emitter<ScheduleState> emit,
  ) {
    if (event.index >= 0 && event.index < _currentFormState.wasteItems.length) {
      final updatedItems = List.of(_currentFormState.wasteItems)
        ..removeAt(event.index);

      _currentFormState = _currentFormState.copyWith(wasteItems: updatedItems);

      emit(_currentFormState);
    }
  }

  // Update waste item at specific index
  void _onUpdateWasteItem(
    ScheduleUpdateWasteItem event,
    Emitter<ScheduleState> emit,
  ) {
    if (event.index >= 0 && event.index < _currentFormState.wasteItems.length) {
      final updatedItems = List.of(_currentFormState.wasteItems);
      updatedItems[event.index] = event.wasteItem;

      _currentFormState = _currentFormState.copyWith(wasteItems: updatedItems);

      emit(_currentFormState);
    }
  }

  // Clear all waste items
  void _onClearWasteItems(
    ScheduleClearWasteItems event,
    Emitter<ScheduleState> emit,
  ) {
    _currentFormState = ScheduleFormState.initial();
    emit(_currentFormState);
  }

  // Reset form completely
  void _onResetForm(ScheduleResetForm event, Emitter<ScheduleState> emit) {
    _currentFormState = ScheduleFormState.initial();
    emit(const ScheduleInitial());
  }

  // Getter for current form state
  ScheduleFormState get currentFormState => _currentFormState;

  // ============================================================================
  // MITRA-SPECIFIC HANDLERS
  // ============================================================================

  // Fetch schedules for Mitra
  Future<void> _onScheduleFetchMitra(
    ScheduleFetchMitra event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      emit(const ScheduleLoading());

      // Fetch schedules assigned to this mitra
      final schedules = await _scheduleService.refreshSchedules(
        page: event.page,
        perPage: event.perPage,
        status: event.status,
        // Additional filtering by date if provided
      );

      emit(ScheduleSuccess(schedules));
    } catch (e) {
      emit(ScheduleFailed(e.toString()));
    }
  }

  // Mitra accepts a schedule
  Future<void> _onScheduleAccept(
    ScheduleAccept event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      emit(const ScheduleUpdating());

      // Update schedule status to 'accepted'
      final schedule = await _scheduleService.updateScheduleWithWasteItems(
        scheduleId: event.scheduleId,
        status: 'accepted',
      );

      emit(ScheduleUpdated(schedule));
    } catch (e) {
      emit(ScheduleUpdateFailed(e.toString()));
    }
  }

  // Mitra starts the pickup
  Future<void> _onScheduleStart(
    ScheduleStart event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      emit(const ScheduleUpdating());

      // Update schedule status to 'in_progress'
      final schedule = await _scheduleService.updateScheduleWithWasteItems(
        scheduleId: event.scheduleId,
        status: 'in_progress',
      );

      emit(ScheduleUpdated(schedule));
    } catch (e) {
      emit(ScheduleUpdateFailed(e.toString()));
    }
  }

  // Mitra completes the pickup
  Future<void> _onScheduleComplete(
    ScheduleComplete event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      emit(const ScheduleUpdating());

      // Update schedule status to 'completed'
      // Optionally include actual weight and notes
      final schedule = await _scheduleService.updateScheduleWithWasteItems(
        scheduleId: event.scheduleId,
        status: 'completed',
        notes: event.notes,
        // If actualWeight is provided, you might want to add it to the model
      );

      emit(ScheduleUpdated(schedule));
    } catch (e) {
      emit(ScheduleUpdateFailed(e.toString()));
    }
  }

  // Mitra cancels/rejects a schedule
  Future<void> _onScheduleCancel(
    ScheduleCancel event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      emit(const ScheduleUpdating());

      // Update schedule status to 'cancelled'
      final schedule = await _scheduleService.updateScheduleWithWasteItems(
        scheduleId: event.scheduleId,
        status: 'cancelled',
        notes: event.reason,
      );

      emit(ScheduleUpdated(schedule));
    } catch (e) {
      emit(ScheduleUpdateFailed(e.toString()));
    }
  }
}
