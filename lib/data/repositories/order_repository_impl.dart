import '../../domain/entities/order.dart';
import '../../domain/entities/order_detail.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OrderListResult> getOrders({
    String? orderStatus,
    int? cafeId,
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await remoteDataSource.getOrders(
      orderStatus: orderStatus,
      cafeId: cafeId,
      page: page,
      perPage: perPage,
    );

    return OrderListResult(
      orders: response.orders,
      currentPage: response.currentPage,
      lastPage: response.lastPage,
      total: response.total,
    );
  }

  @override
  Future<List<Order>> getActiveOrders() async {
    return await remoteDataSource.getActiveOrders();
  }

  @override
  Future<OrderDetail> getOrderDetail(int id) async {
    return await remoteDataSource.getOrderDetail(id);
  }

  @override
  Future<OrderDetail> cancelOrder(int id) async {
    return await remoteDataSource.cancelOrder(id);
  }

  @override
  Future<OrderDetail> reorder(int id) async {
    return await remoteDataSource.reorder(id);
  }

  @override
  Future<OrderDetail> createOrder(CreateOrderRequest request) async {
    return await remoteDataSource.createOrder(request);
  }
}
