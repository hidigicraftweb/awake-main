import 'dart:io';

import '../entities/wallet_topup_info.dart';
import '../entities/wallet_transaction.dart';

/// Result class for paginated wallet transactions
class WalletTransactionListResult {
  final List<WalletTransaction> transactions;
  final int currentPage;
  final int lastPage;
  final int total;

  WalletTransactionListResult({
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;
}

abstract class WalletRepository {
  Future<WalletTransactionListResult> getTransactions({
    String? type,
    int page = 1,
    int perPage = 15,
  });

  Future<WalletTopupInfo> getTopupInfo();

  Future<WalletTransaction> requestTopup({
    required int amount,
    required int uniqueCode,
    File? proofOfPayment,
  });

  Future<WalletTransaction> uploadProof({
    required int transactionId,
    required File proofOfPayment,
  });

  Future<WalletTransaction> cancelTopup(int transactionId);
}
