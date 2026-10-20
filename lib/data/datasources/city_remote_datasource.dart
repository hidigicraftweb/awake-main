import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/city_model.dart';

abstract class CityRemoteDataSource {
  Future<List<CityModel>> getCities();
  Future<CityModel> getCityByIdentifier(String identifier);
}

class CityRemoteDataSourceImpl implements CityRemoteDataSource {
  final ApiClient apiClient;

  CityRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CityModel>> getCities() async {
    try {
      final response = await apiClient.get(ApiEndpoints.cities);
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> citiesJson = data['data'] as List<dynamic>;
        return citiesJson
            .map((json) => CityModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw const ServerException(message: 'Failed to fetch cities');
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
  Future<CityModel> getCityByIdentifier(String identifier) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.cities}/$identifier');
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return CityModel.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw const ServerException(message: 'City not found');
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
