import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getFeaturedProducts({int? limit});
  Future<List<ProductModel>> getPopularProducts({int? limit});
  Future<List<ProductModel>> getTopRatedProducts({int? limit});
  Future<List<ProductModel>> getProductsByCategorySlug(String slug, {int? limit});
  Future<({List<ProductModel> products, bool hasMore, int currentPage})> searchProducts(
    String query, {
    int page = 1,
    int perPage = 10,
  });
  Future<ProductModel> getProductById(dynamic id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getFeaturedProducts({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await apiClient.get(
        ApiEndpoints.productsFeatured,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final productsData = data['data']['products'] as List<dynamic>?;
        if (productsData != null) {
          return productsData
              .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ProductModel>> getPopularProducts({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await apiClient.get(
        ApiEndpoints.productsPopular,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final productsData = data['data']['products'] as List<dynamic>?;
        if (productsData != null) {
          return productsData
              .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ProductModel>> getTopRatedProducts({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await apiClient.get(
        ApiEndpoints.productsTopRated,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final productsData = data['data']['products'] as List<dynamic>?;
        if (productsData != null) {
          return productsData
              .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategorySlug(String slug, {int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await apiClient.get(
        ApiEndpoints.productsByCategorySlug(slug),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final productsData = data['data']['products'] as List<dynamic>?;
        if (productsData != null) {
          return productsData
              .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<({List<ProductModel> products, bool hasMore, int currentPage})> searchProducts(
    String query, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'search': query,
        'page': page,
        'per_page': perPage,
      };

      final response = await apiClient.get(
        ApiEndpoints.products,
        queryParameters: queryParams,
      );
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final productsData = data['data']['products'] as List<dynamic>?;
        final pagination = data['data']['pagination'] as Map<String, dynamic>?;

        final products = productsData
            ?.map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList() ?? [];

        final currentPage = pagination?['current_page'] as int? ?? page;
        final lastPage = pagination?['last_page'] as int? ?? 1;
        final hasMore = currentPage < lastPage;

        return (products: products, hasMore: hasMore, currentPage: currentPage);
      }

      return (products: <ProductModel>[], hasMore: false, currentPage: page);
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProductModel> getProductById(dynamic id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.productById(id));
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        // Use fromDetailJson to parse options
        return ProductModel.fromDetailJson(data['data'] as Map<String, dynamic>);
      }

      throw const ServerException(message: 'Product not found');
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}
