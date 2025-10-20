import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Script sederhana untuk menguji konfigurasi dotenv
// Jalankan dengan: dart test_env.dart

void main() async {
  print('=== GEROBAKS ENV TEST UTILITY ===');
  print('Testing dotenv configuration...');

  // Cek current directory
  final currentDir = Directory.current;
  print('Current directory: ${currentDir.path}');

  // Cek apakah file .env ada
  final envFile = File('.env');
  final envExists = await envFile.exists();
  print('.env file exists: $envExists');

  if (envExists) {
    try {
      // Baca isi file .env
      final content = await envFile.readAsString();
      print('=== .env file content ===');
      print(content);
      print('=== end of content ===');
    } catch (e) {
      print('Error reading .env file: $e');
    }
  } else {
    print('Creating .env file...');
    try {
      await envFile.writeAsString(
        '''# Alamat backend API - gunakan 10.0.2.2 untuk emulator Android
API_BASE_URL=http://10.0.2.2:8000
''',
      );
      print('.env file created successfully');
    } catch (e) {
      print('Error creating .env file: $e');
    }
  }

  // Coba load dengan dotenv
  try {
    print('Trying to load .env with dotenv...');
    await dotenv.load(fileName: '.env');
    print('dotenv loaded successfully');

    final apiUrl = dotenv.env['API_BASE_URL'];
    print('API_BASE_URL from dotenv: $apiUrl');
  } catch (e) {
    print('Error loading dotenv: $e');

    // Alternatif dengan path absolut
    try {
      final absPath = '${currentDir.path}/.env';
      print('Trying to load with absolute path: $absPath');
      await dotenv.load(fileName: absPath);
      print('dotenv loaded successfully using absolute path');

      final apiUrl = dotenv.env['API_BASE_URL'];
      print('API_BASE_URL from dotenv: $apiUrl');
    } catch (e) {
      print('Error loading dotenv with absolute path: $e');

      // Terakhir, coba gunakan testLoad
      print('Trying testLoad as fallback...');
      dotenv.env['API_BASE_URL'] = 'http://10.0.2.2:8000';
      print('API_BASE_URL set manually: ${dotenv.env['API_BASE_URL']}');
    }
  }

  print('=== TEST COMPLETED ===');
}
