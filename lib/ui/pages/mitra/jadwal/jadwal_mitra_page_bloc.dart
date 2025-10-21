import 'package:bank_sha/blocs/schedule/schedule_bloc.dart';
import 'package:bank_sha/blocs/schedule/schedule_event.dart';
import 'package:bank_sha/blocs/schedule/schedule_state.dart';
import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/buttons.dart';
import 'package:bank_sha/ui/widgets/mitra/mitra_schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mitra Schedule Page (BLoC version)
/// Shows list of schedules for mitra with filtering by status
/// Uses BLoC pattern for state management
class JadwalMitraPageBloc extends StatefulWidget {
  const JadwalMitraPageBloc({super.key});

  @override
  State<JadwalMitraPageBloc> createState() => _JadwalMitraPageBlocState();
}

class _JadwalMitraPageBlocState extends State<JadwalMitraPageBloc>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab index mapping
  static const int tabPending = 0;
  static const int tabAccepted = 1;
  static const int tabInProgress = 2;
  static const int tabCompleted = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load pending schedules initially
    _loadSchedules('pending');

    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    String? status;
    switch (index) {
      case tabPending:
        status = 'pending';
        break;
      case tabAccepted:
        status = 'accepted';
        break;
      case tabInProgress:
        status = 'in_progress';
        break;
      case tabCompleted:
        status = 'completed';
        break;
    }
    _loadSchedules(status);
  }

  void _loadSchedules(String? status) {
    context.read<ScheduleBloc>().add(
          ScheduleFetchMitra(
            status: status,
            page: 1,
            perPage: 50,
          ),
        );
  }

  void _refreshSchedules() {
    final currentTab = _tabController.index;
    _onTabChanged(currentTab);
  }

  void _onAcceptSchedule(ScheduleModel schedule) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Terima Jadwal'),
        content: const Text('Apakah Anda yakin ingin menerima jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ScheduleBloc>().add(
                    ScheduleAccept(scheduleId: schedule.id),
                  );
            },
            child: const Text('Terima'),
          ),
        ],
      ),
    );
  }

  void _onStartSchedule(ScheduleModel schedule) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mulai Pengambilan'),
        content: const Text(
          'Apakah Anda yakin ingin memulai pengambilan sampah?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ScheduleBloc>().add(
                    ScheduleStart(scheduleId: schedule.id),
                  );
            },
            child: const Text('Mulai'),
          ),
        ],
      ),
    );
  }

  void _onCompleteSchedule(ScheduleModel schedule) {
    // Show input dialog for actual weight and notes
    final weightController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Selesaikan Jadwal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Berat Aktual (kg)',
                hintText: 'Masukkan berat sampah yang dijemput',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Tambahkan catatan jika ada',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final actualWeight = double.tryParse(weightController.text);
              context.read<ScheduleBloc>().add(
                    ScheduleComplete(
                      scheduleId: schedule.id,
                      actualWeight: actualWeight,
                      notes: notesController.text.isEmpty
                          ? null
                          : notesController.text,
                    ),
                  );
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  void _onViewDetail(ScheduleModel schedule) {
    Navigator.pushNamed(
      context,
      '/jadwal-detail',
      arguments: schedule,
    ).then((_) {
      // Refresh when coming back
      _refreshSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Pengambilan'),
        backgroundColor: lightBackgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: primaryColor,
          unselectedLabelColor: greyColor,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: 'Menunggu'),
            Tab(text: 'Diterima'),
            Tab(text: 'Proses'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: BlocConsumer<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          // Show snackbar on update success/failure
          if (state is ScheduleUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Jadwal berhasil diperbarui'),
                backgroundColor: Colors.green,
              ),
            );
            _refreshSchedules();
          } else if (state is ScheduleUpdateFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildScheduleList(state, 'pending'),
              _buildScheduleList(state, 'accepted'),
              _buildScheduleList(state, 'in_progress'),
              _buildScheduleList(state, 'completed'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScheduleList(ScheduleState state, String status) {
    if (state is ScheduleLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ScheduleLoadFailed) {
      return _buildErrorView(state.error);
    }

    if (state is ScheduleLoaded) {
      final schedules = state.schedules
          .where((s) => s.status.name == status)
          .toList();

      if (schedules.isEmpty) {
        return _buildEmptyView(status);
      }

      return RefreshIndicator(
        onRefresh: () async {
          _refreshSchedules();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return MitraScheduleCard(
              schedule: schedule,
              onTap: () => _onViewDetail(schedule),
              onAccept: status == 'pending'
                  ? () => _onAcceptSchedule(schedule)
                  : null,
              onStart: status == 'accepted'
                  ? () => _onStartSchedule(schedule)
                  : null,
              onComplete: status == 'in_progress'
                  ? () => _onCompleteSchedule(schedule)
                  : null,
            );
          },
        ),
      );
    }

    // Initial or updating state
    if (state is ScheduleUpdating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memperbarui jadwal...'),
          ],
        ),
      );
    }

    return _buildEmptyView(status);
  }

  Widget _buildEmptyView(String status) {
    String message;
    IconData icon;

    switch (status) {
      case 'pending':
        message = 'Tidak ada jadwal menunggu';
        icon = Icons.schedule;
        break;
      case 'accepted':
        message = 'Tidak ada jadwal diterima';
        icon = Icons.check_circle_outline;
        break;
      case 'in_progress':
        message = 'Tidak ada jadwal sedang diproses';
        icon = Icons.local_shipping;
        break;
      case 'completed':
        message = 'Belum ada jadwal selesai';
        icon = Icons.check_circle;
        break;
      default:
        message = 'Tidak ada jadwal';
        icon = Icons.event_busy;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: greyColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: greyTextStyle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 24),
          CustomFilledButton(
            title: 'Muat Ulang',
            onPressed: _refreshSchedules,
            width: 150,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: blackTextStyle.copyWith(
                fontSize: 16,
                fontWeight: semiBold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: greyTextStyle.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomFilledButton(
              title: 'Coba Lagi',
              onPressed: _refreshSchedules,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}
