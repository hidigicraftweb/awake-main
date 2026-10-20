import 'package:equatable/equatable.dart';

import '../../../data/datasources/order_remote_datasource.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrdersFetchRequested extends OrderEvent {
  final String? orderStatus;
  final int? cafeId;
  final bool refresh;

  const OrdersFetchRequested({
    this.orderStatus,
    this.cafeId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [orderStatus, cafeId, refresh];
}

class OrdersLoadMoreRequested extends OrderEvent {
  const OrdersLoadMoreRequested();
}

class ActiveOrdersFetchRequested extends OrderEvent {
  const ActiveOrdersFetchRequested();
}

class LatestOrderFetchRequested extends OrderEvent {
  const LatestOrderFetchRequested();
}

class OrderDetailFetchRequested extends OrderEvent {
  final int orderId;

  const OrderDetailFetchRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderCancelRequested extends OrderEvent {
  final int orderId;

  const OrderCancelRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderReorderRequested extends OrderEvent {
  final int orderId;

  const OrderReorderRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderCreateRequested extends OrderEvent {
  final CreateOrderRequest request;

  const OrderCreateRequested({required this.request});

  @override
  List<Object?> get props => [request];
}
