import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/cafe.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/cafe_repository.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/search/search_event.dart';
import '../../blocs/search/search_state.dart';
import '../product/product_details_page.dart';
import '../cafe/cafe_details_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchBloc>(),
      child: const _SearchPageContent(),
    );
  }
}

class _SearchPageContent extends StatefulWidget {
  const _SearchPageContent();

  @override
  State<_SearchPageContent> createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<_SearchPageContent>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;

  static const _pageSize = 10;

  late final PagingController<int, Product> _productPagingController;
  late final PagingController<int, Cafe> _cafePagingController;

  String? _currentQuery;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _productPagingController = PagingController(
      fetchPage: _fetchProducts,
      getNextPageKey: (state) {
        if (state.keys?.isEmpty ?? true) return 1;
        final hasMore = state.pages?.lastOrNull?.length == _pageSize;
        return hasMore ? (state.keys!.last + 1) : null;
      },
    );

    _cafePagingController = PagingController(
      fetchPage: _fetchCafes,
      getNextPageKey: (state) {
        if (state.keys?.isEmpty ?? true) return 1;
        final hasMore = state.pages?.lastOrNull?.length == _pageSize;
        return hasMore ? (state.keys!.last + 1) : null;
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    _productPagingController.dispose();
    _cafePagingController.dispose();
    super.dispose();
  }

  Future<List<Product>> _fetchProducts(int pageKey) async {
    if (_currentQuery == null || _currentQuery!.isEmpty) {
      return [];
    }

    final result = await sl<ProductRepository>().searchProducts(
      _currentQuery!,
      page: pageKey,
      perPage: _pageSize,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (searchResult) => searchResult.products,
    );
  }

  Future<List<Cafe>> _fetchCafes(int pageKey) async {
    if (_currentQuery == null || _currentQuery!.isEmpty) {
      return [];
    }

    final result = await sl<CafeRepository>().searchCafes(
      _currentQuery!,
      page: pageKey,
      perPage: _pageSize,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (searchResult) => searchResult.cafes,
    );
  }

  void _onQueryChanged(String? query) {
    if (_currentQuery == query) return;
    _currentQuery = query;
    _productPagingController.refresh();
    _cafePagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            _buildTabBar(),
            Expanded(
              child: BlocListener<SearchBloc, SearchState>(
                listener: (context, state) => _onQueryChanged(state.query),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductsTab(),
                    _buildCafesTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                context.read<SearchBloc>().add(SearchQueryChanged(query: value));
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search products or cafes...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          context.read<SearchBloc>().add(const SearchCleared());
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Products'),
          Tab(text: 'Cafes'),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state.query == null) {
          return _buildEmptyState(
            icon: Icons.search_rounded,
            title: 'Search Products',
            subtitle: 'Type a keyword to find your favorite drinks and snacks',
          );
        }

        return PagingListener(
          controller: _productPagingController,
          builder: (context, state, fetchNextPage) {
            return PagedListView<int, Product>.separated(
              state: state,
              fetchNextPage: fetchNextPage,
              padding: const EdgeInsets.all(20),
              separatorBuilder: (context, index) => const SizedBox.shrink(),
              builderDelegate: PagedChildBuilderDelegate<Product>(
                itemBuilder: (context, product, index) =>
                    _buildProductCard(product),
                firstPageProgressIndicatorBuilder: (_) => _buildLoadingState(),
                newPageProgressIndicatorBuilder: (_) => _buildLoadMoreIndicator(),
                noItemsFoundIndicatorBuilder: (_) => _buildEmptyState(
                  icon: Icons.coffee_rounded,
                  title: 'No Products Found',
                  subtitle: 'Try searching with different keywords',
                ),
                firstPageErrorIndicatorBuilder: (context) => _buildErrorState(
                  state.error?.toString() ?? 'Error',
                  () => _productPagingController.refresh(),
                ),
                newPageErrorIndicatorBuilder: (context) => _buildRetryButton(
                  () => fetchNextPage(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCafesTab() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state.query == null) {
          return _buildEmptyState(
            icon: Icons.search_rounded,
            title: 'Search Cafes',
            subtitle: 'Type a keyword to find Awake cafes near you',
          );
        }

        return PagingListener(
          controller: _cafePagingController,
          builder: (context, state, fetchNextPage) {
            return PagedListView<int, Cafe>.separated(
              state: state,
              fetchNextPage: fetchNextPage,
              padding: const EdgeInsets.all(20),
              separatorBuilder: (context, index) => const SizedBox.shrink(),
              builderDelegate: PagedChildBuilderDelegate<Cafe>(
                itemBuilder: (context, cafe, index) => _buildCafeCard(cafe),
                firstPageProgressIndicatorBuilder: (_) => _buildLoadingState(),
                newPageProgressIndicatorBuilder: (_) => _buildLoadMoreIndicator(),
                noItemsFoundIndicatorBuilder: (_) => _buildEmptyState(
                  icon: Icons.store_rounded,
                  title: 'No Cafes Found',
                  subtitle: 'Try searching with different keywords',
                ),
                firstPageErrorIndicatorBuilder: (context) => _buildErrorState(
                  state.error?.toString() ?? 'Error',
                  () => _cafePagingController.refresh(),
                ),
                newPageErrorIndicatorBuilder: (context) => _buildRetryButton(
                  () => fetchNextPage(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: index == 4 ? 0 : 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: AppColors.divider.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 60,
                      decoration: BoxDecoration(
                        color: AppColors.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppColors.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 180,
                      decoration: BoxDecoration(
                        color: AppColors.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 80,
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

  Widget _buildErrorState(String message, VoidCallback onRetry) {
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
              'Search Failed',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton(VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Retry'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
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
              heroTagPrefix: 'search-product',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.thumbnailUrl != null &&
                          product.thumbnailUrl!.isNotEmpty
                      ? Image.network(
                          product.thumbnailUrl!,
                          width: 85,
                          height: 85,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(85, Icons.coffee_rounded),
                        )
                      : _buildPlaceholder(85, Icons.coffee_rounded),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (product.category != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category!.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        product.name,
                        style: AppTextStyles.bodySemibold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (product.about != null && product.about!.isNotEmpty) ...[
                        Text(
                          product.about!,
                          style: AppTextStyles.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        product.priceFormatted,
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCafeCard(Cafe cafe) {
    final isOpen = cafe.isCurrentlyOpen;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CafeDetailsPage(cafeId: cafe.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: cafe.thumbnailUrl != null && cafe.thumbnailUrl!.isNotEmpty
                  ? Image.network(
                      cafe.thumbnailUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(80, Icons.store_rounded),
                    )
                  : _buildPlaceholder(80, Icons.store_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isOpen ? 'Open' : 'Closed',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isOpen ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cafe.name,
                    style: AppTextStyles.bodySemibold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (cafe.city != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            cafe.city!.name,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (cafe.todayOpeningHours != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cafe.todayOpeningHours!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double size, IconData icon) {
    return Container(
      width: size,
      height: size,
      color: AppColors.divider.withValues(alpha: 0.3),
      child: Icon(
        icon,
        color: AppColors.textSecondary,
        size: 32,
      ),
    );
  }
}
