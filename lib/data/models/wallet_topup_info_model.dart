import '../../domain/entities/wallet_topup_info.dart';

class WalletTopupInfoModel extends WalletTopupInfo {
  const WalletTopupInfoModel({
    required super.serviceFee,
    required super.serviceFeeFormatted,
    required super.maxUniqueCode,
    required super.bankAccounts,
    required super.instructions,
  });

  factory WalletTopupInfoModel.fromJson(Map<String, dynamic> json) {
    return WalletTopupInfoModel(
      serviceFee: (json['service_fee'] as num).toInt(),
      serviceFeeFormatted: json['service_fee_formatted'] as String,
      maxUniqueCode: (json['max_unique_code'] as num?)?.toInt() ?? 200,
      bankAccounts: (json['bank_accounts'] as List<dynamic>)
          .map((e) => BankAccountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      instructions: (json['instructions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

class BankAccountModel extends BankAccount {
  const BankAccountModel({
    required super.bankName,
    required super.accountNumber,
    required super.accountName,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      bankName: json['bank_name'] as String,
      accountNumber: json['account_number'] as String,
      accountName: json['account_name'] as String,
    );
  }
}
