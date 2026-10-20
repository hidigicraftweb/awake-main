import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/city.dart';

abstract class CityRepository {
  Future<Either<Failure, List<City>>> getCities();
  Future<Either<Failure, City>> getCityByIdentifier(String identifier);
}
