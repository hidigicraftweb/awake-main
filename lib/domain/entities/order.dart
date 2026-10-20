class Order {
  final int id;
  final OrderCafe? cafe;
  final String paymentStatus;
  final String orderStatus;
  final String paymentMethod;
  final int totalItems;
  final double grandTotalAmount;
  final String grandTotalFormatted;
  final int estimatedTime; // Estimated preparation time in minutes
  final DateTime? createdAt;

  const Order({
    required this.id,
    this.cafe,
    required this.paymentStatus,
    required this.orderStatus,
    required this.paymentMethod,
    required this.totalItems,
    required this.grandTotalAmount,
    required this.grandTotalFormatted,
    this.estimatedTime = 0,
    this.createdAt,
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

class OrderCafe {
  final int id;
  final String name;
  final String? slug;

  const OrderCafe({
    required this.id,
    required this.name,
    this.slug,
  });
}
