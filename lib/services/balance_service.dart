import 'package:flutter/material.dart';
import 'package:bank_sha/services/api_client.dart';

class BalanceService {
  static const Duration _cacheDuration = Duration(minutes: 5);

  static final ApiClient _api = ApiClient();
  static DateTime? _lastFetchTime;
  static Map<String, dynamic>? _cachedSummary;

  static Future<Map<String, dynamic>> fetchUserBalance(String userId) async {
    final now = DateTime.now();
    if (_cachedSummary != null &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < _cacheDuration) {
      return {'success': true, 'isCache': true, ..._cachedSummary!};
    }

    try {
      final response = await _api.getJson(
        '/api/balance/summary',
        query: {'user_id': userId},
      );

      if (response is! Map<String, dynamic>) {
        throw Exception('Invalid balance summary response');
      }

      final summary = {
        'user_id': response['user_id'],
        'balance': _asDouble(response['balance']),
        'credit': _asDouble(response['credit']),
        'debit': _asDouble(response['debit']),
        'recent_entries': List<Map<String, dynamic>>.from(
          (response['recent_entries'] as List? ?? const []).map(
            (e) => Map<String, dynamic>.from(e as Map),
          ),
        ),
      };

      _cachedSummary = summary;
      _lastFetchTime = now;

      return {'success': true, 'isCache': false, ...summary};
    } catch (e) {
      if (_cachedSummary != null) {
        return {
          'success': true,
          'isCache': true,
          'hasError': true,
          'errorMessage': e.toString(),
          ..._cachedSummary!,
        };
      }

      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  static void clearCache() {
    _cachedSummary = null;
    _lastFetchTime = null;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  // Format balance as currency
  static String formatCurrency(double balance) {
    // Format with thousand separators
    final formatted = balance
        .toStringAsFixed(0)
        .replaceAllMapped(
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
    super.key,
    required this.userId,
    this.onTap,
    this.autoRefresh = true,
  });

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
                  Icon(Icons.refresh, size: 16, color: Colors.black45),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            Icon(Icons.error_outline, color: Colors.orange, size: 20),
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
            style: TextStyle(fontSize: 14, color: Colors.black45),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          'Ketuk untuk mencoba lagi',
          style: TextStyle(fontSize: 12, color: Colors.black38),
        ),
      ],
    );
  }

  Widget _buildBalanceDisplay() {
    final formattedBalance = BalanceService.formatCurrency(_balance);
    final lastUpdate = DateTime.now();
    final timeString =
        '${lastUpdate.hour.toString().padLeft(2, '0')}:${lastUpdate.minute.toString().padLeft(2, '0')}';

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
          style: TextStyle(fontSize: 12, color: Colors.black38),
        ),
      ],
    );
  }
}
