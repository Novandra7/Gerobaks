# 🎯 IMPLEMENTASI BLOC - ROLE MITRA

**Date**: October 21, 2025  
**Target**: Implement BLoC pattern for Mitra role (same as end_user)  
**Status**: 📋 PLANNING

---

## 📊 ANALYSIS - CURRENT MITRA PAGES

### Existing Mitra Schedule Pages

```
lib/ui/pages/mitra/jadwal/
├── jadwal_mitra_page.dart              ← Main schedule list (StatefulWidget)
├── jadwal_mitra_page_new.dart          ← Alternative version
├── jadwal_detail_page.dart             ← Schedule detail view
├── jadwal_mitra_page_map_view.dart     ← Map-based view
└── jadwal_mitra_api_page.dart          ← API version
```

### Current Architecture (Without BLoC)

```
StatefulWidget
    ↓
setState() management
    ↓
Direct Service calls
    ↓
Manual state handling
```

**Problems**:

- ❌ No centralized state management
- ❌ setState() scattered everywhere
- ❌ Difficult to test
- ❌ Code duplication
- ❌ No separation of concerns

---

## 🎯 IMPLEMENTATION PLAN

### Phase 1: Update Existing BLoC (10 mins)

**Goal**: Add Mitra-specific events to existing ScheduleBloc

**Files to Update**:

1. ✅ `lib/blocs/schedule/schedule_event.dart`

   - Add FetchMitraSchedules event
   - Add AcceptSchedule event (mitra accepts schedule)
   - Add StartSchedule event (mitra starts pickup)
   - Add CompleteSchedule event (mitra completes pickup)

2. ✅ `lib/blocs/schedule/schedule_state.dart`

   - Add state for Mitra operations
   - Keep existing states (already compatible)

3. ✅ `lib/blocs/schedule/schedule_bloc.dart`
   - Add handlers for new Mitra events
   - Integrate with MitraService

---

### Phase 2: Create Mitra-Specific Widgets (15 mins)

**Goal**: Reusable components for Mitra schedule views

**New Widgets**:

1. ✅ `lib/ui/widgets/mitra/mitra_schedule_card.dart`

   - Display schedule with waste items
   - Show multiple waste types with icons
   - Total weight display
   - Status badges
   - Action buttons (Accept/Start/Complete)

2. ✅ `lib/ui/widgets/mitra/waste_items_summary.dart`
   - Compact view of all waste items
   - Icons + weight for each type
   - Total weight prominent display

---

### Phase 3: Update Mitra Pages with BLoC (30 mins)

**Goal**: Convert existing pages to use BLoC pattern

**Pages to Update**:

1. ✅ `lib/ui/pages/mitra/jadwal/jadwal_mitra_page_bloc.dart` (NEW)

   - Convert jadwal_mitra_page.dart to BLoC
   - Use ScheduleBloc for state management
   - Display schedules with waste items
   - Filter by status (pending/in_progress/completed)
   - Pull-to-refresh with BLoC

2. ✅ `lib/ui/pages/mitra/jadwal/jadwal_detail_page_bloc.dart` (NEW)
   - Convert jadwal_detail_page.dart to BLoC
   - Show full schedule details
   - Display all waste items with details
   - Total weight calculation
   - Action buttons with BLoC events
   - Map integration

---

### Phase 4: Update Navigation (5 mins)

**Goal**: Wire BLoC providers in mitra navigation

**Files to Update**:

1. ✅ `lib/ui/pages/mitra/dashboard/mitra_dashboard_page_new.dart`
   - Ensure ScheduleBloc is accessible
   - Update navigation to new BLoC pages

---

## 📋 DETAILED IMPLEMENTATION

### 1. ScheduleBloc Events (Mitra-specific)

