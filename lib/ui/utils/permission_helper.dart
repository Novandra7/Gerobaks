import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// Check and request location permission
  static Future<bool> checkAndRequestLocationPermission(
    BuildContext context,
  ) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) {
        return false;
      }
      // Location services are not enabled
      _showSnackBar(
        context,
        'Layanan lokasi tidak aktif. Mohon aktifkan di pengaturan perangkat Anda.',
      );
      return false;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!context.mounted) {
          return false;
        }
        // Permissions are denied
        _showSnackBar(
          context,
          'Izin lokasi ditolak. Beberapa fitur mungkin tidak berfungsi dengan baik.',
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) {
        return false;
      }
      // Permissions are permanently denied
      _showOpenSettingsDialog(
        context,
        'Izin lokasi ditolak secara permanen',
        'Silakan ubah di pengaturan perangkat Anda untuk menggunakan fitur ini.',
      );
      return false;
    }

    // Permissions are granted
    return true;
  }

  /// Check and request call phone permission
  static Future<bool> checkAndRequestCallPermission(
    BuildContext context,
  ) async {
    var status = await Permission.phone.status;

    if (status.isDenied) {
      status = await Permission.phone.request();
      if (status.isDenied) {
        if (!context.mounted) {
          return false;
        }
        _showSnackBar(
          context,
          'Izin telepon ditolak. Tidak dapat melakukan panggilan.',
        );
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      if (!context.mounted) {
        return false;
      }
      _showOpenSettingsDialog(
        context,
        'Izin telepon ditolak secara permanen',
        'Silakan ubah di pengaturan perangkat Anda untuk menggunakan fitur ini.',
      );
      return false;
    }

    return true;
  }

  /// Check and request camera permission
  static Future<bool> checkAndRequestCameraPermission(
    BuildContext context,
  ) async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
      if (status.isDenied) {
        if (!context.mounted) {
          return false;
        }
        _showSnackBar(
          context,
          'Izin kamera ditolak. Tidak dapat menggunakan kamera.',
        );
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      if (!context.mounted) {
        return false;
      }
      _showOpenSettingsDialog(
        context,
        'Izin kamera ditolak secara permanen',
        'Silakan ubah di pengaturan perangkat Anda untuk menggunakan fitur ini.',
      );
      return false;
    }

    return true;
  }

  /// Check and request microphone permission
  static Future<bool> checkAndRequestMicrophonePermission(
    BuildContext context,
  ) async {
    var status = await Permission.microphone.status;

    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isDenied) {
        if (!context.mounted) {
          return false;
        }
        _showSnackBar(
          context,
          'Izin mikrofon ditolak. Tidak dapat menggunakan mikrofon.',
        );
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      if (!context.mounted) {
        return false;
      }
      _showOpenSettingsDialog(
        context,
        'Izin mikrofon ditolak secara permanen',
        'Silakan ubah di pengaturan perangkat Anda untuk menggunakan fitur ini.',
      );
      return false;
    }

    return true;
  }

  /// Check and request storage permission
  static Future<bool> checkAndRequestStoragePermission(
    BuildContext context,
  ) async {
    Permission storagePermission;

    // For Android 13 and above (SDK 33+), use granular media permissions
    if (await _isAndroid13OrHigher()) {
      var photos = await Permission.photos.status;

      if (photos.isDenied) {
        photos = await Permission.photos.request();
        if (photos.isDenied) {
          if (!context.mounted) {
            return false;
          }
          _showSnackBar(
            context,
            'Izin akses media ditolak. Tidak dapat mengakses media.',
          );
          return false;
        }
      }

      if (photos.isPermanentlyDenied) {
        if (!context.mounted) {
          return false;
        }
        _showOpenSettingsDialog(
          context,
          'Izin akses media ditolak secara permanen',
          'Silakan ubah di pengaturan perangkat Anda untuk menggunakan fitur ini.',
        );
        return false;
      }

      return true;
    }
    // For Android 12 and below
    else {
      storagePermission = Permission.storage;
      var status = await storagePermission.status;

      if (status.isDenied) {
        status = await storagePermission.request();
        if (status.isDenied) {
          if (!context.mounted) {
            return false;
          }
          _showSnackBar(
            context,
            'Izin penyimpanan ditolak. Tidak dapat mengakses penyimpanan.',
          );
          return false;
        }
      }

      if (status.isPermanentlyDenied) {
        if (!context.mounted) {
          return false;
        }
        _showOpenSettingsDialog(
          context,
          'Izin penyimpanan ditolak secara permanen',
          'Silakan ubah di pengaturan perangkat Anda untuk menggunakan fitur ini.',
        );
        return false;
      }

      return true;
    }
  }

  /// Check and request notification permission
  static Future<bool> checkAndRequestNotificationPermission(
    BuildContext context,
  ) async {
    var status = await Permission.notification.status;

    if (status.isDenied) {
      status = await Permission.notification.request();
      if (status.isDenied) {
        if (!context.mounted) {
          return false;
        }
        _showSnackBar(
          context,
          'Izin notifikasi ditolak. Anda tidak akan menerima notifikasi.',
        );
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      if (!context.mounted) {
        return false;
      }
      _showOpenSettingsDialog(
        context,
        'Izin notifikasi ditolak secara permanen',
        'Silakan ubah di pengaturan perangkat Anda untuk menerima notifikasi.',
      );
      return false;
    }

    return true;
  }

  /// Check if the device is running Android 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    return await Permission.photos.status.isGranted ||
        await Permission.photos.status.isDenied;
  }

  /// Show a snackbar with a message
  static void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  /// Show a dialog to open app settings
  static Future<void> _showOpenSettingsDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    if (!context.mounted) {
      return;
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(message)]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Buka Pengaturan'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
