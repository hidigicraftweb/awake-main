import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getFeaturedProducts({int? limit}) async {
    try {
      final products = await remoteDataSource.getFeaturedProducts(limit: limit);
      return Right(products.map((model) => model.toEntity()).toList());
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
  Future<Either<Failure, List<Product>>> getPopularProducts({int? limit}) async {
    try {
      final products = await remoteDataSource.getPopularProducts(limit: limit);
      return Right(products.map((model) => model.toEntity()).toList());
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
  Future<Either<Failure, List<Product>>> getTopRatedProducts({int? limit}) async {
    try {
      final products = await remoteDataSource.getTopRatedProducts(limit: limit);
      return Right(products.map((model) => model.toEntity()).toList());
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
  Future<Either<Failure, List<Product>>> getProductsByCategorySlug(String slug, {int? limit}) async {
    try {
      final products = await remoteDataSource.getProductsByCategorySlug(slug, limit: limit);
      return Right(products.map((model) => model.toEntity()).toList());
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
  Future<Either<Failure, ProductSearchResult>> searchProducts(
    String query, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final result = await remoteDataSource.searchProducts(
        query,
        page: page,
        perPage: perPage,
      );
      return Right(ProductSearchResult(
        products: result.products.map((model) => model.toEntity()).toList(),
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
  Future<Either<Failure, Product>> getProductById(dynamic id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return Right(product.toEntity());
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
