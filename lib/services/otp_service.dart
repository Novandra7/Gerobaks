import 'dart:async';
import 'dart:math';
import 'package:bank_sha/services/notification_service.dart';
import 'package:bank_sha/services/session_storage.dart';

class OTPService {
  static final OTPService _instance = OTPService._internal();
  factory OTPService() => _instance;
  OTPService._internal();

  final _sessionStorage = SessionStorage();
  final _notificationService = NotificationService();
  
  // Initialize the OTP service
  Future<void> initialize() async {
    // No need to initialize session storage as it's already instantiated
  }
  final _otpExpiry = const Duration(minutes: 10);
  
  // Generate a 6-digit OTP
  String generateOTP() {
    final random = Random();
    // Generate a random 6-digit number
    return (100000 + random.nextInt(900000)).toString();
  }

  // Send OTP via notification
  Future<void> sendOTP(String phoneNumber) async {
    final otp = generateOTP();
    
    // Store OTP with timestamp
    await _storeOTP(phoneNumber, otp);
    
    // Send notification with OTP
    await _notificationService.showOTPNotification(otp, phoneNumber);
    
    print('OTP sent to $phoneNumber: $otp');
    return;
  }

  // Store OTP in session storage with timestamp
  Future<void> _storeOTP(String phoneNumber, String otp) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _sessionStorage.setString('otp_$phoneNumber', otp);
    _sessionStorage.setInt('otp_timestamp_$phoneNumber', timestamp);
  }

  // Verify OTP
  Future<bool> verifyOTP(String phoneNumber, String userInputOTP) async {
    // Performa akan lebih baik karena tidak perlu await
    final storedOTP = _sessionStorage.getString('otp_$phoneNumber');
    final timestamp = _sessionStorage.getInt('otp_timestamp_$phoneNumber', defaultValue: 0);
    
    if (storedOTP == null || timestamp == 0) {
      return false;
    }
    
    // Check if OTP is expired
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final expiryTime = (timestamp ?? 0) + _otpExpiry.inMilliseconds;
    
    if (currentTime > expiryTime) {
      // OTP expired
      _clearOTP(phoneNumber);
      return false;
    }
    
    // Check if OTP matches
    if (storedOTP == userInputOTP) {
      // OTP verified, clear it
      _clearOTP(phoneNumber);
      return true;
    }
    
    return false;
  }
  
  // Clear OTP data
  void _clearOTP(String phoneNumber) {
    _sessionStorage.remove('otp_$phoneNumber');
    _sessionStorage.remove('otp_timestamp_$phoneNumber');
  }
}
