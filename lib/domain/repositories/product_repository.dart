import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/product.dart';

class ProductSearchResult {
  final List<Product> products;
  final bool hasMore;
  final int currentPage;

  const ProductSearchResult({
    required this.products,
    required this.hasMore,
    required this.currentPage,
  });
}

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getFeaturedProducts({int? limit});
  Future<Either<Failure, List<Product>>> getPopularProducts({int? limit});
  Future<Either<Failure, List<Product>>> getTopRatedProducts({int? limit});
  Future<Either<Failure, List<Product>>> getProductsByCategorySlug(String slug, {int? limit});
  Future<Either<Failure, ProductSearchResult>> searchProducts(
    String query, {
    int page = 1,
    int perPage = 10,
  });
  Future<Either<Failure, Product>> getProductById(dynamic id);
}
