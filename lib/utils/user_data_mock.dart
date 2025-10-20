import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/services/auth_api_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'package:logger/logger.dart';

/// Class UserDataMock sekarang hanya berfungsi sebagai helper untuk
/// mendapatkan data dari API atau localStorage.
/// Tidak lagi menggunakan data hardcoded.
class UserDataMock {
<<<<<<< HEAD
  static final _logger = Logger();
  static final ApiClient _api = ApiClient();
  static final AuthApiService _authService = AuthApiService();

  // Variabel di atas tetap disimpan untuk kompatibilitas dengan kode lama
  // yang mungkin masih mereferensikannya
=======
  // Data untuk end users (pelanggan)
  static final List<Map<String, dynamic>> endUsers = [
    {
      'id': 'user_001',
      'email': 'daffa@gmail.com',
      'password': 'password123',
      'name': 'User Daffa',
      'role': 'end_user',
      'profile_picture': 'assets/img_friend1.png',
      'phone': '081234567890',
      'address': 'Jl. Merdeka No. 1, Jakarta',
      'points': 50, // Starting points
      'subscription_status': 'active',
      'created_at': '2024-01-15',
    },
    {
      'id': 'user_003',
      'email': 'ajiali@gmail.com',
      'password': '12345678',
      'name': 'Aji Ali',
      'role': 'end_user',
      'profile_picture': 'assets/img_friend1.png',
      'phone': '081234567890',
      'address': 'Jl. Sambutan No. 1, Jakarta',
      'points': 50, // Starting points
      'subscription_status': 'active',
      'created_at': '2024-01-15',
    },
    {
      'id': 'user_002',
      'email': 'sansan@gmail.com',
      'password': 'password456',
      'name': 'Jane San',
      'role': 'end_user',
      'profile_picture': 'assets/img_friend2.png',
      'phone': '087654321098',
      'address': 'Jl. Sudirman No. 2, Bandung',
      'points': 125, // Starting points
      'subscription_status': 'active',
      'created_at': '2024-02-20',
    },
    {
      'id': 'user_003',
      'email': 'wahyuh@gmail.com',
      'password': '12345678',
      'name': 'Lionel Wahyu',
      'role': 'end_user',
      'profile_picture': 'assets/img_friend3.png',
      'phone': '089876543210',
      'address': 'Jl. Thamrin No. 3, Surabaya',
      'points': 75, // Starting points
      'subscription_status': 'active',
      'created_at': '2024-03-10',
    },
  ];

  // Data untuk mitra (petugas/driver)
  static final List<Map<String, dynamic>> mitras = [
    {
      'id': 'mitra_001',
      'email': 'driver@gerobaks.com',
      'password': '12345678',
      'name': 'Ahmad Kurniawan',
      'role': 'mitra',
      'profile_picture': 'assets/img_friend4.png',
      'phone': '081345678901',
      'employee_id': 'DRV-JKT-001',
      'vehicle_type': 'Truck Sampah',
      'vehicle_plate': 'B 1234 ABC',
      'work_area': 'Jakarta Pusat',
      'status': 'active', // active, inactive, on_duty, off_duty
      'rating': 4.8,
      'total_collections': 1250,
      'created_at': '2023-06-15',
    },
    {
      'id': 'mitra_002',
      'email': 'driver.bandung@gerobaks.com',
      'password': 'mitra123',
      'name': 'Budi Santoso',
      'role': 'mitra',
      'profile_picture': 'assets/img_friend1.png',
      'phone': '081456789012',
      'employee_id': 'DRV-BDG-002',
      'vehicle_type': 'Truck Sampah',
      'vehicle_plate': 'D 5678 EFG',
      'work_area': 'Bandung Utara',
      'status': 'active',
      'rating': 4.9,
      'total_collections': 980,
      'created_at': '2023-08-20',
    },
    {
      'id': 'mitra_003',
      'email': 'supervisor.surabaya@gerobaks.com',
      'password': 'mitra123',
      'name': 'Siti Nurhaliza',
      'role': 'mitra',
      'profile_picture': 'assets/img_friend2.png',
      'phone': '081567890123',
      'employee_id': 'SPV-SBY-003',
      'vehicle_type': 'Motor Supervisor',
      'vehicle_plate': 'L 9012 HIJ',
      'work_area': 'Surabaya Timur',
      'status': 'active',
      'rating': 4.7,
      'total_collections': 750,
      'created_at': '2023-09-10',
    },
  ];
>>>>>>> 2e541a34a65c54536f2513f1cd751746eb9fc575

  // Data kosong - semua data sekarang diambil dari API
  static final List<Map<String, dynamic>> endUsers = [];
  static final List<Map<String, dynamic>> mitras = [];

  /// Semua methods di bawah ini sekarang mengakses localStorage
  /// yang sudah diisi oleh API setelah login

  /// Gabungan semua users - sekarang tidak digunakan lagi
  static List<Map<String, dynamic>> get allUsers {
    return []; // Return empty list, data sekarang dari API
  }

  /// Mendapatkan user dari localStorage (sudah diisi oleh API setelah login)
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      // Mengambil data dari localStorage
      final localStorage = await LocalStorageService.getInstance();
      final userData = await localStorage.getUserData();

      // Jika ada data dan email cocok, kembalikan data tersebut
      if (userData != null && userData['email'] == email) {
        return userData;
      }

      // Jika tidak ada di localStorage, kembalikan null
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  /// Method ini tidak digunakan lagi - data dari API
  static Map<String, dynamic>? getUserById(String id) {
    // Tidak digunakan lagi, data dari API
    return null;
  }

  /// Method ini tidak digunakan lagi - data dari API
  static List<Map<String, dynamic>> getUsersByRole(String role) {
    // Tidak digunakan lagi, data dari API
    return [];
  }

  /// Method ini tidak digunakan lagi - login via API
  static Map<String, dynamic>? validateLogin(String email, String password) {
    // Tidak digunakan lagi, login via API
    return null;
  }

  /// Method untuk mendaftarkan user melalui API
  static Future<bool> registerEndUser(Map<String, dynamic> userData) async {
    try {
<<<<<<< HEAD
      _logger.i(
        '🔐 Registrasi user via API: ${userData['name']} (${userData['email']})',
      );

      // Gunakan API untuk registrasi
      await AuthApiService().register(
        name: userData['name'],
        email: userData['email'],
        password: userData['password'],
        role: 'end_user', // Set default role
      );

      _logger.i('✅ Registrasi API berhasil');
=======
      // Check if email already exists
      if (getUserByEmail(userData['email']) != null) {
        return false; // Email already exists
      }

      // Add role and ID
      userData['role'] = 'end_user';
      userData['id'] = 'user_${DateTime.now().millisecondsSinceEpoch}';
      userData['points'] = 0;
      userData['subscription_status'] = 'inactive';
      userData['created_at'] = DateTime.now().toString().split(' ')[0];

      endUsers.add(userData);
>>>>>>> 2e541a34a65c54536f2513f1cd751746eb9fc575
      return true;
    } catch (e) {
      _logger.e('❌ Registrasi gagal: $e');
      return false;
    }
  }
}