```dart
// New events for Mitra
abstract class ScheduleEvent extends Equatable {
  // ... existing events ...

  // Mitra-specific events
  const factory ScheduleEvent.fetchMitraSchedules({
    String? status,  // pending/in_progress/completed
    DateTime? date,
  }) = FetchMitraSchedules;

  const factory ScheduleEvent.acceptSchedule({
    required String scheduleId,
  }) = AcceptSchedule;

  const factory ScheduleEvent.startSchedule({
    required String scheduleId,
  }) = StartSchedule;

  const factory ScheduleEvent.completeSchedule({
    required String scheduleId,
    required double actualWeight,  // Weight collected
  }) = CompleteSchedule;
}
```

### 2. MitraScheduleCard Widget

```dart
class MitraScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  // Display:
  - Schedule date/time
  - User name & address
  - Multiple waste items with icons
  - Total weight (sum of all items)
  - Status badge
  - Action buttons based on status
}
```

### 3. WasteItemsSummary Widget

```dart
class WasteItemsSummary extends StatelessWidget {
  final List<WasteItem> wasteItems;
  final bool showTotal;

  // Compact horizontal display:
  - 🟢 Organik: 5kg
  - 🔵 Plastik: 2kg
  - 📄 Kertas: 1.5kg
  - Total: 8.5kg (prominent)
}
```

### 4. JadwalMitraPageBloc

```dart
class JadwalMitraPageBloc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<ScheduleBloc>()
        ..add(FetchMitraSchedules()),
      child: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) return LoadingWidget();
          if (state is ScheduleSuccess) {
            return ListView.builder(
              itemCount: state.schedules.length,
              itemBuilder: (context, index) {
                final schedule = state.schedules[index];
                return MitraScheduleCard(
                  schedule: schedule,
                  onTap: () => Navigator.push(...),
                  onAccept: () => context.read<ScheduleBloc>()
                    .add(AcceptSchedule(scheduleId: schedule.id)),
                  // ... other actions
                );
              },
            );
          }
          if (state is ScheduleFailed) return ErrorWidget();
          return EmptyWidget();
        },
      ),
    );
  }
}
```

### 5. JadwalDetailPageBloc

