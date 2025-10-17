import 'package:bank_sha/services/api_client.dart';

/// Complete Balance Service - Wallet Management
///
/// Features:
/// - Get balance (GET /api/balance)
/// - Top-up balance (POST /api/balance/topup)
/// - Withdraw balance (POST /api/balance/withdraw)
/// - Get balance ledger/history (GET /api/balance/ledger)
/// - Get balance summary (GET /api/balance/summary)
/// - Check sufficient balance
/// - Get available top-up methods
///
/// Use Cases:
/// - User checks wallet balance
/// - User tops up balance for orders
/// - Mitra withdraws earnings
/// - View transaction history
/// - Balance validations
class BalanceServiceComplete {
  final ApiClient _apiClient = ApiClient();

  // Top-up methods
  static const List<String> topupMethods = [
    'transfer',
    'va',
    'qris',
    'ewallet',
  ];

  // Ledger types
  static const List<String> ledgerTypes = ['credit', 'debit'];

  // ========================================
  // Balance Operations
  // ========================================

  /// Get current user balance
  ///
  /// GET /api/balance
  ///
  /// Returns: Balance object with current amount
  ///
  /// Example:
  /// ```dart
  /// final balance = await balanceService.getBalance();
  /// print('Current balance: Rp ${balance['amount']}');
  /// ```
  Future<dynamic> getBalance() async {
    try {
      print('💰 Getting user balance');

      final response = await _apiClient.get('/api/balance');

      final balance = response['data'];
      print('✅ Balance: Rp ${balance['amount'] ?? 0}');

      return balance;
    } catch (e) {
      print('❌ Error getting balance: $e');
      rethrow;
    }
  }

