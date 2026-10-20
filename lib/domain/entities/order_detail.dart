import 'order.dart';

class OrderDetail {
  final int id;
  final OrderCafe? cafe;
  final String paymentStatus;
  final String orderStatus;
  final String paymentMethod;
  final int totalItems;
  final double subtotal;
  final String subtotalFormatted;
  final double taxPercentage;
  final double taxAmount;
  final String taxAmountFormatted;
  final double serviceFee;
  final String serviceFeeFormatted;
  final double discount;
  final String discountFormatted;
  final double grandTotalAmount;
  final String grandTotalFormatted;
  final int estimatedTime; // Estimated preparation time in minutes
  final String? proofOfPayment;
  final String? proofOfPaymentUrl;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderDetail({
    required this.id,
    this.cafe,
    required this.paymentStatus,
    required this.orderStatus,
    required this.paymentMethod,
    required this.totalItems,
    required this.subtotal,
    required this.subtotalFormatted,
    required this.taxPercentage,
    required this.taxAmount,
    required this.taxAmountFormatted,
    required this.serviceFee,
    required this.serviceFeeFormatted,
    required this.discount,
    required this.discountFormatted,
    required this.grandTotalAmount,
    required this.grandTotalFormatted,
    this.estimatedTime = 0,
    this.proofOfPayment,
    this.proofOfPaymentUrl,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  String get displayStatus {
    switch (orderStatus) {
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'finished':
        return 'Finished';
      case 'cancelled':
        return 'Cancelled';
      default:
        return orderStatus;
    }
  }

  bool get isActive =>
      orderStatus == 'pending' ||
      orderStatus == 'preparing';

  bool get canCancel => orderStatus == 'pending';

  String get statusMessage {
    switch (orderStatus) {
      case 'pending':
        return 'Waiting kitchen confirmation';
      case 'preparing':
        return estimatedTime > 0 ? '~$estimatedTime mins preparing' : 'Preparing your order';
      default:
        return '';
    }
  }
}

class OrderItem {
  final int id;
  final OrderProduct? product;
  final double price;
  final String priceFormatted;
  final int quantity;
  final double totalAmount;
  final String totalAmountFormatted;
  final List<OrderItemOption> options;

  const OrderItem({
    required this.id,
    this.product,
    required this.price,
    required this.priceFormatted,
    required this.quantity,
    required this.totalAmount,
    required this.totalAmountFormatted,
    required this.options,
  });

  String get displayName {
    final productName = product?.name ?? 'Unknown Product';
    if (options.isEmpty) {
      return '$productName x$quantity';
    }
    final optionNames = options.map((o) => o.name).join(', ');
    return '$productName ($optionNames) x$quantity';
  }
}

class OrderProduct {
  final int id;
  final String name;
  final String? category;

  const OrderProduct({
    required this.id,
    required this.name,
    this.category,
  });
}

class OrderItemOption {
  final int id;
  final String? name;
  final String? type;
  final double price;
  final String priceFormatted;

  const OrderItemOption({
    required this.id,
    this.name,
    this.type,
    required this.price,
    required this.priceFormatted,
  });
}
