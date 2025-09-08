import 'package:bank_sha/services/notification_service.dart';

// Function untuk memastikan notifikasi pantun aktif dan berjalan
Future<void> fixPantunNotifications() async {
  final notificationService = NotificationService();
  
  // Re-enable routine pantun notifications
  try {
    // Tampilkan pantun test untuk memicu fungsionalitas
    await notificationService.showTestRoutinePantun();
    
    print("Pantun notifications have been re-enabled");
    
    return Future.value();
  } catch (e) {
    print("Error enabling pantun notifications: $e");
    return Future.error(e);
  }
}
