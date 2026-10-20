import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/cafe.dart';
import '../../domain/repositories/cafe_repository.dart';
import '../datasources/cafe_remote_datasource.dart';

class CafeRepositoryImpl implements CafeRepository {
  final CafeRemoteDataSource remoteDataSource;

  CafeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Cafe>>> getCafesByCity(int cityId,
      {int? limit}) async {
    try {
      final cafes = await remoteDataSource.getCafesByCity(cityId, limit: limit);
      return Right(cafes.map((model) => model.toEntity()).toList());
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
  Future<Either<Failure, List<Cafe>>> getPopularCafes({int? limit}) async {
    try {
      final cafes = await remoteDataSource.getPopularCafes(limit: limit);
      return Right(cafes.map((model) => model.toEntity()).toList());
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
  Future<Either<Failure, List<Cafe>>> getNewestCafes({int? limit}) async {
    try {
      final cafes = await remoteDataSource.getNewestCafes(limit: limit);
      return Right(cafes.map((model) => model.toEntity()).toList());
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
  Future<Either<Failure, CafeSearchResult>> searchCafes(
    String query, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final result = await remoteDataSource.searchCafes(
        query,
        page: page,
        perPage: perPage,
      );
      return Right(CafeSearchResult(
        cafes: result.cafes.map((model) => model.toEntity()).toList(),
        hasMore: result.hasMore,
        currentPage: result.currentPage,
      ));
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
  Future<Either<Failure, Cafe>> getCafeById(int id) async {
    try {
      final cafe = await remoteDataSource.getCafeById(id);
      return Right(cafe.toEntity());
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
