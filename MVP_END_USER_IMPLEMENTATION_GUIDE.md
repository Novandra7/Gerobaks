# 🚀 Mobile App MVP - End User Integration Guide

## 📋 Overview

Implementasi Backend API ke Mobile App dengan fokus pada **MVP (Minimum Viable Product)** untuk role **end_user** menggunakan **BLoC Pattern**.

### ✅ Perubahan Yang Sudah Dilakukan

1. **✓ Update API Configuration ke Production**

   - File: `lib/utils/app_config.dart`
   - Default API URL: `https://gerobaks.dumeg.com`
   - Previous: `http://localhost:8000`

2. **✓ Membuat BLoC Architecture untuk End User**

   - Auth BLoC (Login, Register, Logout)
   - Balance BLoC (Summary, Ledger, Top-up)
   - Notification BLoC (List, Mark as Read)
   - Profile BLoC (View, Update, Upload Image, Change Password)
   - Tracking BLoC (sudah ada)
   - Schedule BLoC (sudah ada)

3. **✓ Install Dependencies**
   - `equatable: ^2.0.5` - Untuk memudahkan state comparison

---

## 📁 Struktur BLoC yang Sudah Dibuat

```
lib/blocs/
├── auth/
│   ├── auth_bloc.dart          ✅ Complete
│   ├── auth_event.dart         ✅ Complete
│   └── auth_state.dart         ✅ Complete
├── balance/
│   ├── balance_bloc.dart       ✅ Complete
│   ├── balance_event.dart      ✅ Complete
│   └── balance_state.dart      ✅ Complete
├── notification/
│   ├── notification_bloc.dart  ✅ Complete
│   ├── notification_event.dart ✅ Complete
│   └── notification_state.dart ✅ Complete
├── profile/
│   ├── profile_bloc.dart       ✅ Complete
│   ├── profile_event.dart      ✅ Complete
│   └── profile_state.dart      ✅ Complete
├── tracking/
│   ├── tracking_bloc.dart      ✅ Existing
│   ├── tracking_event.dart     ✅ Existing
│   └── tracking_state.dart     ✅ Existing
└── schedule/
    ├── schedule_bloc.dart      ✅ Existing
    ├── schedule_event.dart     ✅ Existing
    └── schedule_state.dart     ✅ Existing
```

---

## 🔐 1. Authentication BLoC

### Features:

- ✅ Login
- ✅ Register (default role: end_user)
- ✅ Logout
- ✅ Check Auth Status
- ✅ Update User Profile in State

### Usage Example:

```dart
// Login
context.read<AuthBloc>().add(
  LoginRequested(
    email: 'daffa@gmail.com',
    password: 'password',
  ),
);

// Register
context.read<AuthBloc>().add(
  RegisterRequested(
    name: 'John Doe',
    email: 'john@example.com',
    password: 'password',
    role: 'end_user',
  ),
);

// Check Auth Status
context.read<AuthBloc>().add(const CheckAuthStatus());

// Logout
context.read<AuthBloc>().add(const LogoutRequested());
```

### State Handling:

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state.status == AuthStatus.loading) {
      return CircularProgressIndicator();
    }

    if (state.status == AuthStatus.authenticated) {
      // Navigate to home
      return HomePage();
    }

    if (state.status == AuthStatus.error) {
      // Show error
      return Text(state.errorMessage ?? 'Error');
    }

    return LoginPage();
  },
)
```

---

## 💰 2. Balance BLoC

### Features:

- ✅ Fetch Balance Summary
- ✅ Fetch Balance Ledger (with pagination)
- ✅ Top-up Balance
- ✅ Refresh Balance

### Usage Example:

```dart
// Fetch Balance Summary
context.read<BalanceBloc>().add(const FetchBalanceSummary());

// Fetch Balance Ledger (page 1)
context.read<BalanceBloc>().add(const FetchBalanceLedger(page: 1));

// Load more transactions (pagination)
context.read<BalanceBloc>().add(FetchBalanceLedger(page: 2));

// Top-up Balance
context.read<BalanceBloc>().add(
  TopUpBalance(
    amount: 100000.0,
    paymentMethod: 'qris',
  ),
);

