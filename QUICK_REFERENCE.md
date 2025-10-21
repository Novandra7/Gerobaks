# 📦 Quick Reference - New Multiple Waste System

## 🚀 How to Use the New System

### 1. Add New Schedule Page

Import the new page:
```dart
import 'package:bank_sha/ui/pages/user/schedule/add_schedule_page_new.dart';
```

Navigate to it:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider.value(
      value: context.read<ScheduleBloc>(),
      child: const AddSchedulePageNew(),
    ),
  ),
);
```

### 2. Predefined Waste Types

```dart
import 'package:bank_sha/models/waste_item.dart';

// Get all types
final types = WasteType.getAllTypes();
// Returns:
// [
//   {'value': 'organik', 'label': 'Organik', 'emoji': '🍃'},
//   {'value': 'plastik', 'label': 'Plastik', 'emoji': '♻️'},
//   {'value': 'kertas', 'label': 'Kertas', 'emoji': '📄'},
//   {'value': 'kaleng', 'label': 'Kaleng', 'emoji': '🥫'},
//   {'value': 'botol_kaca', 'label': 'Botol Kaca', 'emoji': '🍾'},
//   {'value': 'elektronik', 'label': 'Elektronik', 'emoji': '📱'},
//   {'value': 'lainnya', 'label': 'Lainnya', 'emoji': '📦'},
// ]

// Get emoji for type
final emoji = WasteType.getEmoji('organik'); // Returns '🍃'

// Get display name
final name = WasteType.getDisplayName('plastik'); // Returns 'Plastik'
```

### 3. Create WasteItem

```dart
final wasteItem = WasteItem(
  wasteType: 'organik',
  estimatedWeight: 5.5,
  unit: 'kg',
  notes: 'Optional notes',
);

// Convert to JSON
final json = wasteItem.toJson();
// {
//   "wasteType": "organik",
//   "estimatedWeight": 5.5,
//   "unit": "kg",
//   "notes": "Optional notes"
// }

// From JSON
final item = WasteItem.fromJson(json);
```

### 4. BLoC Events

```dart
// Add waste item to temporary form
context.read<ScheduleBloc>().add(
  ScheduleAddWasteItem(
    WasteItem(wasteType: 'organik', estimatedWeight: 5.5),
  ),
);

// Remove waste item by index
context.read<ScheduleBloc>().add(
  ScheduleRemoveWasteItem(0),
);

// Update waste item
context.read<ScheduleBloc>().add(
  ScheduleUpdateWasteItem(
    0,
    WasteItem(wasteType: 'organik', estimatedWeight: 6.0),
  ),
);

// Clear all waste items
context.read<ScheduleBloc>().add(
  ScheduleClearWasteItems(),
);

// Create schedule
context.read<ScheduleBloc>().add(
  ScheduleCreate(
    date: '2025-10-25',
    time: '10:00',
    address: 'Jl. Contoh No. 123',
    latitude: -6.200000,
    longitude: 106.816666,
    wasteItems: [
      WasteItem(wasteType: 'organik', estimatedWeight: 5.5),
      WasteItem(wasteType: 'plastik', estimatedWeight: 2.0),
    ],
    notes: 'Optional schedule notes',
  ),
);
```

### 5. Listen to BLoC States

```dart
BlocConsumer<ScheduleBloc, ScheduleState>(
  listener: (context, state) {
    if (state is ScheduleCreated) {
      // Schedule created successfully
      Navigator.pop(context);
    } else if (state is ScheduleCreateFailed) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error)),
      );
    }
  },
  builder: (context, state) {
    if (state is ScheduleCreating) {
      return CircularProgressIndicator();
    }
    
    if (state is ScheduleFormState) {
      // Access temporary waste items
      final items = state.wasteItems;
      final total = state.totalEstimatedWeight;
      final isValid = state.isValid;
      
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return WasteItemCard(
            wasteItem: items[index],
            onEdit: () => _editItem(index),
            onDelete: () => _removeItem(index),
          );
        },
      );
    }
    
    return Container();
  },
);
```

### 6. Using Widgets

#### WasteTypeSelector
```dart
WasteTypeSelector(
  selectedTypes: ['organik', 'plastik'],
  onTypeSelected: (wasteType) {
    // Handle type selection
    _showWeightInput(wasteType);
  },
)
```

#### WeightInputDialog
```dart
final result = await showDialog<Map<String, dynamic>>(
  context: context,
  builder: (context) => const WeightInputDialog(),
);

if (result != null) {
  final weight = result['weight'] as double;
  final unit = result['unit'] as String;
  final notes = result['notes'] as String?;
  
  // Create waste item
  final item = WasteItem(
    wasteType: selectedType,
    estimatedWeight: weight,
    unit: unit,
    notes: notes,
  );
}
```

#### WasteItemCard
```dart
WasteItemCard(
  wasteItem: wasteItem,
  onEdit: () {
    // Show edit dialog
    _showEditDialog(wasteItem);
  },
  onDelete: () {
    // Remove item
    context.read<ScheduleBloc>().add(
      ScheduleRemoveWasteItem(index),
    );
  },
)
```

---

## 📁 File Structure

```
lib/
├── blocs/
│   └── schedule/
│       ├── schedule_bloc.dart       # Complete BLoC with 9 event handlers
│       ├── schedule_event.dart      # 9 events (CRUD + form management)
│       └── schedule_state.dart      # 13 states including ScheduleFormState
├── models/
│   ├── waste_item.dart              # WasteItem model + WasteType utility
│   └── schedule_model.dart          # Updated with wasteItems array
├── services/
│   └── schedule_service.dart        # New methods for waste items
└── ui/
    ├── pages/
    │   └── user/
    │       └── schedule/
    │           └── add_schedule_page_new.dart  # NEW complete page
    └── widgets/
        └── schedule/
            ├── waste_type_selector.dart        # Pill buttons
            ├── weight_input_dialog.dart        # Weight input
            └── waste_item_card.dart            # Display card
```

---

## 🗄️ Database Schema

```sql
-- New columns in schedules table
waste_items JSON NULL,
total_estimated_weight DECIMAL(8,2) DEFAULT 0.00,
INDEX idx_total_weight (total_estimated_weight)

-- Example waste_items JSON:
[
  {
    "waste_type": "organik",
    "estimated_weight": 5.5,
    "unit": "kg"
  },
  {
    "waste_type": "plastik",
    "estimated_weight": 2.0,
    "unit": "kg",
    "notes": "Botol plastik bekas"
  }
]
```

---

## 🎯 Key Points

1. **No Google Maps**: Simple address text input only
2. **Multiple Waste Types**: Select and manage multiple types
3. **Auto-calculation**: Total weight calculated automatically
4. **BLoC Pattern**: Clean, testable architecture
5. **Reusable Widgets**: Modular components
6. **Type Safety**: Predefined waste types
7. **Validation**: Weight > 0, min 1 waste item required
8. **Backward Compatible**: Old schedules still work

---

## 🚨 Important Notes

- Always wrap AddSchedulePageNew with BlocProvider.value
- Use ScheduleFormState to access temporary waste items
- Clear form state after successful creation
- Validate weight > 0 before adding
- Total weight auto-calculated in both model and state
- Old waste_type field deprecated but retained

---

## 📞 Support

For issues or questions:
1. Check IMPLEMENTATION_COMPLETE.md for full documentation
2. See docs/implementation/SISTEM_BARU_IMPLEMENTASI_PLAN.md for original plan
3. Review model files for data structure
4. Check BLoC files for state management logic
