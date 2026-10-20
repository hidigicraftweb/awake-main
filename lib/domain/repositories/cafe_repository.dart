import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/cafe.dart';

class CafeSearchResult {
  final List<Cafe> cafes;
  final bool hasMore;
  final int currentPage;

  const CafeSearchResult({
    required this.cafes,
    required this.hasMore,
    required this.currentPage,
  });
}

abstract class CafeRepository {
  Future<Either<Failure, List<Cafe>>> getCafesByCity(int cityId, {int? limit});
  Future<Either<Failure, List<Cafe>>> getPopularCafes({int? limit});
  Future<Either<Failure, List<Cafe>>> getNewestCafes({int? limit});
  Future<Either<Failure, CafeSearchResult>> searchCafes(
    String query, {
    int page = 1,
    int perPage = 10,
  });
  Future<Either<Failure, Cafe>> getCafeById(int id);
}
