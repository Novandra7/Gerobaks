# 🗺️ Navigation Update Guide

Panduan untuk mengupdate navigation ke halaman add schedule yang baru.

---

## 📍 Where to Update

Cari semua tempat yang menggunakan `AddSchedulePage` lama dan ganti dengan `AddSchedulePageNew`.

---

## 🔍 Find Old References

```bash
# Search for old page imports
grep -r "add_schedule_page.dart" lib/

# Search for AddSchedulePage usage
grep -r "AddSchedulePage(" lib/
```

---

## ✏️ Update Pattern

### Before (Old)

```dart
import 'package:bank_sha/ui/pages/user/schedule/add_schedule_page.dart';

// Navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AddSchedulePage(),
  ),
);
```

### After (New)

```dart
import 'package:bank_sha/ui/pages/user/schedule/add_schedule_page_new.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/blocs/schedule/schedule_bloc.dart';

// Navigation with BLoC provider
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

---

## 📝 Common Locations to Update

### 1. Schedule List Page

```dart
// Likely: lib/ui/pages/user/schedule/schedule_list_page.dart
// or: lib/ui/pages/user/home/home_page.dart

FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ScheduleBloc>(),
          child: const AddSchedulePageNew(),
        ),
      ),
    );
  },
  child: Icon(Icons.add),
)
```

### 2. Navigation/Bottom Bar

```dart
// Check navigation handlers
case 'schedule':
  return BlocProvider.value(
    value: context.read<ScheduleBloc>(),
    child: const AddSchedulePageNew(),
  );
```

### 3. Deep Links / Routes

```dart
// If using named routes
routes: {
  '/add-schedule': (context) => BlocProvider.value(
    value: context.read<ScheduleBloc>(),
    child: const AddSchedulePageNew(),
  ),
}
```

---

## ⚠️ Important Notes

1. **Always wrap with BlocProvider.value** to pass existing ScheduleBloc
2. **Don't create new BLoC instance** - use existing one from context
3. **Update imports** to use `add_schedule_page_new.dart`
4. **Test navigation flow** after updating

---

## 🎯 After Navigation

When user successfully creates schedule:

```dart
// In AddSchedulePageNew - already handled
BlocConsumer<ScheduleBloc, ScheduleState>(
  listener: (context, state) {
    if (state is ScheduleCreated) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to previous page with result
      Navigator.pop(context, true); // true = success
    }
  },
  // ...
)
```

Then in calling page:

```dart
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider.value(
      value: context.read<ScheduleBloc>(),
      child: const AddSchedulePageNew(),
    ),
  ),
);

if (result == true) {
  // Refresh schedule list
  context.read<ScheduleBloc>().add(ScheduleFetch());
}
```

---

## 🧪 Testing Navigation

```dart
// Test code
void testNavigation() async {
  // 1. Tap add button
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // 2. Should show AddSchedulePageNew
  expect(find.byType(AddSchedulePageNew), findsOneWidget);

  // 3. Fill form and submit
  // ... fill fields
  await tester.tap(find.text('Buat Jadwal'));
  await tester.pumpAndSettle();

  // 4. Should return to list page
  expect(find.byType(AddSchedulePageNew), findsNothing);

  // 5. Should show success message
  expect(find.text('Jadwal berhasil dibuat!'), findsOneWidget);
}
```

---

## 📋 Checklist

Before deploying:

- [ ] Updated all AddSchedulePage references to AddSchedulePageNew
- [ ] All navigations wrap with BlocProvider.value
- [ ] Imports updated to new file
- [ ] Tested navigation flow
- [ ] Tested back button behavior
- [ ] Tested success/error scenarios
- [ ] Tested schedule list refresh after creation
- [ ] Removed old AddSchedulePage imports

---

## 🔍 Search & Replace Guide

### VS Code / IDE

1. **Find**: `AddSchedulePage\(`
2. **Replace with**: (manual - need to add BlocProvider.value wrapper)

3. **Find**: `import.*add_schedule_page\.dart`
4. **Replace with**: `import 'package:bank_sha/ui/pages/user/schedule/add_schedule_page_new.dart';`

---

## ✅ Verification

After updating, verify:

```bash
# No references to old page
grep -r "add_schedule_page.dart" lib/ | grep -v "new"

# Should return empty or only comments
```

---

## 🎉 Done!

Navigation updated successfully. Users can now:

- ✅ Navigate to new add schedule page
- ✅ Select multiple waste types
- ✅ Input weights per type
- ✅ See total weight
- ✅ Submit and return
- ✅ See success message

Happy coding! 🚀
