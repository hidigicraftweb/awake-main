import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FeaturedProductsFetchRequested extends ProductEvent {
  final int? limit;

  const FeaturedProductsFetchRequested({this.limit});

  @override
  List<Object?> get props => [limit];
}

class PopularProductsFetchRequested extends ProductEvent {
  final int? limit;

  const PopularProductsFetchRequested({this.limit});

  @override
  List<Object?> get props => [limit];
}

class TopRatedProductsFetchRequested extends ProductEvent {
  final int? limit;

  const TopRatedProductsFetchRequested({this.limit});

  @override
  List<Object?> get props => [limit];
}

class ProductFetchRequested extends ProductEvent {
  final dynamic productId;

  const ProductFetchRequested({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class SnackProductsFetchRequested extends ProductEvent {
  final int? limit;

  const SnackProductsFetchRequested({this.limit});

  @override
  List<Object?> get props => [limit];
}

class CategoryProductsFetchRequested extends ProductEvent {
  final String categorySlug;
  final int? limit;

  const CategoryProductsFetchRequested({
    required this.categorySlug,
    this.limit,
  });

  @override
  List<Object?> get props => [categorySlug, limit];
}
