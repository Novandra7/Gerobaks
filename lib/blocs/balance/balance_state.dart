import 'package:equatable/equatable.dart';

/// States untuk balance management
enum BalanceStatus {
  initial,
  loading,
  loaded,
  error,
  topUpInProgress,
  topUpSuccess,
  topUpError,
}

class BalanceState extends Equatable {
  final BalanceStatus status;
  final Map<String, dynamic>? balanceSummary;
  final List<dynamic>? ledgerTransactions;
  final String? errorMessage;
  final bool hasMoreTransactions;
  final int currentPage;

  const BalanceState({
    this.status = BalanceStatus.initial,
    this.balanceSummary,
    this.ledgerTransactions,
    this.errorMessage,
    this.hasMoreTransactions = true,
    this.currentPage = 1,
  });

  /// Initial state
  factory BalanceState.initial() {
    return const BalanceState(status: BalanceStatus.initial);
  }

  /// Loading state
  factory BalanceState.loading() {
    return const BalanceState(status: BalanceStatus.loading);
  }

  /// Loaded state
  factory BalanceState.loaded({
    required Map<String, dynamic> balanceSummary,
    List<dynamic>? ledgerTransactions,
    bool hasMoreTransactions = true,
    int currentPage = 1,
  }) {
    return BalanceState(
      status: BalanceStatus.loaded,
      balanceSummary: balanceSummary,
      ledgerTransactions: ledgerTransactions,
      hasMoreTransactions: hasMoreTransactions,
      currentPage: currentPage,
    );
  }

  /// Error state
  factory BalanceState.error(String message) {
    return BalanceState(status: BalanceStatus.error, errorMessage: message);
  }

  /// Top-up in progress
  factory BalanceState.topUpInProgress() {
    return const BalanceState(status: BalanceStatus.topUpInProgress);
  }

  /// Top-up success
  factory BalanceState.topUpSuccess(Map<String, dynamic> updatedSummary) {
    return BalanceState(
      status: BalanceStatus.topUpSuccess,
      balanceSummary: updatedSummary,
    );
  }

  /// Top-up error
  factory BalanceState.topUpError(String message) {
    return BalanceState(
      status: BalanceStatus.topUpError,
      errorMessage: message,
    );
  }

  /// Copy with method
  BalanceState copyWith({
    BalanceStatus? status,
    Map<String, dynamic>? balanceSummary,
    List<dynamic>? ledgerTransactions,
    String? errorMessage,
    bool? hasMoreTransactions,
    int? currentPage,
  }) {
    return BalanceState(
      status: status ?? this.status,
      balanceSummary: balanceSummary ?? this.balanceSummary,
      ledgerTransactions: ledgerTransactions ?? this.ledgerTransactions,
      errorMessage: errorMessage,
      hasMoreTransactions: hasMoreTransactions ?? this.hasMoreTransactions,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  /// Get current balance
  double? get currentBalance {
    if (balanceSummary == null) return null;
    return (balanceSummary!['balance'] as num?)?.toDouble();
  }

  /// Get pending balance
  double? get pendingBalance {
    if (balanceSummary == null) return null;
    return (balanceSummary!['pending_balance'] as num?)?.toDouble();
  }

  /// Get total spent
  double? get totalSpent {
    if (balanceSummary == null) return null;
    return (balanceSummary!['total_spent'] as num?)?.toDouble();
  }

  @override
  List<Object?> get props => [
    status,
    balanceSummary,
    ledgerTransactions,
    errorMessage,
    hasMoreTransactions,
    currentPage,
  ];
}
