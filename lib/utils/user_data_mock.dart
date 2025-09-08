class UserDataMock {
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
      'password': 'password789',
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
      'email': 'driver.jakarta@gerobaks.com',
      'password': 'mitra123',
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

  // Gabungan semua users untuk keperluan login
  static List<Map<String, dynamic>> get allUsers {
    return [...endUsers, ...mitras];
  }

  // Method untuk mendapatkan user berdasarkan email (untuk login)
  static Map<String, dynamic>? getUserByEmail(String email) {
    try {
      return allUsers.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }

  // Method untuk mendapatkan user berdasarkan ID
  static Map<String, dynamic>? getUserById(String id) {
    try {
      return allUsers.firstWhere((user) => user['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Method untuk mendapatkan users berdasarkan role
  static List<Map<String, dynamic>> getUsersByRole(String role) {
    return allUsers.where((user) => user['role'] == role).toList();
  }

  // Method untuk validasi login
  static Map<String, dynamic>? validateLogin(String email, String password) {
    final user = getUserByEmail(email);
    if (user != null && user['password'] == password) {
      return user;
    }
    return null;
  }

  // Method untuk registrasi end user baru
  static bool registerEndUser(Map<String, dynamic> userData) {
    try {
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
      return true;
    } catch (e) {
      return false;
    }
  }
}
