import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class BalanceService {
  // Base URL for the API
  static const String baseUrl = 'https://example.com';
  
  // Cache time in milliseconds (5 minutes)
  static const int cacheTime = 300000;
  
  // Last fetch time and cached balance
  static int? _lastFetchTime;
  static double? _cachedBalance;

  // Fetch balance for user
  static Future<Map<String, dynamic>> fetchUserBalance(String userId) async {
    try {
      // Check if cache is valid
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      if (_cachedBalance != null && 
          _lastFetchTime != null && 
          currentTime - _lastFetchTime! < cacheTime) {
        // Return cached data
        return {
          'success': true,
          'balance': _cachedBalance,
          'isCache': true,
        };
      }
      
      // Make API call
      final response = await http.get(
        Uri.parse('$baseUrl/saldo/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Update cache
        _cachedBalance = data['balance'] is int 
            ? (data['balance'] as int).toDouble() 
            : data['balance'];
        _lastFetchTime = currentTime;
        
        return {
          'success': true,
          'balance': _cachedBalance,
          'isCache': false,
        };
      } else {
        // Return error from server
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      // If we have cached data, return it with error flag
      if (_cachedBalance != null) {
        return {
          'success': true,
          'balance': _cachedBalance,
          'isCache': true,
          'hasError': true,
          'errorMessage': e.toString(),
        };
      }
      
      // Otherwise return error
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }
  
  // Clear the balance cache to force refresh
  static void clearCache() {
    _cachedBalance = null;
    _lastFetchTime = null;
  }
  
  // Format balance as currency
  static String formatCurrency(double balance) {
    // Format with thousand separators
    final formatted = balance.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    
    return 'Rp $formatted';
  }
}

class BalanceCard extends StatefulWidget {
  final String userId;
  final VoidCallback? onTap;
  final bool autoRefresh;
  
  const BalanceCard({
    Key? key,
    required this.userId,
    this.onTap,
    this.autoRefresh = true,
  }) : super(key: key);

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isLoading = true;
  bool _hasError = false;
  double _balance = 0;
  bool _isRefreshing = false;
  
  @override
  void initState() {
    super.initState();
    _loadBalance();
    
    // Set up auto refresh if enabled
    if (widget.autoRefresh) {
      // Refresh every 5 minutes
      Future.delayed(const Duration(minutes: 5), () {
        if (mounted) {
          _refreshBalance();
        }
      });
    }
  }
  
  Future<void> _loadBalance() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    final result = await BalanceService.fetchUserBalance(widget.userId);
    
    if (!mounted) return;
    
    if (result['success']) {
      setState(() {
        _balance = result['balance'];
        _isLoading = false;
        _hasError = result['hasError'] ?? false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }
  
  Future<void> _refreshBalance() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    // Clear cache to force refresh
    BalanceService.clearCache();
    await _loadBalance();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          _refreshBalance();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saldo Anda',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                if (_isRefreshing)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.refresh,
                    size: 16,
                    color: Colors.black45,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoading
                ? _buildLoadingIndicator()
                : _hasError
                    ? _buildErrorState()
                    : _buildBalanceDisplay(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Memuat saldo...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Gagal memuat saldo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        if (_balance > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Saldo terakhir: ${BalanceService.formatCurrency(_balance)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black45,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          'Ketuk untuk mencoba lagi',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black38,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBalanceDisplay() {
    final formattedBalance = BalanceService.formatCurrency(_balance);
    final lastUpdate = DateTime.now();
    final timeString = '${lastUpdate.hour.toString().padLeft(2, '0')}:${lastUpdate.minute.toString().padLeft(2, '0')}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedBalance,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Terakhir diperbarui: $timeString',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black38,
          ),
        ),
      ],
    );
  }
}
