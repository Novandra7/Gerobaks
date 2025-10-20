import 'package:flutter/material.dart';
import 'package:bank_sha/utils/app_config.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:http/http.dart' as http;

class HiddenSettingsPage extends StatefulWidget {
  const HiddenSettingsPage({super.key});

  @override
  State<HiddenSettingsPage> createState() => _HiddenSettingsPageState();
}

class _HiddenSettingsPageState extends State<HiddenSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isLoading = false;
  bool _isTestingConnection = false;
  String _connectionStatus = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  void _loadCurrentUrl() {
    _urlController.text = AppConfig.apiBaseUrl;
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTestingConnection = true;
      _connectionStatus = '';
    });

    try {
      final testUrl = _urlController.text.trim();

      // Test connection to the API ping endpoint
      final response = await http
          .get(
            Uri.parse('$testUrl/api/ping'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _connectionStatus = '✅ Koneksi berhasil!';
        });
      } else {
        setState(() {
          _connectionStatus =
              '❌ Server merespons dengan status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = '❌ Koneksi gagal: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  Future<void> _saveUrl() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newUrl = _urlController.text.trim();
      await AppConfig.setApiBaseUrl(newUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ URL API berhasil disimpan: $newUrl'),
          backgroundColor: Colors.green,
        ),
      );

      // Optional: Navigate back or restart app
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal menyimpan URL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetToDefault() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AppConfig.resetApiBaseUrl();
      _urlController.text = AppConfig.DEFAULT_API_URL;

      setState(() {
        _connectionStatus = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ URL API direset ke default'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal reset URL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Pengaturan Developer'),
        backgroundColor: greenColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.api, color: greenColor),
                          const SizedBox(width: 8),
                          Text(
                            'Konfigurasi API',
                            style: blackTextStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: 'Base URL API',
                          hintText: 'http://10.0.2.2:8000',
                          prefixIcon: const Icon(Icons.link),
                          border: const OutlineInputBorder(),
                          helperText: 'Masukkan URL lengkap tanpa /api',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'URL tidak boleh kosong';
                          }
                          if (!value.startsWith('http')) {
                            return 'URL harus dimulai dengan http:// atau https://';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isTestingConnection
                                  ? null
                                  : _testConnection,
                              icon: _isTestingConnection
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.wifi_find),
                              label: Text(
                                _isTestingConnection
                                    ? 'Testing...'
                                    : 'Test Koneksi',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_connectionStatus.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _connectionStatus.startsWith('✅')
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _connectionStatus.startsWith('✅')
                                  ? Colors.green
                                  : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _connectionStatus,
                            style: TextStyle(
                              color: _connectionStatus.startsWith('✅')
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi',
                            style: blackTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• URL saat ini: ${AppConfig.apiBaseUrl}',
                        style: greyTextStyle.copyWith(fontSize: 14),
                      ),
                      Text(
                        '• Status: ${AppConfig.isUsingCustomApiUrl ? "Custom URL" : "Default URL"}',
                        style: greyTextStyle.copyWith(fontSize: 14),
                      ),
                      Text(
                        '• Default URL: ${AppConfig.DEFAULT_API_URL}',
                        style: greyTextStyle.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveUrl,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isLoading ? 'Menyimpan...' : 'Simpan URL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _resetToDefault,
                      icon: const Icon(Icons.restore),
                      label: const Text('Reset ke Default'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
