import 'package:flutter/material.dart';

/// Global RouteObserver untuk tracking navigasi halaman
/// Digunakan untuk mendeteksi kapan user kembali ke halaman tertentu
/// setelah navigasi ke halaman lain
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
