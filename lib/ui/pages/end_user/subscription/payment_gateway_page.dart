import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/models/subscription_model.dart';
import 'package:bank_sha/services/subscription_service.dart';
import 'package:bank_sha/ui/pages/end_user/subscription/payment_success_page.dart';

class PaymentGatewayPage extends StatefulWidget {
  final SubscriptionPlan plan;
  final bool isFromSignup;

  const PaymentGatewayPage({
    super.key,
    required this.plan,
    this.isFromSignup = false,
  });

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  PaymentMethod? _selectedPaymentMethod;
  bool _isProcessing = false;
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }
  
  Future<void> _initializeService() async {
    try {
      // Make sure service is initialized
      await _subscriptionService.initialize();
      _paymentMethods = _subscriptionService.getPaymentMethods();
    } catch (e) {
      print('Error initializing subscription service: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Jika metode pembayaran adalah QRIS, arahkan ke halaman QRIS
      if (_selectedPaymentMethod!.id == 'qris') {
        // Generate transaction ID unik
        final transactionId = 'TRX${DateTime.now().millisecondsSinceEpoch}';
        
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          
          // Arahkan ke halaman QRIS payment
          Navigator.pushNamed(
            context,
            '/qris-payment',
            arguments: {
              'amount': widget.plan.price.toInt(),
              'transactionId': transactionId,
              'description': 'Pembayaran ${widget.plan.name}',
              'returnData': {
                'plan': widget.plan,
                'paymentMethod': _selectedPaymentMethod,
                'isFromSignup': widget.isFromSignup,
              },
            },
          );
        }
        return;
      }
      
      // Untuk metode pembayaran lain, proses seperti biasa
      final subscription = await _subscriptionService.processPayment(
        widget.plan,
        _selectedPaymentMethod!,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              subscription: subscription,
              isFromSignup: widget.isFromSignup,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pembayaran gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppNotif(
        title: 'Pembayaran',
        showBackButton: true,
      ),
      backgroundColor: uicolor,
      body: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Memuat metode pembayaran...", style: TextStyle(fontSize: 16)),
              ],
            ),
          )
        : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummary(),
                    const SizedBox(height: 24),
                    _buildPaymentMethods(),
                    const SizedBox(height: 24),
                    _buildPaymentInstructions(),
                  ],
                ),
              ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pesanan',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.star,
                  color: greenColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plan.name,
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semiBold,
                      ),
                    ),
                    Text(
                      widget.plan.description,
                      style: greyTextStyle.copyWith(fontSize: 12),
                    ),
                    Text(
                      widget.plan.durationText,
                      style: greyTextStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                widget.plan.formattedPrice,
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
              Text(
                widget.plan.formattedPrice,
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: bold,
                  color: greenColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    // Group payment methods by category
    final Map<String, List<PaymentMethod>> groupedMethods = {};
    for (final method in _paymentMethods) {
      final category = method.category;
      if (!groupedMethods.containsKey(category)) {
        groupedMethods[category] = [];
      }
      groupedMethods[category]!.add(method);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Metode Pembayaran',
          style: blackTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Build sections for each category
        ...groupedMethods.entries.map((entry) {
          final category = entry.key;
          final methods = entry.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 18,
                      color: greenColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: blackTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: semiBold,
                        color: greenColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Payment methods in this category
              ...methods.map((method) => _buildPaymentMethodItem(method)),
              
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'E-Wallet':
        return Icons.account_balance_wallet;
      case 'Bank Transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  Widget _getPaymentIcon(String paymentId) {
    IconData iconData;
    Color iconColor;
    
    switch (paymentId) {
      case 'qris':
        iconData = Icons.qr_code;
        iconColor = Colors.blue[600]!;
        break;
      case 'shopeepay':
        iconData = Icons.shopping_bag;
        iconColor = Colors.orange[600]!;
        break;
      case 'dana':
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.blue[800]!;
        break;
      case 'gopay':
        iconData = Icons.motorcycle;
        iconColor = Colors.green[600]!;
        break;
      case 'ovo':
        iconData = Icons.circle;
        iconColor = Colors.purple[600]!;
        break;
      case 'bca':
        iconData = Icons.account_balance;
        iconColor = Colors.blue[700]!;
        break;
      case 'mandiri':
        iconData = Icons.account_balance;
        iconColor = Colors.yellow[700]!;
        break;
      case 'bni':
        iconData = Icons.account_balance;
        iconColor = Colors.orange[700]!;
        break;
      case 'ocbc':
        iconData = Icons.account_balance;
        iconColor = Colors.red[700]!;
        break;
      default:
        iconData = Icons.payment;
        iconColor = Colors.grey[600]!;
    }
    
    return Icon(
      iconData,
      color: iconColor,
      size: 28,
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod?.id == method.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? greenColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: method.icon.startsWith('assets/')
                    ? Image.asset(
                        method.icon,
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) => _getPaymentIcon(method.id),
                      )
                    : _getPaymentIcon(method.id),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: blackTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: medium,
                      ),
                    ),
                    Text(
                      method.description,
                      style: greyTextStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? greenColor : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: greenColor,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentInstructions() {
    if (_selectedPaymentMethod == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Instruksi Pembayaran',
                style: blackTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getPaymentInstructions(_selectedPaymentMethod!),
            style: blackTextStyle.copyWith(
              fontSize: 12,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentInstructions(PaymentMethod method) {
    switch (method.id) {
      case 'qris':
        return '1. Scan QR Code yang akan muncul setelah konfirmasi\n'
               '2. Buka aplikasi e-wallet atau mobile banking favorit Anda\n'
               '3. Scan QR Code dan konfirmasi pembayaran\n'
               '4. Pembayaran akan diverifikasi otomatis\n'
               '5. Langganan aktif dalam 1-3 menit';
      
      case 'shopeepay':
        return '1. Anda akan diarahkan ke aplikasi ShopeePay\n'
               '2. Login ke akun ShopeePay Anda\n'
               '3. Konfirmasi detail pembayaran\n'
               '4. Masukkan PIN ShopeePay\n'
               '5. Langganan akan aktif secara otomatis';
      
      case 'dana':
        return '1. Anda akan diarahkan ke aplikasi DANA\n'
               '2. Login ke akun DANA Anda\n'
               '3. Konfirmasi pembayaran dengan PIN/biometrik\n'
               '4. Langganan akan aktif dalam hitungan detik';
      
      case 'gopay':
        return '1. Anda akan diarahkan ke aplikasi Gojek\n'
               '2. Konfirmasi pembayaran dengan PIN/biometrik\n'
               '3. Langganan akan aktif secara otomatis';
      
      case 'ovo':
        return '1. Anda akan diarahkan ke aplikasi OVO\n'
               '2. Login ke akun OVO Anda\n'
               '3. Konfirmasi pembayaran dengan PIN/biometrik\n'
               '4. Langganan akan aktif secara otomatis';
      
      case 'bca':
      case 'mandiri':
      case 'bni':
      case 'ocbc':
        return '1. Setelah konfirmasi, Anda akan mendapat nomor Virtual Account\n'
               '2. Transfer sesuai nominal yang tertera\n'
               '3. Pembayaran akan diverifikasi otomatis\n'
               '4. Langganan akan aktif dalam 1-5 menit\n'
               '5. Simpan bukti transfer untuk referensi';
      
      default:
        return 'Ikuti instruksi pembayaran yang akan muncul setelah konfirmasi.';
    }
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                    ),
                  )
                : Text(
                    'Bayar Sekarang',
                    style: whiteTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
