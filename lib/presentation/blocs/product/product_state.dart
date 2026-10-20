import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class FeaturedProductsLoaded extends ProductState {
  final List<Product> products;

  const FeaturedProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class PopularProductsLoaded extends ProductState {
  final List<Product> products;

  const PopularProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class TopRatedProductsLoaded extends ProductState {
  final List<Product> products;

  const TopRatedProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductLoaded extends ProductState {
  final Product product;

  const ProductLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

class SnackProductsLoaded extends ProductState {
  final List<Product> products;

  const SnackProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class CategoryProductsLoaded extends ProductState {
  final List<Product> products;
  final String categorySlug;

  const CategoryProductsLoaded({
    required this.products,
    required this.categorySlug,
  });

  @override
  List<Object?> get props => [products, categorySlug];
}

class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object?> get props => [message];
}
