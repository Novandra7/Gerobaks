import 'package:bloc/bloc.dart';
import 'package:bank_sha/models/schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// Events
abstract class ScheduleEvent {}

class ScheduleFetch extends ScheduleEvent {}

class ScheduleAdd extends ScheduleEvent {
  final ScheduleModel schedule;
  ScheduleAdd(this.schedule);
}

class ScheduleUpdate extends ScheduleEvent {
  final ScheduleModel schedule;
  ScheduleUpdate(this.schedule);
}

class ScheduleDelete extends ScheduleEvent {
  final String id;
  ScheduleDelete(this.id);
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
        
        // Dalam contoh ini kita membuat data dummy
        // Pada implementasi nyata, Anda akan mengambil data dari API atau database
        List<ScheduleModel> schedules = _getDummySchedules();
        
        emit(ScheduleSuccess(schedules));
      } catch (e) {
        emit(ScheduleFailed(e.toString()));
      }
    });
    
    on<ScheduleAdd>((event, emit) async {
      try {
        emit(ScheduleLoading());
        
        // Di sini Anda akan menambahkan jadwal ke database/API
        // Untuk contoh ini, kita hanya mengembalikan list dummy
        List<ScheduleModel> schedules = _getDummySchedules();
        
        emit(ScheduleSuccess(schedules));
      } catch (e) {
        emit(ScheduleFailed(e.toString()));
      }
    });
    
    on<ScheduleUpdate>((event, emit) async {
      try {
        emit(ScheduleLoading());
        
        // Di sini Anda akan memperbarui jadwal di database/API
        // Untuk contoh ini, kita hanya mengembalikan list dummy
        List<ScheduleModel> schedules = _getDummySchedules();
        
        emit(ScheduleSuccess(schedules));
      } catch (e) {
        emit(ScheduleFailed(e.toString()));
      }
    });
    
    on<ScheduleDelete>((event, emit) async {
      try {
        emit(ScheduleLoading());
        
        // Di sini Anda akan menghapus jadwal dari database/API
        // Untuk contoh ini, kita hanya mengembalikan list dummy
        List<ScheduleModel> schedules = _getDummySchedules();
        
        emit(ScheduleSuccess(schedules));
      } catch (e) {
        emit(ScheduleFailed(e.toString()));
      }
    });
  }
  
  // Helper method untuk mendapatkan jadwal dummy
  List<ScheduleModel> _getDummySchedules() {
    final now = DateTime.now();
    
    return [
      ScheduleModel(
        id: '1',
        userId: '123',
        scheduledDate: now.add(const Duration(days: 1)),
        timeSlot: const TimeOfDay(hour: 9, minute: 0),
        location: const LatLng(-6.2088, 106.8456), // Jakarta
        address: 'Jl. Sudirman No. 123, Jakarta Selatan',
        status: ScheduleStatus.pending,
        frequency: ScheduleFrequency.once,
        createdAt: now,
        isPaid: true,
        wasteType: 'Organik',
        contactName: 'Budi Santoso',
        contactPhone: '081234567890',
      ),
      ScheduleModel(
        id: '2',
        userId: '123',
        scheduledDate: now.add(const Duration(days: -1)),
        timeSlot: const TimeOfDay(hour: 14, minute: 0),
        location: const LatLng(-6.1751, 106.8650), // Jakarta
        address: 'Jl. Gatot Subroto No. 45, Jakarta Selatan',
        status: ScheduleStatus.completed,
        frequency: ScheduleFrequency.once,
        createdAt: now.subtract(const Duration(days: 3)),
        completedAt: now.subtract(const Duration(days: 1)),
        isPaid: true,
        wasteType: 'Anorganik',
        contactName: 'Budi Santoso',
        contactPhone: '081234567890',
      ),
      ScheduleModel(
        id: '3',
        userId: '123',
        scheduledDate: now.add(const Duration(days: 3)),
        timeSlot: const TimeOfDay(hour: 10, minute: 30),
        location: const LatLng(-6.2006, 106.7900), // Jakarta
        address: 'Jl. Kebon Jeruk No. 78, Jakarta Barat',
        status: ScheduleStatus.pending,
        frequency: ScheduleFrequency.weekly,
        createdAt: now.subtract(const Duration(days: 1)),
        isPaid: false,
        wasteType: 'Campuran',
        contactName: 'Budi Santoso',
        contactPhone: '081234567890',
      ),
    ];
  }
}
