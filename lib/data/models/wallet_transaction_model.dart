import '../../core/network/api_endpoints.dart';
import '../../domain/entities/wallet_transaction.dart';

class WalletTransactionModel extends WalletTransaction {
  const WalletTransactionModel({
    required super.id,
    required super.type,
    required super.status,
    required super.amount,
    required super.amountFormatted,
    required super.totalAmount,
    required super.totalAmountFormatted,
    super.serviceFee,
    super.serviceFeeFormatted,
    super.uniqueCode,
    super.orderId,
    super.proofOfPayment,
    super.proofOfPaymentUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final proofUrlPath = json['proof_of_payment_url'] as String?;
    final fullProofUrl = ApiEndpoints.getFullStorageUrl(proofUrlPath);

    return WalletTransactionModel(
      id: _parseInt(json['id']),
      type: json['type'] as String,
      status: json['status'] as String,
      amount: _parseInt(json['amount']),
      amountFormatted: json['amount_formatted'] as String? ?? '',
      totalAmount: _parseInt(json['total_amount']),
      totalAmountFormatted: json['total_amount_formatted'] as String,
      serviceFee: json['service_fee'] != null
          ? _parseInt(json['service_fee'])
          : null,
      serviceFeeFormatted: json['service_fee_formatted'] as String?,
      uniqueCode: json['unique_code'] != null
          ? _parseInt(json['unique_code'])
          : null,
      orderId: json['order_id'] != null
          ? _parseInt(json['order_id'])
          : null,
      proofOfPayment: json['proof_of_payment'] as String?,
      proofOfPaymentUrl: fullProofUrl,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    return 0;
  }
}
