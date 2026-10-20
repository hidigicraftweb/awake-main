import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/order_detail_model.dart';
import '../models/order_model.dart';

/// Request class for creating orders
class CreateOrderRequest {
  final int cafeId;
  final String paymentMethod;
  final List<CreateOrderItem> items;
  final double? discount;

  CreateOrderRequest({
    required this.cafeId,
    this.paymentMethod = 'wallet',
    required this.items,
    this.discount,
  });

  Map<String, dynamic> toJson() {
    return {
      'cafe_id': cafeId,
      'payment_method': paymentMethod,
      'items': items.map((item) => item.toJson()).toList(),
      if (discount != null) 'discount': discount,
    };
  }
}

class CreateOrderItem {
  final int productId;
  final int quantity;
  final List<int>? optionIds;

  CreateOrderItem({
    required this.productId,
    required this.quantity,
    this.optionIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      if (optionIds != null && optionIds!.isNotEmpty) 'options': optionIds,
    };
  }
}

abstract class OrderRemoteDataSource {
  Future<OrderListResponse> getOrders({
    String? orderStatus,
    int? cafeId,
    int page = 1,
    int perPage = 10,
  });

  Future<List<OrderModel>> getActiveOrders();

  Future<OrderDetailModel> getOrderDetail(int id);

  Future<OrderDetailModel> cancelOrder(int id);

  Future<OrderDetailModel> reorder(int id);

  Future<OrderDetailModel> createOrder(CreateOrderRequest request);
}

class OrderListResponse {
  final List<OrderModel> orders;
  final int currentPage;
  final int lastPage;
  final int total;

  OrderListResponse({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _apiClient;

  OrderRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<OrderListResponse> getOrders({
    String? orderStatus,
    int? cafeId,
    int page = 1,
    int perPage = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (orderStatus != null && orderStatus.isNotEmpty) {
      queryParams['order_status'] = orderStatus;
    }
    if (cafeId != null) {
      queryParams['cafe_id'] = cafeId;
    }

    final response = await _apiClient.get(
      ApiEndpoints.transactions,
      queryParameters: queryParams,
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final transactionsJson = data['transactions'] as List<dynamic>;
    final pagination = data['pagination'] as Map<String, dynamic>;

    return OrderListResponse(
      orders: transactionsJson
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: pagination['current_page'] as int,
      lastPage: pagination['last_page'] as int,
      total: pagination['total'] as int,
    );
  }

  @override
  Future<List<OrderModel>> getActiveOrders() async {
    final response = await _apiClient.get(ApiEndpoints.transactionsActive);

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final transactionsJson = data['transactions'] as List<dynamic>;

    return transactionsJson
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrderDetailModel> getOrderDetail(int id) async {
    final response = await _apiClient.get(ApiEndpoints.transactionById(id));

    final responseData = response.data as Map<String, dynamic>;
    return OrderDetailModel.fromJson(
        responseData['data'] as Map<String, dynamic>);
  }

  @override
  Future<OrderDetailModel> cancelOrder(int id) async {
    final response = await _apiClient.post(ApiEndpoints.transactionCancel(id));

    final responseData = response.data as Map<String, dynamic>;
    return OrderDetailModel.fromJson(
        responseData['data'] as Map<String, dynamic>);
  }

  @override
  Future<OrderDetailModel> reorder(int id) async {
    final response = await _apiClient.post(ApiEndpoints.transactionReorder(id));

    final responseData = response.data as Map<String, dynamic>;
    return OrderDetailModel.fromJson(
        responseData['data'] as Map<String, dynamic>);
  }

  @override
  Future<OrderDetailModel> createOrder(CreateOrderRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.transactions,
      data: request.toJson(),
    );

    final responseData = response.data as Map<String, dynamic>;
    return OrderDetailModel.fromJson(
        responseData['data'] as Map<String, dynamic>);
  }
}
