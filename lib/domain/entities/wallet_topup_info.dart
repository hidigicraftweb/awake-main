class WalletTopupInfo {
  final int serviceFee;
  final String serviceFeeFormatted;
  final int maxUniqueCode;
  final List<BankAccount> bankAccounts;
  final List<String> instructions;

  const WalletTopupInfo({
    required this.serviceFee,
    required this.serviceFeeFormatted,
    required this.maxUniqueCode,
    required this.bankAccounts,
    required this.instructions,
  });
}

class BankAccount {
  final String bankName;
  final String accountNumber;
  final String accountName;

  const BankAccount({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });
}
