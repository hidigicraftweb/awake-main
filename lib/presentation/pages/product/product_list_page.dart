import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';
import '../../blocs/product/product_bloc.dart';
import '../../blocs/product/product_event.dart';
import '../../blocs/product/product_state.dart';
import 'product_details_page.dart';

class ProductListPage extends StatelessWidget {
  final String categoryName;

  const ProductListPage({
    super.key,
    required this.categoryName,
  });

  // Convert category name to slug for API
  String get _categorySlug {
    switch (categoryName.toLowerCase()) {
      case 'non coffee':
        return 'non-coffee';
      default:
        return categoryName.toLowerCase();
    }
  }

  String get _categoryType {
    if (categoryName == 'Snack' || categoryName == 'Merchandise') {
      return 'snack';
    }
    return 'drink';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()
        ..add(CategoryProductsFetchRequested(categorySlug: _categorySlug)),
      child: _ProductListContent(
        categoryName: categoryName,
        categorySlug: _categorySlug,
        categoryType: _categoryType,
      ),
    );
  }
}

class _ProductListContent extends StatelessWidget {
  final String categoryName;
  final String categorySlug;
  final String categoryType;

  const _ProductListContent({
    required this.categoryName,
    required this.categorySlug,
    required this.categoryType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // App Bar
          _buildAppBar(context),

          // Products Grid
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return _buildLoadingState();
                }

                if (state is ProductError) {
                  return _buildErrorState(context, state.message);
                }

                if (state is CategoryProductsLoaded) {
                  if (state.products.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildProductsGrid(context, state.products);
                }

                return _buildLoadingState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
          const Spacer(),

          // Title
          Text(
            categoryName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),

          // Placeholder for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 34,
        childAspectRatio: categoryType == 'drink' ? 0.58 : 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: categoryType == 'drink' ? 5 : 4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(categoryType == 'drink' ? 0 : 16),
                    ),
                    color: AppColors.divider.withValues(alpha: 0.3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppColors.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: 60,
                      decoration: BoxDecoration(
                        color: AppColors.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load products',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                context.read<ProductBloc>().add(
                      CategoryProductsFetchRequested(categorySlug: categorySlug),
                    );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_state_no_data.png',
              width: 160,
              height: 160,
            ),
            const SizedBox(height: 20),
            Text(
              'No Products Found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No products available in this category yet.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context, List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 34,
        childAspectRatio: categoryType == 'drink' ? 0.58 : 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        if (categoryType == 'drink') {
          return _buildDrinkCard(context, product);
        } else {
          return _buildSnackCard(context, product);
        }
      },
    );
  }

  // Drink card style - like recommendations section
  Widget _buildDrinkCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(
              productId: product.id,
              name: product.name,
              description: product.about ?? '',
              price: product.price,
              image: product.thumbnailUrl ?? '',
              isAssetImage: false,
              heroTagPrefix: 'product-image-category',
            ),
          ),
        );
      },
      child: Stack(
        children: [
          // White background - bottom half only
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 90, // Start white bg from middle
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Content
          Column(
            children: [
              // Image - floats above
              Expanded(
                flex: 5,
                child: Center(
                  child: Hero(
                    tag: 'product-image-category-${product.id}',
                    child: product.thumbnailUrl != null && product.thumbnailUrl!.isNotEmpty
                        ? Image.network(
                            product.thumbnailUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.coffee_rounded,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : const Icon(
                            Icons.coffee_rounded,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.bodySemibold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.about ?? product.category?.name ?? '',
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.priceFormatted,
                      style: AppTextStyles.price,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Snack card style - like snacks grid section
  Widget _buildSnackCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(
              productId: product.id,
              name: product.name,
              description: product.about ?? '',
              price: product.price,
              image: product.thumbnailUrl ?? '',
              isAssetImage: false,
              heroTagPrefix: 'product-image-category',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rating badge and Hero animation
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Hero(
                      tag: 'product-image-category-${product.id}',
                      child: product.thumbnailUrl != null && product.thumbnailUrl!.isNotEmpty
                          ? Image.network(
                              product.thumbnailUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.divider.withValues(alpha: 0.3),
                                child: const Center(
                                  child: Icon(
                                    Icons.bakery_dining_rounded,
                                    size: 48,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.divider.withValues(alpha: 0.3),
                              child: const Center(
                                child: Icon(
                                  Icons.bakery_dining_rounded,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                    ),
                  ),
                  // Rating badge
                  if (product.rate > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rate.toStringAsFixed(1),
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.bodySemibold.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.priceFormatted,
                    style: AppTextStyles.price.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