// Refresh Balance
context.read<BalanceBloc>().add(const RefreshBalance());
```

### State Handling:

```dart
BlocBuilder<BalanceBloc, BalanceState>(
  builder: (context, state) {
    if (state.status == BalanceStatus.loading) {
      return CircularProgressIndicator();
    }

    if (state.status == BalanceStatus.loaded) {
      return Column(
        children: [
          Text('Balance: Rp ${state.currentBalance}'),
          Text('Pending: Rp ${state.pendingBalance}'),

          // Ledger transactions
          ListView.builder(
            itemCount: state.ledgerTransactions?.length ?? 0,
            itemBuilder: (context, index) {
              final transaction = state.ledgerTransactions![index];
              return ListTile(
                title: Text(transaction['description']),
                subtitle: Text(transaction['created_at']),
                trailing: Text('Rp ${transaction['amount']}'),
              );
            },
          ),
        ],
      );
    }

    return Container();
  },
)
```

---

## 🔔 3. Notification BLoC

### Features:

- ✅ Fetch Notifications (with pagination)
- ✅ Mark Notification as Read
- ✅ Mark All Notifications as Read
- ✅ Refresh Notifications

### Usage Example:

```dart
// Fetch Notifications (page 1)
context.read<NotificationBloc>().add(const FetchNotifications(page: 1));

// Load more notifications (pagination)
context.read<NotificationBloc>().add(FetchNotifications(page: 2));

// Mark notification as read
context.read<NotificationBloc>().add(MarkNotificationAsRead(123));

// Mark all as read
context.read<NotificationBloc>().add(const MarkAllNotificationsAsRead());

// Refresh
context.read<NotificationBloc>().add(const RefreshNotifications());
```

### State Handling:

```dart
BlocBuilder<NotificationBloc, NotificationState>(
  builder: (context, state) {
    if (state.status == NotificationStatus.loaded) {
      return Column(
        children: [
          // Unread count badge
          Badge(
            label: Text('${state.unreadCount}'),
            child: Icon(Icons.notifications),
          ),

          // Notification list
          ListView.builder(
            itemCount: state.notifications?.length ?? 0,
            itemBuilder: (context, index) {
              final notification = state.notifications![index];
              final isRead = notification['read_at'] != null;

              return ListTile(
                title: Text(notification['title']),
                subtitle: Text(notification['message']),
                tileColor: isRead ? null : Colors.blue[50],
                onTap: () {
                  context.read<NotificationBloc>().add(
                    MarkNotificationAsRead(notification['id']),
                  );
                },
              );
            },
          ),
        ],
      );
    }

    return Container();
  },
)
```

---

## 👤 4. Profile BLoC

### Features:

- ✅ Fetch User Profile
- ✅ Update Profile
- ✅ Upload Profile Image
- ✅ Change Password
- ✅ Refresh Profile

### Usage Example:

```dart
// Fetch Profile
context.read<ProfileBloc>().add(const FetchUserProfile());

// Update Profile
context.read<ProfileBloc>().add(
  UpdateProfile(
    name: 'New Name',
    email: 'newemail@example.com',
    phone: '08123456789',
    address: 'New Address',
  ),
);

// Upload Profile Image
context.read<ProfileBloc>().add(
  UploadProfileImage('/path/to/image.jpg'),
);

// Change Password
context.read<ProfileBloc>().add(
  ChangePassword(
    currentPassword: 'oldpass',
    newPassword: 'newpass',
    confirmPassword: 'newpass',
  ),
);

// Refresh
context.read<ProfileBloc>().add(const RefreshProfile());
```

### State Handling:

```dart
BlocBuilder<ProfileBloc, ProfileState>(
  builder: (context, state) {
    if (state.status == ProfileStatus.loaded) {
      return Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(state.userAvatar ?? ''),
          ),
          Text(state.userName ?? ''),
          Text(state.userEmail ?? ''),
          Text(state.userPhone ?? ''),
        ],
      );
    }

    if (state.status == ProfileStatus.updated) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.successMessage ?? 'Updated')),
      );
      return ProfileView(user: state.userData);
    }

    return Container();
  },
)
```

---

## 📱 Next Steps - Implementation Plan

### Phase 1: Setup BLoC Providers (Priority: 🔴 HIGH)

1. **Update `main.dart` dengan MultiBlocProvider**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(const CheckAuthStatus())),
        BlocProvider(create: (_) => BalanceBloc()),
        BlocProvider(create: (_) => NotificationBloc()),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => TrackingBloc()),
        BlocProvider(create: (_) => ScheduleBloc()),
      ],
      child: MyApp(),
    ),
  );
}
```

### Phase 2: Create End User Pages (Priority: 🔴 HIGH)

1. **Authentication Pages**

   - `lib/ui/pages/auth/login_page.dart`
   - `lib/ui/pages/auth/register_page.dart`

2. **Dashboard Page**

   - `lib/ui/pages/end_user/dashboard_page.dart`
   - Shows: Balance summary, recent tracking, notifications

3. **Balance Pages**

   - `lib/ui/pages/end_user/balance/balance_page.dart`
   - `lib/ui/pages/end_user/balance/topup_page.dart`
   - `lib/ui/pages/end_user/balance/ledger_page.dart`

