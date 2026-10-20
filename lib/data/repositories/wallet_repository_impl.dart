import 'dart:io';

import '../../domain/entities/wallet_topup_info.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WalletTransactionListResult> getTransactions({
    String? type,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await remoteDataSource.getTransactions(
      type: type,
      page: page,
      perPage: perPage,
    );

    return WalletTransactionListResult(
      transactions: response.transactions,
      currentPage: response.currentPage,
      lastPage: response.lastPage,
      total: response.total,
    );
  }

  @override
  Future<WalletTopupInfo> getTopupInfo() async {
    return await remoteDataSource.getTopupInfo();
  }

  @override
  Future<WalletTransaction> requestTopup({
    required int amount,
    required int uniqueCode,
    File? proofOfPayment,
  }) async {
    return await remoteDataSource.requestTopup(
      amount: amount,
      uniqueCode: uniqueCode,
      proofOfPayment: proofOfPayment,
    );
  }

  @override
  Future<WalletTransaction> uploadProof({
    required int transactionId,
    required File proofOfPayment,
  }) async {
    return await remoteDataSource.uploadProof(
      transactionId: transactionId,
      proofOfPayment: proofOfPayment,
    );
  }

  @override
  Future<WalletTransaction> cancelTopup(int transactionId) async {
    return await remoteDataSource.cancelTopup(transactionId);
  }
}
