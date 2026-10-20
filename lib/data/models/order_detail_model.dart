import '../../core/network/api_endpoints.dart';
import '../../domain/entities/order_detail.dart';
import 'order_model.dart';

class OrderDetailModel extends OrderDetail {
  const OrderDetailModel({
    required super.id,
    super.cafe,
    required super.paymentStatus,
    required super.orderStatus,
    required super.paymentMethod,
    required super.totalItems,
    required super.subtotal,
    required super.subtotalFormatted,
    required super.taxPercentage,
    required super.taxAmount,
    required super.taxAmountFormatted,
    required super.serviceFee,
    required super.serviceFeeFormatted,
    required super.discount,
    required super.discountFormatted,
    required super.grandTotalAmount,
    required super.grandTotalFormatted,
    super.estimatedTime,
    super.proofOfPayment,
    super.proofOfPaymentUrl,
    required super.items,
    super.createdAt,
    super.updatedAt,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final proofUrlPath = json['proof_of_payment_url'] as String?;
    final fullProofUrl = ApiEndpoints.getFullStorageUrl(proofUrlPath);

    return OrderDetailModel(
      id: json['id'] as int,
      cafe: json['cafe'] != null
          ? OrderCafeModel.fromJson(json['cafe'] as Map<String, dynamic>)
          : null,
      paymentStatus: json['payment_status'] as String,
      orderStatus: json['order_status'] as String,
      paymentMethod: json['payment_method'] as String,
      totalItems: json['total_items'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      subtotalFormatted: json['subtotal_formatted'] as String,
      taxPercentage: (json['tax_percentage'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      taxAmountFormatted: json['tax_amount_formatted'] as String,
      serviceFee: (json['service_fee'] as num).toDouble(),
      serviceFeeFormatted: json['service_fee_formatted'] as String,
      discount: (json['discount'] as num).toDouble(),
      discountFormatted: json['discount_formatted'] as String,
      grandTotalAmount: (json['grand_total_amount'] as num).toDouble(),
      grandTotalFormatted: json['grand_total_formatted'] as String,
      estimatedTime: json['estimated_time'] as int? ?? 0,
      proofOfPayment: json['proof_of_payment'] as String?,
      proofOfPaymentUrl: fullProofUrl,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    super.product,
    required super.price,
    required super.priceFormatted,
    required super.quantity,
    required super.totalAmount,
    required super.totalAmountFormatted,
    required super.options,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      product: json['product'] != null
          ? OrderProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      price: (json['price'] as num).toDouble(),
      priceFormatted: json['price_formatted'] as String,
      quantity: json['quantity'] as int,
      totalAmount: (json['total_amount'] as num).toDouble(),
      totalAmountFormatted: json['total_amount_formatted'] as String,
      options: (json['options'] as List<dynamic>?)
              ?.map(
                  (e) => OrderItemOptionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class OrderProductModel extends OrderProduct {
  const OrderProductModel({
    required super.id,
    required super.name,
    super.category,
  });

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    return OrderProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String?,
    );
  }
}

class OrderItemOptionModel extends OrderItemOption {
  const OrderItemOptionModel({
    required super.id,
    super.name,
    super.type,
    required super.price,
    required super.priceFormatted,
  });

  factory OrderItemOptionModel.fromJson(Map<String, dynamic> json) {
    return OrderItemOptionModel(
      id: json['id'] as int,
      name: json['name'] as String?,
      type: json['type'] as String?,
      price: (json['price'] as num).toDouble(),
      priceFormatted: json['price_formatted'] as String,
    );
  }
}
