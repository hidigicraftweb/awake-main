import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/wallet_topup_info_model.dart';
import '../models/wallet_transaction_model.dart';

/// Response class for paginated wallet transactions
class WalletTransactionListResponse {
  final List<WalletTransactionModel> transactions;
  final int currentPage;
  final int lastPage;
  final int total;

  WalletTransactionListResponse({
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

abstract class WalletRemoteDataSource {
  Future<WalletTransactionListResponse> getTransactions({
    String? type,
    int page = 1,
    int perPage = 15,
  });

  Future<WalletTopupInfoModel> getTopupInfo();

  Future<WalletTransactionModel> requestTopup({
    required int amount,
    required int uniqueCode,
    File? proofOfPayment,
  });

  Future<WalletTransactionModel> uploadProof({
    required int transactionId,
    required File proofOfPayment,
  });

  Future<WalletTransactionModel> cancelTopup(int transactionId);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<WalletTransactionListResponse> getTransactions({
    String? type,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (type != null) {
      queryParams['type'] = type;
    }

    final response = await _apiClient.get(
      ApiEndpoints.walletTransactions,
      queryParameters: queryParams,
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final transactionsJson = (data['transactions'] as List<dynamic>?) ?? [];
    final pagination = data['pagination'] as Map<String, dynamic>?;

    final transactions = transactionsJson
        .map((json) => WalletTransactionModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return WalletTransactionListResponse(
      transactions: transactions,
      currentPage: pagination?['current_page'] as int? ?? page,
      lastPage: pagination?['last_page'] as int? ?? 1,
      total: pagination?['total'] as int? ?? transactions.length,
    );
  }

  @override
  Future<WalletTopupInfoModel> getTopupInfo() async {
    final response = await _apiClient.get(ApiEndpoints.walletTopupInfo);
    final responseData = response.data as Map<String, dynamic>;
    return WalletTopupInfoModel.fromJson(
        responseData['data'] as Map<String, dynamic>);
  }

  @override
  Future<WalletTransactionModel> requestTopup({
    required int amount,
    required int uniqueCode,
    File? proofOfPayment,
  }) async {
    final formData = FormData.fromMap({
      'amount': amount,
      'unique_code': uniqueCode,
      if (proofOfPayment != null)
        'proof_of_payment': await MultipartFile.fromFile(
          proofOfPayment.path,
          filename: 'proof_of_payment.jpg',
        ),
    });

    final response = await _apiClient.postMultipart(
      ApiEndpoints.walletTopup,
      data: formData,
    );

    final responseData = response.data as Map<String, dynamic>;
    return WalletTransactionModel.fromJson(
        responseData['data'] as Map<String, dynamic>);
  }

  @override
  Future<WalletTransactionModel> uploadProof({
    required int transactionId,
    required File proofOfPayment,
  }) async {
    final formData = FormData.fromMap({
      'proof_of_payment': await MultipartFile.fromFile(
        proofOfPayment.path,
        filename: 'proof_of_payment.jpg',
      ),
    });

    final response = await _apiClient.postMultipart(
      ApiEndpoints.walletTopupUploadProof(transactionId),
      data: formData,
    );

    final responseData = response.data as Map<String, dynamic>;
    return WalletTransactionModel.fromJson(
        responseData['data'] as Map<String, dynamic>);
  }

  @override
  Future<WalletTransactionModel> cancelTopup(int transactionId) async {
    final response = await _apiClient.post(
      ApiEndpoints.walletTopupCancel(transactionId),
    );

    final responseData = response.data as Map<String, dynamic>;
    return WalletTransactionModel.fromJson(
        responseData['data'] as Map<String, dynamic>);
  }
}
