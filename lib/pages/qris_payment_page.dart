import 'package:flutter/material.dart';
import 'package:bank_sha/services/qris_webview_service.dart';

class QRISPaymentPage extends StatefulWidget {
  final int amount;
  final String orderId;
  final Function(bool) onPaymentComplete;

  const QRISPaymentPage({
    super.key,
    required this.amount,
    required this.orderId,
    required this.onPaymentComplete,
  });

  @override
  State<QRISPaymentPage> createState() => _QRISPaymentPageState();
}

class _QRISPaymentPageState extends State<QRISPaymentPage> {
  final QRISWebviewService _qrisService = QRISWebviewService();
  
  // Status untuk tracking proses pembayaran
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Controller untuk timer dan verifikasi pembayaran
  bool _isVerifying = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize dan load QRIS code
    _initializeQRIS();
  }
  
  Future<void> _initializeQRIS() async {
    try {
      // Inisialisasi service
      await _qrisService.initialize();
      
      // Generate QRIS code - sudah tidak menggunakan base64 string
      await _qrisService.generateQRIS(widget.amount);
      
      // Update state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }
  
  // Verifikasi pembayaran (simulasi untuk contoh)
  Future<void> _verifyPayment() async {
    if (_isVerifying) return;
    
    setState(() {
      _isVerifying = true;
    });
    
    try {
      // Di sini biasanya akan ada API call ke backend untuk verifikasi
      // Untuk contoh, kita simulasikan berhasil setelah 2 detik
      await Future.delayed(const Duration(seconds: 2));
      
      // Pembayaran berhasil
      widget.onPaymentComplete(true);
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Verifikasi pembayaran gagal: ${e.toString()}';
        _isVerifying = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRIS Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Konfirmasi pembatalan
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Batalkan Pembayaran?'),
                  content: const Text('Pembayaran yang belum selesai akan dibatalkan.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tidak'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        widget.onPaymentComplete(false); // Notify cancellation
                      },
                      child: const Text('Ya'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // Tidak perlu lagi WebView untuk QRIS generation
          
          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Payment Info Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Pembayaran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Order ID'),
                            Text(widget.orderId),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Pembayaran'),
                            Text(
                              'Rp ${widget.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.').toString()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // QRIS Code Display
                if (_isLoading)
                  Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Menghasilkan kode QRIS...'),
                    ],
                  )
                else if (_hasError)
                  Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal menghasilkan kode QRIS',
                        style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeQRIS,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _qrisService.buildQRWidget(
                              widget.amount,
                              size: 250,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Scan dengan aplikasi e-wallet atau banking',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isVerifying ? null : _verifyPayment,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: _isVerifying
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Memverifikasi Pembayaran...'),
                                ],
                              )
                            : const Text('Saya Sudah Bayar'),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 24),
                
                // Payment instructions
                if (!_isLoading && !_hasError)
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cara Pembayaran:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildInstructionStep(
                            '1',
                            'Buka aplikasi e-wallet atau mobile banking Anda',
                          ),
                          _buildInstructionStep(
                            '2',
                            'Pilih menu Scan QR atau QRIS',
                          ),
                          _buildInstructionStep(
                            '3',
                            'Scan kode QR di atas',
                          ),
                          _buildInstructionStep(
                            '4',
                            'Periksa detail transaksi dan lakukan pembayaran',
                          ),
                          _buildInstructionStep(
                            '5',
                            'Klik tombol "Saya Sudah Bayar" di atas setelah pembayaran selesai',
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}
