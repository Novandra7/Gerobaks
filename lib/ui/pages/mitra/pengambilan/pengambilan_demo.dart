import 'package:flutter/material.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/pengambilan_page.dart';

class PengambilanDemoPage extends StatelessWidget {
  const PengambilanDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const PengambilanPage(),
    );
  }
}
