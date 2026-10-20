import 'package:equatable/equatable.dart';

import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_detail.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrdersLoaded extends OrderState {
  final List<Order> orders;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingMore;
  final String? currentStatusFilter;
  final int? currentCafeFilter;

  const OrdersLoaded({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.isLoadingMore = false,
    this.currentStatusFilter,
    this.currentCafeFilter,
  });

  bool get hasMore => currentPage < lastPage;

  OrdersLoaded copyWith({
    List<Order>? orders,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingMore,
    String? currentStatusFilter,
    int? currentCafeFilter,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentStatusFilter: currentStatusFilter ?? this.currentStatusFilter,
      currentCafeFilter: currentCafeFilter ?? this.currentCafeFilter,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        currentPage,
        lastPage,
        total,
        isLoadingMore,
        currentStatusFilter,
        currentCafeFilter,
      ];
}

class ActiveOrdersLoaded extends OrderState {
  final List<Order> orders;

  const ActiveOrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class LatestOrderLoaded extends OrderState {
  final Order? order;

  const LatestOrderLoaded({this.order});

  @override
  List<Object?> get props => [order];
}

class OrderDetailLoading extends OrderState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderState {
  final OrderDetail orderDetail;

  const OrderDetailLoaded({required this.orderDetail});

  @override
  List<Object?> get props => [orderDetail];
}

class OrderCancelSuccess extends OrderState {
  final OrderDetail orderDetail;

  const OrderCancelSuccess({required this.orderDetail});

  @override
  List<Object?> get props => [orderDetail];
}

class OrderReorderSuccess extends OrderState {
  final OrderDetail newOrder;

  const OrderReorderSuccess({required this.newOrder});

  @override
  List<Object?> get props => [newOrder];
}

class OrderError extends OrderState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrderCreateLoading extends OrderState {
  const OrderCreateLoading();
}

class OrderCreateSuccess extends OrderState {
  final OrderDetail order;

  const OrderCreateSuccess({required this.order});

  @override
  List<Object?> get props => [order];
}