  /// Top-up balance
  ///
  /// POST /api/balance/topup
  ///
  /// Parameters:
  /// - [amount]: Amount to top-up (must be > 0)
  /// - [method]: Top-up method (transfer, va, qris, ewallet)
  /// - [proofImage]: Base64 proof of payment (for transfer)
  /// - [notes]: Additional notes (optional)
  ///
  /// Returns: Balance ledger entry
  ///
  /// Example:
  /// ```dart
  /// // Top-up via bank transfer
  /// final topup = await balanceService.topUp(
  ///   amount: 100000.0,
  ///   method: 'transfer',
  ///   proofImage: base64Image,
  ///   notes: 'Top-up from BCA',
  /// );
  ///
  /// // Top-up via VA
  /// final topup = await balanceService.topUp(
  ///   amount: 50000.0,
  ///   method: 'va',
  /// );
  /// ```
  Future<dynamic> topUp({
    required double amount,
    required String method,
    String? proofImage,
    String? notes,
  }) async {
    try {
      // Validate method
      if (!topupMethods.contains(method)) {
        throw ArgumentError(
          'Invalid top-up method. Must be one of: ${topupMethods.join(", ")}',
        );
      }

      // Validate amount
      if (amount <= 0) {
        throw ArgumentError('Amount must be greater than 0');
      }

      // Validate proof for transfer
      if (method == 'transfer' && (proofImage == null || proofImage.isEmpty)) {
        throw ArgumentError('Proof of payment is required for bank transfer');
      }

      final body = {
        'amount': amount,
        'method': method,
        if (proofImage != null && proofImage.isNotEmpty)
          'proof_image': proofImage,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      print('💰 Top-up request');
      print('   Amount: Rp ${amount.toStringAsFixed(2)}');
      print('   Method: $method');

      final response = await _apiClient.postJson('/api/balance/topup', body);

      print('✅ Top-up request submitted');
      return response['data'];
    } catch (e) {
      print('❌ Error submitting top-up: $e');
      rethrow;
    }
  }

  /// Withdraw balance
  ///
  /// POST /api/balance/withdraw
  ///
  /// Parameters:
  /// - [amount]: Amount to withdraw (must be > 0)
  /// - [bankAccount]: Bank account number
  /// - [bankName]: Bank name (BCA, Mandiri, BNI, etc.)
  /// - [accountHolder]: Account holder name
  /// - [notes]: Additional notes (optional)
  ///
  /// Returns: Balance ledger entry
  ///
  /// Example:
  /// ```dart
  /// final withdraw = await balanceService.withdraw(
  ///   amount: 200000.0,
  ///   bankAccount: '1234567890',
  ///   bankName: 'BCA',
  ///   accountHolder: 'John Doe',
  ///   notes: 'Withdraw earnings',
  /// );
  /// ```
  Future<dynamic> withdraw({
    required double amount,
    required String bankAccount,
    required String bankName,
    required String accountHolder,
    String? notes,
  }) async {
    try {
      // Validate amount
      if (amount <= 0) {
        throw ArgumentError('Amount must be greater than 0');
      }

      // Validate bank details
      if (bankAccount.trim().isEmpty) {
        throw ArgumentError('Bank account number is required');
      }
      if (bankName.trim().isEmpty) {
        throw ArgumentError('Bank name is required');
      }
      if (accountHolder.trim().isEmpty) {
        throw ArgumentError('Account holder name is required');
      }

      // Check sufficient balance
      final balance = await getBalance();
      final currentAmount = (balance['amount'] ?? 0.0) as num;

      if (currentAmount < amount) {
        throw Exception(
          'Insufficient balance. Current: Rp ${currentAmount.toStringAsFixed(2)}, Required: Rp ${amount.toStringAsFixed(2)}',
        );
      }

      final body = {
        'amount': amount,
        'bank_account': bankAccount,
        'bank_name': bankName,
        'account_holder': accountHolder,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      print('💰 Withdraw request');
      print('   Amount: Rp ${amount.toStringAsFixed(2)}');
      print('   Bank: $bankName ($bankAccount)');
      print('   Holder: $accountHolder');

      final response = await _apiClient.postJson('/api/balance/withdraw', body);

      print('✅ Withdraw request submitted');
      return response['data'];
    } catch (e) {
      print('❌ Error submitting withdraw: $e');
      rethrow;
    }
  }

  /// Get balance ledger (transaction history)
  ///
  /// GET /api/balance/ledger
  ///
  /// Parameters:
  /// - [type]: Filter by type (credit, debit)
  /// - [page]: Page number for pagination (default: 1)
  /// - [perPage]: Items per page (default: 20, max: 100)
  ///
  /// Returns: List of ledger entries
  ///
  /// Example:
  /// ```dart
  /// // Get all transactions
  /// final ledger = await balanceService.getLedger();
  ///
  /// // Get only credits (top-ups, earnings)
  /// final credits = await balanceService.getLedger(type: 'credit');
  ///
  /// // Get only debits (withdrawals, payments)
  /// final debits = await balanceService.getLedger(type: 'debit');
  /// ```
  Future<List<dynamic>> getLedger({
    String? type,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Validate type if provided
      if (type != null && !ledgerTypes.contains(type)) {
        throw ArgumentError(
          'Invalid ledger type. Must be one of: ${ledgerTypes.join(", ")}',
        );
      }

      final query = <String, dynamic>{'page': page, 'per_page': perPage};

      if (type != null) query['type'] = type;

      print('💰 Getting balance ledger');
      if (type != null) print('   Filter: Type = $type');

      final response = await _apiClient.getJson(
        '/api/balance/ledger',
        query: query,
      );

      final List<dynamic> data = response['data'] ?? [];

      print('✅ Found ${data.length} ledger entries');
      return data;
    } catch (e) {
      print('❌ Error getting ledger: $e');
      rethrow;
    }
  }

  /// Get balance summary
  ///
  /// GET /api/balance/summary
  ///
  /// Returns: Balance summary with statistics
  ///
  /// Example:
  /// ```dart
  /// final summary = await balanceService.getSummary();
  /// print('Total credit: Rp ${summary['total_credit']}');
  /// print('Total debit: Rp ${summary['total_debit']}');
  /// print('Current balance: Rp ${summary['current_balance']}');
  /// ```
  Future<dynamic> getSummary() async {
    try {
      print('💰 Getting balance summary');

      final response = await _apiClient.get('/api/balance/summary');

      final summary = response['data'];
      print('✅ Summary retrieved');

      return summary;
    } catch (e) {
      print('❌ Error getting summary: $e');
      rethrow;
    }
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// Check if user has sufficient balance
  ///
  /// Parameters:
  /// - [amount]: Amount to check
  ///
  /// Returns: true if sufficient, false otherwise
  ///
  /// Example:
  /// ```dart
  /// final canPay = await balanceService.checkSufficientBalance(50000.0);
  /// if (!canPay) {
  ///   showDialog('Insufficient balance. Please top-up.');
  /// }
  /// ```
  Future<bool> checkSufficientBalance(double amount) async {
    try {
      print(
        '💰 Checking sufficient balance for Rp ${amount.toStringAsFixed(2)}',
      );

      final balance = await getBalance();
      final currentAmount = (balance['amount'] ?? 0.0) as num;

      final sufficient = currentAmount >= amount;

      if (sufficient) {
        print('✅ Sufficient balance');
      } else {
        print('❌ Insufficient balance');
        print('   Current: Rp ${currentAmount.toStringAsFixed(2)}');
        print('   Required: Rp ${amount.toStringAsFixed(2)}');
      }

      return sufficient;
    } catch (e) {
      print('❌ Error checking balance: $e');
      return false;
    }
  }

  /// Get available top-up methods with details
  ///
  /// Returns: List of top-up methods
  ///
  /// Example:
  /// ```dart
  /// final methods = balanceService.getTopUpMethods();
  /// for (var method in methods) {
  ///   print('${method['name']}: ${method['description']}');
  /// }
  /// ```
  List<Map<String, dynamic>> getTopUpMethods() {
    return [
      {
        'id': 'transfer',
        'name': 'Bank Transfer',
        'description': 'Transfer to our bank account',
        'requires_proof': true,
        'instant': false,
        'min_amount': 10000.0,
        'max_amount': 10000000.0,
      },
      {
        'id': 'va',
        'name': 'Virtual Account',
        'description': 'Pay via Virtual Account',
        'requires_proof': false,
        'instant': true,
        'min_amount': 10000.0,
        'max_amount': 10000000.0,
      },
      {
        'id': 'qris',
        'name': 'QRIS',
        'description': 'Scan QR code to top-up',
        'requires_proof': false,
        'instant': true,
        'min_amount': 10000.0,
        'max_amount': 2000000.0,
      },
      {
        'id': 'ewallet',
        'name': 'E-Wallet',
        'description': 'OVO, GoPay, Dana, etc.',
        'requires_proof': false,
        'instant': true,
        'min_amount': 10000.0,
        'max_amount': 5000000.0,
      },
    ];
  }

  /// Calculate balance after transaction
  ///
  /// Parameters:
  /// - [currentBalance]: Current balance
  /// - [amount]: Transaction amount
  /// - [type]: Transaction type (credit/debit)
  ///
  /// Returns: New balance after transaction
  ///
  /// Example:
  /// ```dart
  /// final newBalance = balanceService.calculateBalanceAfter(
  ///   currentBalance: 100000.0,
  ///   amount: 50000.0,
  ///   type: 'debit',
  /// );
  /// print('New balance: Rp $newBalance'); // 50000.0
  /// ```
  double calculateBalanceAfter({
    required double currentBalance,
    required double amount,
    required String type,
  }) {
    if (type == 'credit') {
      return currentBalance + amount;
    } else if (type == 'debit') {
      return currentBalance - amount;
    } else {
      throw ArgumentError('Invalid type. Must be credit or debit');
    }
  }

  /// Validate top-up amount
  ///
  /// Parameters:
  /// - [amount]: Amount to validate
  /// - [method]: Top-up method
  ///
  /// Returns: null if valid, error message if invalid
  ///
  /// Example:
  /// ```dart
  /// final error = balanceService.validateTopUpAmount(5000.0, 'transfer');
  /// if (error != null) {
  ///   showErrorDialog(error);
  /// }
  /// ```
  String? validateTopUpAmount(double amount, String method) {
    final methods = getTopUpMethods();
    final methodInfo = methods.firstWhere(
      (m) => m['id'] == method,
      orElse: () => {},
    );

    if (methodInfo.isEmpty) {
      return 'Invalid top-up method: $method';
    }

    final minAmount = (methodInfo['min_amount'] ?? 0.0) as double;
    final maxAmount = (methodInfo['max_amount'] ?? double.infinity) as double;

    if (amount < minAmount) {
      return 'Minimum top-up amount is Rp ${minAmount.toStringAsFixed(0)}';
    }

    if (amount > maxAmount) {
      return 'Maximum top-up amount is Rp ${maxAmount.toStringAsFixed(0)}';
    }

    return null; // Valid
  }

  /// Validate withdraw amount
  ///
  /// Parameters:
  /// - [amount]: Amount to validate
  /// - [currentBalance]: Current user balance
  ///
  /// Returns: null if valid, error message if invalid
  ///
  /// Example:
  /// ```dart
  /// final balance = await balanceService.getBalance();
  /// final error = balanceService.validateWithdrawAmount(
  ///   300000.0,
  ///   balance['amount'],
  /// );
  /// if (error != null) {
  ///   showErrorDialog(error);
  /// }
  /// ```
  String? validateWithdrawAmount(double amount, double currentBalance) {
    const minWithdraw = 50000.0;
    const maxWithdraw = 10000000.0;

    if (amount < minWithdraw) {
      return 'Minimum withdrawal amount is Rp ${minWithdraw.toStringAsFixed(0)}';
    }

    if (amount > maxWithdraw) {
      return 'Maximum withdrawal amount is Rp ${maxWithdraw.toStringAsFixed(0)}';
    }

    if (amount > currentBalance) {
      return 'Insufficient balance. Current: Rp ${currentBalance.toStringAsFixed(2)}';
    }

    return null; // Valid
  }
}
