import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/cafe_model.dart';

abstract class CafeRemoteDataSource {
  Future<List<CafeModel>> getCafesByCity(int cityId, {int? limit});
  Future<List<CafeModel>> getPopularCafes({int? limit});
  Future<List<CafeModel>> getNewestCafes({int? limit});
  Future<({List<CafeModel> cafes, bool hasMore, int currentPage})> searchCafes(
    String query, {
    int page = 1,
    int perPage = 10,
  });
  Future<CafeModel> getCafeById(int id);
}

class CafeRemoteDataSourceImpl implements CafeRemoteDataSource {
  final ApiClient apiClient;

  CafeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CafeModel>> getCafesByCity(int cityId, {int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await apiClient.get(
        ApiEndpoints.cafesByCity(cityId),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final cafesData = data['data']['cafes'] as List<dynamic>?;
        if (cafesData != null) {
          return cafesData
              .map((json) => CafeModel.fromJson(json as Map<String, dynamic>))
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
  Future<List<CafeModel>> getPopularCafes({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await apiClient.get(
        ApiEndpoints.cafesPopular,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final cafesData = data['data']['cafes'] as List<dynamic>?;
        if (cafesData != null) {
          return cafesData
              .map((json) => CafeModel.fromJson(json as Map<String, dynamic>))
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
  Future<List<CafeModel>> getNewestCafes({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await apiClient.get(
        ApiEndpoints.cafesNewest,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final cafesData = data['data']['cafes'] as List<dynamic>?;
        if (cafesData != null) {
          return cafesData
              .map((json) => CafeModel.fromJson(json as Map<String, dynamic>))
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
  Future<({List<CafeModel> cafes, bool hasMore, int currentPage})> searchCafes(
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
        ApiEndpoints.cafes,
        queryParameters: queryParams,
      );
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final cafesData = data['data']['cafes'] as List<dynamic>?;
        final pagination = data['data']['pagination'] as Map<String, dynamic>?;

        final cafes = cafesData
            ?.map((json) => CafeModel.fromJson(json as Map<String, dynamic>))
            .toList() ?? [];

        final currentPage = pagination?['current_page'] as int? ?? page;
        final lastPage = pagination?['last_page'] as int? ?? 1;
        final hasMore = currentPage < lastPage;

        return (cafes: cafes, hasMore: hasMore, currentPage: currentPage);
      }

      return (cafes: <CafeModel>[], hasMore: false, currentPage: page);
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
  Future<CafeModel> getCafeById(int id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.cafeById(id));
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        // Use fromDetailJson for full cafe details
        return CafeModel.fromDetailJson(data['data'] as Map<String, dynamic>);
      }

      throw const ServerException(message: 'Cafe not found');
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
