import 'package:flutter/material.dart';
import 'package:bank_sha/utils/app_config.dart';

class ApiConfigDialog extends StatefulWidget {
  const ApiConfigDialog({super.key});

  @override
  State<ApiConfigDialog> createState() => _ApiConfigDialogState();
}

class _ApiConfigDialogState extends State<ApiConfigDialog> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = '';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    // Mengisi URL awal dengan URL yang sedang digunakan
    _urlController.text = AppConfig.apiBaseUrl;
  }

  Future<void> _testConnection() async {
    if (_urlController.text.isEmpty) {
      setState(() {
        _statusMessage = 'URL tidak boleh kosong';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Menguji koneksi...';
      _isSuccess = false;
    });

    try {
      // Simpan URL yang dimasukkan
      final url = _urlController.text.trim();

      // Pastikan URL diakhiri dengan slash jika belum
      final formattedUrl = url.endsWith('/')
          ? url.substring(0, url.length - 1)
          : url;

      // Atur URL API
      AppConfig.setApiBaseUrl(formattedUrl);

      setState(() {
        _statusMessage = 'URL API diubah menjadi: $formattedUrl';
        _isSuccess = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Gagal: ${e.toString()}';
        _isSuccess = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Konfigurasi API'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL API',
              hintText: 'http://10.0.2.2:8000',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          if (_statusMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: _isSuccess ? Colors.green.shade100 : Colors.red.shade100,
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: _isSuccess
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _testConnection,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}

void showApiConfigDialog(BuildContext context) {
  showDialog(context: context, builder: (context) => const ApiConfigDialog());
}
