class WalletTransaction {
  final int id;
  final String type;
  final String status;
  final int amount; // Pure top-up amount that gets added to wallet
  final String amountFormatted;
  final int totalAmount; // Total transfer amount (amount + service fee - unique code)
  final String totalAmountFormatted;
  final int? serviceFee;
  final String? serviceFeeFormatted;
  final int? uniqueCode;
  final int? orderId; // Link to order for payment/refund transactions
  final String? proofOfPayment;
  final String? proofOfPaymentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.amountFormatted,
    required this.totalAmount,
    required this.totalAmountFormatted,
    this.serviceFee,
    this.serviceFeeFormatted,
    this.uniqueCode,
    this.orderId,
    this.proofOfPayment,
    this.proofOfPaymentUrl,
    this.createdAt,
    this.updatedAt,
  });
}
