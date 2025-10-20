import 'package:equatable/equatable.dart';

/// Events untuk balance management
abstract class BalanceEvent extends Equatable {
  const BalanceEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk fetch balance summary
class FetchBalanceSummary extends BalanceEvent {
  const FetchBalanceSummary();
}

/// Event untuk fetch balance ledger (transaction history)
class FetchBalanceLedger extends BalanceEvent {
  final int? page;
  final int? perPage;

  const FetchBalanceLedger({
    this.page,
    this.perPage,
  });

  @override
  List<Object?> get props => [page, perPage];
}

/// Event untuk top-up balance
class TopUpBalance extends BalanceEvent {
  final double amount;
  final String paymentMethod;

  const TopUpBalance({
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [amount, paymentMethod];
}

/// Event untuk refresh balance data
class RefreshBalance extends BalanceEvent {
  const RefreshBalance();
}
