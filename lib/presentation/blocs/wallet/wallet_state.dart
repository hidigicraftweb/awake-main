import 'package:equatable/equatable.dart';

import '../../../domain/entities/wallet_topup_info.dart';
import '../../../domain/entities/wallet_transaction.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletTransactionsLoaded extends WalletState {
  final List<WalletTransaction> transactions;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingMore;
  final String? currentTypeFilter;

  const WalletTransactionsLoaded({
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.isLoadingMore = false,
    this.currentTypeFilter,
  });

  bool get hasMore => currentPage < lastPage;

  WalletTransactionsLoaded copyWith({
    List<WalletTransaction>? transactions,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingMore,
    String? currentTypeFilter,
  }) {
    return WalletTransactionsLoaded(
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentTypeFilter: currentTypeFilter ?? this.currentTypeFilter,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        currentPage,
        lastPage,
        total,
        isLoadingMore,
        currentTypeFilter,
      ];
}

class WalletTopupInfoLoaded extends WalletState {
  final WalletTopupInfo topupInfo;

  const WalletTopupInfoLoaded({required this.topupInfo});

  @override
  List<Object?> get props => [topupInfo];
}

class WalletTopupSuccess extends WalletState {
  final WalletTransaction transaction;

  const WalletTopupSuccess({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class WalletProofUploadSuccess extends WalletState {
  final WalletTransaction transaction;

  const WalletProofUploadSuccess({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class WalletTopupCancelSuccess extends WalletState {
  final WalletTransaction transaction;

  const WalletTopupCancelSuccess({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});

  @override
  List<Object?> get props => [message];
}