```dart
class JadwalDetailPageBloc extends StatelessWidget {
  final String scheduleId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        final schedule = _getScheduleById(state, scheduleId);

        return Scaffold(
          body: Column(
            children: [
              // User info
              UserInfoCard(schedule.user),

              // Location with map
              LocationCard(schedule.location),

              // Waste items - SHOW ALL TYPES
              WasteItemsSection(
                wasteItems: schedule.wasteItems,  // Multiple items!
              ),

              // Total weight
              TotalWeightCard(
                totalWeight: schedule.totalEstimatedWeight,
              ),

              // Action buttons based on status
              ActionButtons(
                status: schedule.status,
                onAccept: () => context.read<ScheduleBloc>()
                  .add(AcceptSchedule(...)),
                onStart: () => context.read<ScheduleBloc>()
                  .add(StartSchedule(...)),
                onComplete: () => _showCompleteDialog(),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 🎨 UI MOCKUP - MITRA SCHEDULE CARD

```
┌─────────────────────────────────────────────────┐
│  📅 Senin, 21 Okt 2024 • 14:00 WIB              │
│                                                 │
│  👤 Daffa Kemal                                 │
│  📍 Jl. Sudirman No. 123, Jakarta               │
│                                                 │
│  🗑️ Sampah yang dijemput:                       │
│  ┌─────────────────────────────────────────┐   │
│  │ 🟢 Organik  : 5.0 kg                     │   │
│  │ 🔵 Plastik  : 2.5 kg                     │   │
│  │ 📄 Kertas   : 1.5 kg                     │   │
│  │ ─────────────────────                    │   │
│  │ ⚖️  Total    : 9.0 kg                    │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  [  ✓ Terima Jadwal  ]  [  ℹ️ Detail  ]        │
└─────────────────────────────────────────────────┘
```

---

## 🎨 UI MOCKUP - DETAIL PAGE

```
┌─────────────────────────────────────────────────┐
│  ← Detail Jadwal Pengambilan                    │
├─────────────────────────────────────────────────┤
│                                                 │
│  📍 Lokasi Penjemputan                          │
│  ┌─────────────────────────────────────────┐   │
│  │         [MAP VIEW]                       │   │
│  │    📍 User Location Marker               │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  👤 Informasi Pelanggan                         │
│  Nama    : Daffa Kemal                          │
│  Telepon : 0812-3456-7890                       │
│  Alamat  : Jl. Sudirman No. 123, Jakarta        │
│                                                 │
│  📦 Rincian Sampah                              │
│  ┌─────────────────────────────────────────┐   │
│  │ 🟢 Sampah Organik                        │   │
│  │    Estimasi: 5.0 kg                      │   │
│  │    Catatan: Dari dapur                   │   │
│  │                                           │   │
│  │ 🔵 Sampah Plastik                        │   │
│  │    Estimasi: 2.5 kg                      │   │
│  │    Catatan: Botol & kantong              │   │
│  │                                           │   │
│  │ 📄 Sampah Kertas                         │   │
│  │    Estimasi: 1.5 kg                      │   │
│  │                                           │   │
│  │ ─────────────────────                    │   │
│  │ ⚖️  TOTAL ESTIMASI: 9.0 kg               │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  [  🚀 Mulai Pengambilan  ]                     │
└─────────────────────────────────────────────────┘
```

---

## ✅ SUCCESS CRITERIA

### Functional Requirements

- ✅ Mitra can view all schedules with multiple waste items
- ✅ Each waste item type visible with icon + weight
- ✅ Total weight calculated and displayed
- ✅ Mitra can accept schedule
- ✅ Mitra can start pickup
- ✅ Mitra can complete pickup
- ✅ Real-time state updates via BLoC
- ✅ Error handling with proper feedback

### Technical Requirements

- ✅ BLoC pattern implemented
- ✅ No setState() in pages
- ✅ Centralized state management
- ✅ Reusable widgets
- ✅ Type-safe models
- ✅ Clean separation of concerns
- ✅ Testable architecture

---

## 📦 FILES TO CREATE/UPDATE

### New Files (3)

```
1. lib/ui/widgets/mitra/mitra_schedule_card.dart
2. lib/ui/widgets/mitra/waste_items_summary.dart
3. lib/ui/pages/mitra/jadwal/jadwal_mitra_page_bloc.dart
```

### Update Files (4)

```
1. lib/blocs/schedule/schedule_event.dart  (add mitra events)
2. lib/blocs/schedule/schedule_state.dart  (if needed)
3. lib/blocs/schedule/schedule_bloc.dart   (add handlers)
4. lib/ui/pages/mitra/jadwal/jadwal_detail_page.dart (convert to BLoC)
```

**Total**: 7 files

---

## ⏱️ TIME ESTIMATE

| Phase     | Task                                 | Time                    |
| --------- | ------------------------------------ | ----------------------- |
| 1         | Update BLoC (events/states/handlers) | 10 min                  |
| 2         | Create mitra widgets                 | 15 min                  |
| 3         | Create/update mitra pages            | 30 min                  |
| 4         | Update navigation                    | 5 min                   |
| 5         | Testing & fixes                      | 10 min                  |
| **TOTAL** |                                      | **70 min (~1.2 hours)** |

---

## 🚀 NEXT STEPS

1. ✅ Review this plan
2. ⏳ Start Phase 1: Update BLoC
3. ⏳ Start Phase 2: Create widgets
4. ⏳ Start Phase 3: Update pages
5. ⏳ Start Phase 4: Navigation
6. ⏳ Test end-to-end
7. ⏳ Create documentation

---

**Status**: 📋 PLAN READY - AWAITING APPROVAL  
**Next**: Begin Phase 1 - BLoC Updates
