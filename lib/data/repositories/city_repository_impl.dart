import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/city.dart';
import '../../domain/repositories/city_repository.dart';
import '../datasources/city_remote_datasource.dart';

class CityRepositoryImpl implements CityRepository {
  final CityRemoteDataSource remoteDataSource;

  CityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<City>>> getCities() async {
    try {
      final cities = await remoteDataSource.getCities();
      return Right(cities.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, City>> getCityByIdentifier(String identifier) async {
    try {
      final city = await remoteDataSource.getCityByIdentifier(identifier);
      return Right(city.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
