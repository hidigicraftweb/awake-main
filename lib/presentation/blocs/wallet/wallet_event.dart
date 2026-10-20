import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class WalletTransactionsFetchRequested extends WalletEvent {
  final String? type;
  final bool refresh;

  const WalletTransactionsFetchRequested({
    this.type,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [type, refresh];
}

class WalletTransactionsLoadMoreRequested extends WalletEvent {
  const WalletTransactionsLoadMoreRequested();
}

class WalletTopupInfoRequested extends WalletEvent {
  const WalletTopupInfoRequested();
}

class WalletTopupRequested extends WalletEvent {
  final int amount;
  final int uniqueCode;
  final File? proofOfPayment;

  const WalletTopupRequested({
    required this.amount,
    required this.uniqueCode,
    this.proofOfPayment,
  });

  @override
  List<Object?> get props => [amount, uniqueCode, proofOfPayment];
}

class WalletTopupProofUploaded extends WalletEvent {
  final int transactionId;
  final File proofOfPayment;

  const WalletTopupProofUploaded({
    required this.transactionId,
    required this.proofOfPayment,
  });

  @override
  List<Object?> get props => [transactionId, proofOfPayment];
}

class WalletTopupCancelled extends WalletEvent {
  final int transactionId;

  const WalletTopupCancelled({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}
