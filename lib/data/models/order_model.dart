import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    super.cafe,
    required super.paymentStatus,
    required super.orderStatus,
    required super.paymentMethod,
    required super.totalItems,
    required super.grandTotalAmount,
    required super.grandTotalFormatted,
    super.estimatedTime,
    super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      cafe: json['cafe'] != null
          ? OrderCafeModel.fromJson(json['cafe'] as Map<String, dynamic>)
          : null,
      paymentStatus: json['payment_status'] as String,
      orderStatus: json['order_status'] as String,
      paymentMethod: json['payment_method'] as String,
      totalItems: json['total_items'] as int,
      grandTotalAmount: (json['grand_total_amount'] as num).toDouble(),
      grandTotalFormatted: json['grand_total_formatted'] as String,
      estimatedTime: json['estimated_time'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

class OrderCafeModel extends OrderCafe {
  const OrderCafeModel({
    required super.id,
    required super.name,
    super.slug,
  });

  factory OrderCafeModel.fromJson(Map<String, dynamic> json) {
    return OrderCafeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String?,
    );
  }
}
