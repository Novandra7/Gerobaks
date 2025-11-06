# 🎯 MVP END_USER TESTING GUIDE

**Gerobaks Mobile App - Production API Integration**

## ✅ Status: READY FOR TESTING

Date: October 20, 2025  
Version: MVP v1.0  
Backend API: https://gerobaks.dumeg.com

---

## 📋 Pre-Test Checklist

### Dependencies Installed ✅

- [x] flutter_bloc: ^9.1.1
- [x] equatable: ^2.0.7
- [x] All 170 packages installed successfully

### BLoC Architecture Integrated ✅

- [x] AuthBloc - Login, Register, Logout, Check Status
- [x] BalanceBloc - Balance summary, Ledger, Top-up
- [x] NotificationBloc - Fetch, Mark as read
- [x] ProfileBloc - View, Update, Change password
- [x] TrackingBloc - Map tracking (existing)
- [x] ScheduleBloc - Schedule management (existing)
- [x] WilayahBloc - Region management (existing)

### Files Created ✅

- [x] lib/ui/pages/auth_wrapper.dart - Role-based routing
- [x] lib/blocs/blocs.dart - Central BLoC exports
- [x] All BLoC files (4 new modules, 12 files total)

### Main.dart Configuration ✅

- [x] MultiBlocProvider with 7 BLoCs
- [x] Production API URL configured
- [x] Auth status check on app start

---

## 🧪 TEST SCENARIOS

### Test 1: Clean Install & First Launch

**Goal**: Verify splash screen and onboarding flow

**Steps**:

1. Uninstall app if previously installed: `flutter clean`
2. Run app: `flutter run --verbose`
3. Observe splash screen animation (3 seconds)
4. Should navigate to: `/onboarding`

**Expected Result**:

- ✅ Splash screen displays correctly
- ✅ No auto-login occurs
- ✅ Onboarding page appears

---

### Test 2: User Registration (Optional)

**Goal**: Test register flow with production API

**Test Credentials**:

- Name: Test User MVP
- Email: testmvp@example.com
- Password: password123
- Role: end_user (default)

**Steps**:

1. From onboarding, click "Daftar"
2. Fill registration form
3. Submit registration
4. Observe network call and response

**Expected Result**:

- ✅ API call to `/api/register`
- ✅ Token received and stored
- ✅ AuthBloc state → authenticated
- ✅ Navigate to HomePage

**Alternative**: Skip to Test 3 with existing user

---

### Test 3: 🔥 PRIMARY TEST - Login with Production User

**Goal**: Test complete login flow with BLoC

**Test Credentials**:

```
Email: daffa@gmail.com
Password: password
Role: end_user
```

**Steps**:

1. From onboarding/sign-in page, enter credentials
2. Click "Sign In" / "Masuk"
3. **Observe console logs**:
   ```
   🔐 AuthBloc: Starting login for daffa@gmail.com
   ✅ AuthBloc: Login successful
   User role: end_user
   ```
4. Observe navigation to HomePage

**Expected Result**:

- ✅ API call: POST https://gerobaks.dumeg.com/api/login
- ✅ Token stored in SharedPreferences
- ✅ AuthBloc emits: AuthState.authenticated
- ✅ User data contains: name, email, role: 'end_user'
- ✅ Navigate to: `/home` (HomePage)
- ✅ No errors or exceptions

**How to Verify**:

```dart
// Check console for these logs:
🔐 AuthBloc: Starting login for daffa@gmail.com
✅ AuthBloc: Login successful
Response data: {token: ..., user: {id: 1, name: Daffa, email: daffa@gmail.com, role: end_user}}
✅ AuthBloc: Token and user data found
User role: end_user
```

---

### Test 4: HomePage Balance Display

**Goal**: Verify BalanceBloc fetches and displays data

**Steps**:

1. After successful login, on HomePage
2. **Check balance widget** (should show points)
3. **Check console logs**:
   ```
   BalanceBloc: Fetching balance summary
   BalanceBloc: Balance loaded - Current: XXX
   ```

**Expected Result**:

- ✅ API call: GET /api/balance/summary
- ✅ BalanceBloc emits: BalanceState.loaded
- ✅ Balance displayed correctly
- ✅ No "Loading..." stuck state

**Manual Trigger (if auto-load not implemented)**:

```dart
// In HomePage, trigger fetch:
context.read<BalanceBloc>().add(FetchBalanceSummary());
```

---

### Test 5: Notifications List

**Goal**: Test NotificationBloc fetch and display

**Steps**:

1. Navigate to Notifications page (`/notif`)
2. Observe loading state
3. **Check console logs**:
   ```
   NotificationBloc: Fetching notifications (page 1)
   NotificationBloc: Loaded X notifications
   ```

**Expected Result**:

- ✅ API call: GET /api/notifications?page=1
- ✅ NotificationBloc emits: NotificationState.loaded
- ✅ Notification list displays
- ✅ Unread count badge shows correct number

---

### Test 6: Profile View

**Goal**: Test ProfileBloc fetch user data

**Steps**:

1. Navigate to Profile page
2. Observe user data loading
3. **Check console logs**:
   ```
   ProfileBloc: Fetching user profile
   ProfileBloc: Profile loaded - Daffa
   ```

**Expected Result**:

- ✅ API call: GET /api/auth/me
- ✅ ProfileBloc emits: ProfileState.loaded
- ✅ User name: "Daffa"
- ✅ User email: "daffa@gmail.com"
- ✅ User role: "end_user"

---

### Test 7: Logout & Session Management