4. **Notification Pages**

   - `lib/ui/pages/end_user/notification/notification_list_page.dart`

5. **Profile Pages**

   - `lib/ui/pages/end_user/profile/profile_page.dart`
   - `lib/ui/pages/end_user/profile/edit_profile_page.dart`
   - `lib/ui/pages/end_user/profile/change_password_page.dart`

6. **Tracking Pages**

   - `lib/ui/pages/end_user/tracking/tracking_list_page.dart`
   - `lib/ui/pages/end_user/tracking/tracking_detail_page.dart`

7. **Schedule Pages**
   - `lib/ui/pages/end_user/schedule/schedule_list_page.dart`
   - `lib/ui/pages/end_user/schedule/create_schedule_page.dart`

### Phase 3: Test with Production API (Priority: 🟡 MEDIUM)

1. **Test User Credentials**

   - Email: `daffa@gmail.com`
   - Password: `password`
   - Role: `end_user`

2. **Test Flow**
   - ✅ Login → Dashboard
   - ✅ View Balance → Top-up → View Ledger
   - ✅ View Notifications → Mark as Read
   - ✅ View Profile → Update → Change Password
   - ✅ View Tracking → Create Tracking
   - ✅ View Schedule → Create Schedule

### Phase 4: Error Handling & UX (Priority: 🟢 LOW)

1. **Error States**

   - Network errors
   - Validation errors
   - Server errors

2. **Loading States**

   - Shimmer loading
   - Pull-to-refresh
   - Infinite scroll

3. **Success States**
   - Toast messages
   - Snackbars
   - Navigation

---

## 🔑 API Endpoints Documentation

### Authentication

- `POST /api/login` - Login
- `POST /api/register` - Register
- `POST /api/auth/logout` - Logout
- `GET /api/auth/me` - Get current user

### Balance

- `GET /api/balance/summary` - Get balance summary
- `GET /api/balance/ledger` - Get transaction history
- `POST /api/balance/topup` - Top-up balance

### Notifications

- `GET /api/notifications` - Get notifications
- `POST /api/notifications/mark-read` - Mark as read (all unread)

### Profile

- `GET /api/auth/me` - Get user profile
- `POST /api/user/update-profile` - Update profile
- `POST /api/user/upload-profile-image` - Upload image
- `POST /api/user/change-password` - Change password

### Tracking

- `GET /api/trackings` - Get tracking list
- `POST /api/trackings` - Create tracking

### Schedules

- `GET /api/schedules` - Get schedule list
- `POST /api/schedules` - Create schedule

---

## 🧪 Testing Guide

### Manual Testing Steps:

1. **Install Dependencies**

   ```bash
   flutter pub get
   ```

2. **Check API Configuration**

   - Verify `lib/utils/app_config.dart`
   - DEFAULT_API_URL should be `https://gerobaks.dumeg.com`

3. **Run App**

   ```bash
   flutter run --verbose
   ```

4. **Test Authentication**

   - Login with test credentials
   - Check token storage in SharedPreferences
   - Verify user data in state

5. **Test Features**
   - Balance: Fetch summary, ledger, top-up
   - Notifications: List, mark as read
   - Profile: View, update, change password
   - Tracking: List, create
   - Schedule: List, create

---

## 📝 Notes

1. **Production API**: `https://gerobaks.dumeg.com`
2. **Test User**: `daffa@gmail.com` / `password`
3. **Backend Status**: ✅ 25 endpoints ready (100%)
4. **Database**: SQLite (development) / MySQL (production)
5. **Authentication**: Laravel Sanctum (Bearer Token)

---

## ⚠️ Important Reminders

1. **BLoC Pattern**

   - Always use `context.read<>()` for events
   - Use `BlocBuilder` for state updates
   - Use `BlocListener` for side effects (navigation, snackbar)
   - Use `BlocConsumer` for both

2. **Error Handling**

   - Wrap API calls in try-catch
   - Show user-friendly error messages
   - Log errors for debugging

3. **State Management**

   - Don't mutate state directly
   - Use `copyWith()` for state updates
   - Use `Equatable` for comparison

4. **Performance**
   - Implement pagination for lists
   - Use pull-to-refresh
   - Cache data when appropriate

---

## 🚀 Ready to Implement!

Semua BLoC sudah siap. Tinggal:

1. ✅ Update `main.dart` dengan MultiBlocProvider
2. ✅ Buat UI Pages
3. ✅ Integrasikan BLoC dengan UI
4. ✅ Test dengan production API

**Status**: 🟢 READY FOR MVP IMPLEMENTATION
