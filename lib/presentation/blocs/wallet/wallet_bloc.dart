import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;

  WalletBloc({required WalletRepository walletRepository})
      : _walletRepository = walletRepository,
        super(const WalletInitial()) {
    on<WalletTransactionsFetchRequested>(_onTransactionsFetchRequested);
    on<WalletTransactionsLoadMoreRequested>(_onTransactionsLoadMoreRequested);
    on<WalletTopupInfoRequested>(_onTopupInfoRequested);
    on<WalletTopupRequested>(_onTopupRequested);
    on<WalletTopupProofUploaded>(_onProofUploaded);
    on<WalletTopupCancelled>(_onTopupCancelled);
  }

  Future<void> _onTransactionsFetchRequested(
    WalletTransactionsFetchRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      final result = await _walletRepository.getTransactions(
        type: event.type,
        page: 1,
      );

      emit(WalletTransactionsLoaded(
        transactions: result.transactions,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        total: result.total,
        currentTypeFilter: event.type,
      ));
    } catch (e) {
      emit(WalletError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onTransactionsLoadMoreRequested(
    WalletTransactionsLoadMoreRequested event,
    Emitter<WalletState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WalletTransactionsLoaded ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final result = await _walletRepository.getTransactions(
        type: currentState.currentTypeFilter,
        page: currentState.currentPage + 1,
      );

      emit(WalletTransactionsLoaded(
        transactions: [...currentState.transactions, ...result.transactions],
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        total: result.total,
        currentTypeFilter: currentState.currentTypeFilter,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onTopupInfoRequested(
    WalletTopupInfoRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      final topupInfo = await _walletRepository.getTopupInfo();
      emit(WalletTopupInfoLoaded(topupInfo: topupInfo));
    } catch (e) {
      emit(WalletError(message: e.toString()));
    }
  }

  Future<void> _onTopupRequested(
    WalletTopupRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      final transaction = await _walletRepository.requestTopup(
        amount: event.amount,
        uniqueCode: event.uniqueCode,
        proofOfPayment: event.proofOfPayment,
      );
      emit(WalletTopupSuccess(transaction: transaction));
    } catch (e) {
      emit(WalletError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onProofUploaded(
    WalletTopupProofUploaded event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      final transaction = await _walletRepository.uploadProof(
        transactionId: event.transactionId,
        proofOfPayment: event.proofOfPayment,
      );
      emit(WalletProofUploadSuccess(transaction: transaction));
    } catch (e) {
      emit(WalletError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onTopupCancelled(
    WalletTopupCancelled event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      final transaction = await _walletRepository.cancelTopup(event.transactionId);
      emit(WalletTopupCancelSuccess(transaction: transaction));
    } catch (e) {
      emit(WalletError(message: _parseErrorMessage(e)));
    }
  }

  String _parseErrorMessage(dynamic error) {
    final message = error.toString();
    if (message.contains('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}