**Goal**: Test logout flow

**Steps**:

1. From Profile, click Logout
2. **Observe console logs**:
   ```
   AuthBloc: Logout requested
   AuthBloc: Calling API logout
   AuthBloc: Logout successful, clearing token
   ```
3. Observe navigation back to login

**Expected Result**:

- ✅ API call: POST /api/auth/logout
- ✅ Token cleared from SharedPreferences
- ✅ AuthBloc emits: AuthState.unauthenticated
- ✅ Navigate to: SignInPage
- ✅ No user data remains

---

### Test 8: 🔥 Auto-Login on App Restart

**Goal**: Test persistent authentication

**Steps**:

1. Login with daffa@gmail.com (Test 3)
2. **Close app completely** (kill process)
3. **Reopen app**
4. Observe SplashPage behavior
5. **Check console logs**:
   ```
   🚀 [SPLASH] Attempting auto-login from splash page
   🚀 [SPLASH] Auto-login successful with role: end_user
   🚀 [SPLASH] Navigating to home page
   ```

**Expected Result**:

- ✅ SplashPage appears (3 sec)
- ✅ Token loaded from SharedPreferences
- ✅ AuthBloc state → authenticated (from stored token)
- ✅ **Direct navigation to HomePage** (no login screen)
- ✅ User data persists

---

### Test 9: Error Handling - Wrong Password

**Goal**: Test error state management

**Test Data**:

```
Email: daffa@gmail.com
Password: wrongpassword123
```

**Steps**:

1. Enter wrong password
2. Click Sign In
3. Observe error message

**Expected Result**:

- ✅ API returns 401 Unauthorized
- ✅ AuthBloc emits: AuthState.error('Invalid credentials')
- ✅ Error message displays on UI
- ✅ No navigation occurs
- ✅ User can retry

---

### Test 10: Network Error Handling

**Goal**: Test offline/network error scenarios

**Steps**:

1. **Disable internet connection**
2. Try to login
3. Observe error handling

**Expected Result**:

- ✅ AuthBloc catches exception
- ✅ Error message: "Network error" or similar
- ✅ No app crash
- ✅ User can retry when online

---

## 🔍 Console Log Patterns to Watch

### ✅ Successful Login Flow:

```
🔐 AuthBloc: Starting login for daffa@gmail.com
✅ AuthBloc: Login successful
Response data: {token: eyJ..., user: {...}}
✅ AuthBloc: Token and user data found
User role: end_user
```

### ✅ Successful Auto-Login:

```
🔄 AuthWrapper: Current auth status - loading
🚀 [SPLASH] Attempting auto-login from splash page
🚀 [SPLASH] Auto-login successful with role: end_user
✅ AuthWrapper: User authenticated with role: end_user
```

### ❌ Error Patterns:

```
❌ AuthBloc: Login failed - [error message]
❌ AuthBloc: Token or user data missing
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "Token not found" on auto-login

**Solution**: Logout completely, login again to store fresh token

### Issue 2: BLoC state not updating UI

**Solution**: Ensure BlocBuilder is used in widgets:

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state.status == AuthStatus.loading) {
      return CircularProgressIndicator();
    }
    // ... rest of UI
  },
)
```

### Issue 3: Multiple simultaneous API calls

**Solution**: This is expected! BLoCs fetch data independently.

### Issue 4: "Invalid credentials" with correct password

**Solution**: Check API URL in app_config.dart:

```dart
static const String DEFAULT_API_URL = 'https://gerobaks.dumeg.com';
```

---

## 📊 Success Criteria for MVP

### ✅ Must Pass (Critical):

- [ ] Login with daffa@gmail.com works
- [ ] HomePage loads with user data
- [ ] Auto-login works on app restart
- [ ] Logout clears session correctly
- [ ] No crashes or unhandled exceptions

### ✅ Should Pass (Important):

- [ ] Balance displays correctly
- [ ] Notifications load
- [ ] Profile data shows
- [ ] Error messages display properly

### ⚠️ Nice to Have (Optional):

- [ ] Loading states smooth
- [ ] Pull-to-refresh works
- [ ] Pagination on lists

---

## 🚀 Testing Commands

### Clean and Run:

```powershell
flutter clean
flutter pub get
flutter run --verbose
```

### Check Logs Only:

```powershell
flutter logs | Select-String "AuthBloc|BalanceBloc|NotificationBloc"
```

### Build for Production Test:

```powershell
flutter build apk --release
```

---

## 📝 Test Report Template

After testing, fill this out:

```
=== MVP TEST REPORT ===
Date: [Date]
Tester: [Name]

Test 3 - Login: ✅ PASS / ❌ FAIL
Notes: _______________________________

Test 4 - Balance: ✅ PASS / ❌ FAIL
Notes: _______________________________

Test 8 - Auto-Login: ✅ PASS / ❌ FAIL
Notes: _______________________________

Other issues: _______________________________

Overall: ✅ MVP READY / ❌ NEEDS FIX
```

---

## 🆘 Need Help?

Check these files for reference:

- `MVP_END_USER_IMPLEMENTATION_GUIDE.md` - Complete BLoC usage guide
- `QUICK_SUMMARY_MVP.md` - Quick reference
- `IMPLEMENTATION_COMPLETE.md` - What's done and next steps

**API Documentation**: All endpoints documented in `MVP_END_USER_IMPLEMENTATION_GUIDE.md`

---

## ✅ READY TO TEST!

Start with **Test 3** (Login) - this is the most critical test for MVP.

Good luck! 🚀
