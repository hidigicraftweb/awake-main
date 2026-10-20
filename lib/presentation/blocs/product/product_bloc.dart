import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc({required this.repository}) : super(const ProductInitial()) {
    on<FeaturedProductsFetchRequested>(_onFeaturedProductsFetchRequested);
    on<PopularProductsFetchRequested>(_onPopularProductsFetchRequested);
    on<TopRatedProductsFetchRequested>(_onTopRatedProductsFetchRequested);
    on<ProductFetchRequested>(_onProductFetchRequested);
    on<SnackProductsFetchRequested>(_onSnackProductsFetchRequested);
    on<CategoryProductsFetchRequested>(_onCategoryProductsFetchRequested);
  }

  Future<void> _onFeaturedProductsFetchRequested(
    FeaturedProductsFetchRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await repository.getFeaturedProducts(limit: event.limit);

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(FeaturedProductsLoaded(products: products)),
    );
  }

  Future<void> _onPopularProductsFetchRequested(
    PopularProductsFetchRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await repository.getPopularProducts(limit: event.limit);

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(PopularProductsLoaded(products: products)),
    );
  }

  Future<void> _onTopRatedProductsFetchRequested(
    TopRatedProductsFetchRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await repository.getTopRatedProducts(limit: event.limit);

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(TopRatedProductsLoaded(products: products)),
    );
  }

  Future<void> _onProductFetchRequested(
    ProductFetchRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await repository.getProductById(event.productId);

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (product) => emit(ProductLoaded(product: product)),
    );
  }

  Future<void> _onSnackProductsFetchRequested(
    SnackProductsFetchRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await repository.getProductsByCategorySlug('snack', limit: event.limit);

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(SnackProductsLoaded(products: products)),
    );
  }

  Future<void> _onCategoryProductsFetchRequested(
    CategoryProductsFetchRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await repository.getProductsByCategorySlug(
      event.categorySlug,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(CategoryProductsLoaded(
        products: products,
        categorySlug: event.categorySlug,
      )),
    );
  }
}
