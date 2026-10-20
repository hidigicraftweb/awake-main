import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(const OrderInitial()) {
    on<OrdersFetchRequested>(_onOrdersFetchRequested);
    on<OrdersLoadMoreRequested>(_onOrdersLoadMoreRequested);
    on<ActiveOrdersFetchRequested>(_onActiveOrdersFetchRequested);
    on<LatestOrderFetchRequested>(_onLatestOrderFetchRequested);
    on<OrderDetailFetchRequested>(_onOrderDetailFetchRequested);
    on<OrderCancelRequested>(_onOrderCancelRequested);
    on<OrderReorderRequested>(_onOrderReorderRequested);
    on<OrderCreateRequested>(_onOrderCreateRequested);
  }

  Future<void> _onOrdersFetchRequested(
    OrdersFetchRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());
    try {
      final result = await _orderRepository.getOrders(
        orderStatus: event.orderStatus,
        cafeId: event.cafeId,
        page: 1,
      );

      emit(OrdersLoaded(
        orders: result.orders,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        total: result.total,
        currentStatusFilter: event.orderStatus,
        currentCafeFilter: event.cafeId,
      ));
    } catch (e) {
      emit(OrderError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onOrdersLoadMoreRequested(
    OrdersLoadMoreRequested event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrdersLoaded || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final result = await _orderRepository.getOrders(
        orderStatus: currentState.currentStatusFilter,
        cafeId: currentState.currentCafeFilter,
        page: currentState.currentPage + 1,
      );

      emit(OrdersLoaded(
        orders: [...currentState.orders, ...result.orders],
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        total: result.total,
        currentStatusFilter: currentState.currentStatusFilter,
        currentCafeFilter: currentState.currentCafeFilter,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onActiveOrdersFetchRequested(
    ActiveOrdersFetchRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());
    try {
      final orders = await _orderRepository.getActiveOrders();
      emit(ActiveOrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onLatestOrderFetchRequested(
    LatestOrderFetchRequested event,
    Emitter<OrderState> emit,
  ) async {
    try {
      final orders = await _orderRepository.getActiveOrders();
      final latestOrder = orders.isNotEmpty ? orders.first : null;
      emit(LatestOrderLoaded(order: latestOrder));
    } catch (e) {
      // Silently fail - just show no order card
      emit(const LatestOrderLoaded(order: null));
    }
  }

  Future<void> _onOrderDetailFetchRequested(
    OrderDetailFetchRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderDetailLoading());
    try {
      final orderDetail = await _orderRepository.getOrderDetail(event.orderId);
      emit(OrderDetailLoaded(orderDetail: orderDetail));
    } catch (e) {
      emit(OrderError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onOrderCancelRequested(
    OrderCancelRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());
    try {
      final orderDetail = await _orderRepository.cancelOrder(event.orderId);
      emit(OrderCancelSuccess(orderDetail: orderDetail));
    } catch (e) {
      emit(OrderError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onOrderReorderRequested(
    OrderReorderRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());
    try {
      final newOrder = await _orderRepository.reorder(event.orderId);
      emit(OrderReorderSuccess(newOrder: newOrder));
    } catch (e) {
      emit(OrderError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onOrderCreateRequested(
    OrderCreateRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderCreateLoading());
    try {
      final order = await _orderRepository.createOrder(event.request);
      emit(OrderCreateSuccess(order: order));
    } catch (e) {
      emit(OrderError(message: _parseErrorMessage(e)));
    }
  }

  String _parseErrorMessage(dynamic error) {
    final message = error.toString();
    if (message.contains('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}
