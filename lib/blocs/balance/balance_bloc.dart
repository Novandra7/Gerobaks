import 'package:bloc/bloc.dart';
import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'balance_event.dart';
import 'balance_state.dart';

/// BLoC untuk mengelola balance
/// Menggunakan ApiClient untuk komunikasi dengan backend
class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final ApiClient _api = ApiClient();

  BalanceBloc() : super(BalanceState.initial()) {
    on<FetchBalanceSummary>(_onFetchBalanceSummary);
    on<FetchBalanceLedger>(_onFetchBalanceLedger);
    on<TopUpBalance>(_onTopUpBalance);
    on<RefreshBalance>(_onRefreshBalance);
  }

  /// Handle fetch balance summary
  Future<void> _onFetchBalanceSummary(
    FetchBalanceSummary event,
    Emitter<BalanceState> emit,
  ) async {
    emit(BalanceState.loading());

    try {
      print('💰 BalanceBloc: Fetching balance summary');

      // GET /api/balance/summary
      final response = await _api.get(ApiRoutes.balanceSummary);

      print('✅ BalanceBloc: Balance summary fetched');
      print('Response: $response');

      // Extract balance data from response
      final data = response['data'] as Map<String, dynamic>?;

      if (data != null) {
        emit(BalanceState.loaded(
          balanceSummary: data,
          ledgerTransactions: state.ledgerTransactions,
          hasMoreTransactions: state.hasMoreTransactions,
          currentPage: state.currentPage,
        ));
      } else {
        emit(BalanceState.error('Data balance tidak ditemukan'));
      }
    } catch (e) {
      print('❌ BalanceBloc: Failed to fetch balance summary - $e');
      emit(BalanceState.error(e.toString()));
    }
  }

  /// Handle fetch balance ledger
  Future<void> _onFetchBalanceLedger(
    FetchBalanceLedger event,
    Emitter<BalanceState> emit,
  ) async {
    // Don't show loading if we're paginating
    if (event.page == null || event.page == 1) {
      emit(state.copyWith(status: BalanceStatus.loading));
    }

    try {
      print('💰 BalanceBloc: Fetching balance ledger page ${event.page ?? 1}');

      // GET /api/balance/ledger?page=1&per_page=20
      String endpoint = ApiRoutes.balanceLedger;
      if (event.page != null || event.perPage != null) {
        endpoint += '?';
        if (event.page != null) endpoint += 'page=${event.page}&';
        if (event.perPage != null) endpoint += 'per_page=${event.perPage}';
      }

      final response = await _api.get(endpoint);

      print('✅ BalanceBloc: Balance ledger fetched');

      // Extract ledger data from response
      final data = response['data'] as List<dynamic>?;
      final meta = response['meta'] as Map<String, dynamic>?;

      if (data != null) {
        // If paginating, append to existing transactions
        List<dynamic> updatedTransactions;
        if (event.page != null && event.page! > 1 && state.ledgerTransactions != null) {
          updatedTransactions = [...state.ledgerTransactions!, ...data];
        } else {
          updatedTransactions = data;
        }

        // Check if there are more pages
        bool hasMore = true;
        if (meta != null) {
          final currentPage = meta['current_page'] as int?;
          final lastPage = meta['last_page'] as int?;
          if (currentPage != null && lastPage != null) {
            hasMore = currentPage < lastPage;
          }
        }

        emit(state.copyWith(
          status: BalanceStatus.loaded,
          ledgerTransactions: updatedTransactions,
          hasMoreTransactions: hasMore,
          currentPage: event.page ?? 1,
        ));
      } else {
        emit(state.copyWith(
          status: BalanceStatus.error,
          errorMessage: 'Data ledger tidak ditemukan',
        ));
      }
    } catch (e) {
      print('❌ BalanceBloc: Failed to fetch balance ledger - $e');
      emit(state.copyWith(
        status: BalanceStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Handle top-up balance
  Future<void> _onTopUpBalance(
    TopUpBalance event,
    Emitter<BalanceState> emit,
  ) async {
    emit(BalanceState.topUpInProgress());

    try {
      print('💰 BalanceBloc: Processing top-up ${event.amount}');

      // POST /api/balance/topup
      await _api.postJson(ApiRoutes.balanceTopup, {
        'amount': event.amount,
        'payment_method': event.paymentMethod,
      });

      print('✅ BalanceBloc: Top-up successful');

      // After successful top-up, fetch updated balance
      final summaryResponse = await _api.get(ApiRoutes.balanceSummary);
      final updatedSummary = summaryResponse['data'] as Map<String, dynamic>?;

      if (updatedSummary != null) {
        emit(state.copyWith(
          status: BalanceStatus.topUpSuccess,
          balanceSummary: updatedSummary,
        ));

        // Also refresh ledger to show the new transaction
        add(const FetchBalanceLedger(page: 1));
      } else {
        emit(BalanceState.topUpSuccess(state.balanceSummary ?? {}));
      }
    } catch (e) {
      print('❌ BalanceBloc: Top-up failed - $e');
      emit(BalanceState.topUpError(e.toString()));
    }
  }

  /// Handle refresh balance
  Future<void> _onRefreshBalance(
    RefreshBalance event,
    Emitter<BalanceState> emit,
  ) async {
    // Fetch both summary and ledger
    add(const FetchBalanceSummary());
    add(const FetchBalanceLedger(page: 1));
  }
}
