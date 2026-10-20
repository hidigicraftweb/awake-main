import '../entities/order.dart';
import '../entities/order_detail.dart';
import '../../data/datasources/order_remote_datasource.dart';

abstract class OrderRepository {
  Future<OrderListResult> getOrders({
    String? orderStatus,
    int? cafeId,
    int page = 1,
    int perPage = 10,
  });

  Future<List<Order>> getActiveOrders();

  Future<OrderDetail> getOrderDetail(int id);

  Future<OrderDetail> cancelOrder(int id);

  Future<OrderDetail> reorder(int id);

  Future<OrderDetail> createOrder(CreateOrderRequest request);
}

class OrderListResult {
  final List<Order> orders;
  final int currentPage;
  final int lastPage;
  final int total;

  OrderListResult({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;
}
