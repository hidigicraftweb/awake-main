import 'package:equatable/equatable.dart';

abstract class CafeEvent extends Equatable {
  const CafeEvent();

  @override
  List<Object?> get props => [];
}

class CafesByCityFetchRequested extends CafeEvent {
  final int cityId;
  final int? limit;

  const CafesByCityFetchRequested({
    required this.cityId,
    this.limit,
  });

  @override
  List<Object?> get props => [cityId, limit];
}

class PopularCafesFetchRequested extends CafeEvent {
  final int? limit;

  const PopularCafesFetchRequested({this.limit});

  @override
  List<Object?> get props => [limit];
}

class NewestCafesFetchRequested extends CafeEvent {
  final int? limit;

  const NewestCafesFetchRequested({this.limit});

  @override
  List<Object?> get props => [limit];
}

class CafeFetchRequested extends CafeEvent {
  final int cafeId;

  const CafeFetchRequested({required this.cafeId});

  @override
  List<Object?> get props => [cafeId];
}
