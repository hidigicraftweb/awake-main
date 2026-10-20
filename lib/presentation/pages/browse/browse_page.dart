import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/services/cafe_service.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/user.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/city/city_bloc.dart';
import '../../blocs/city/city_event.dart';
import '../../blocs/city/city_state.dart';
import '../../blocs/order/order_bloc.dart';
import '../../blocs/order/order_event.dart';
import '../../blocs/order/order_state.dart';
import '../../blocs/product/product_bloc.dart';
import '../../blocs/product/product_event.dart';
import '../../blocs/product/product_state.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../cart/cart_page.dart';
import '../city/city_details_page.dart';
import '../product/product_details_page.dart';
import '../product/product_list_page.dart';
import '../orders/order_details_page.dart';
import '../orders/orders_content.dart';
import '../profile/profile_content.dart';
import '../search/search_page.dart';

class BrowsePage extends StatefulWidget {
  final int initialNavIndex;

  const BrowsePage({super.key, this.initialNavIndex = 0});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage>
    with SingleTickerProviderStateMixin {
  int _currentNavIndex = 0;
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  late PageController _mainPageController;
  final ScrollController _scrollController = ScrollController();
  final CafeService _cafeService = CafeService();
  Timer? _bannerTimer;
  bool _bannerForward = true; // Direction for auto-slide
  bool _showStickyHeader = false;

  // Snack products bloc
  late ProductBloc _snackBloc;

  // Latest order bloc
  late OrderBloc _latestOrderBloc;

  // Animation for preparing card glow
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Promo banners
  final List<String> _promoBanners = [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  @override
  void initState() {
    super.initState();

    // Set initial navigation index from widget parameter
    _currentNavIndex = widget.initialNavIndex;

    // Set initial page based on nav index
    int initialPage = 0;
    if (widget.initialNavIndex == 3) {
      initialPage = 1; // Orders
    } else if (widget.initialNavIndex == 4) {
      initialPage = 2; // Profile
    }
    _mainPageController = PageController(initialPage: initialPage);

    // Initialize snack bloc and fetch snack products
    _snackBloc = sl<ProductBloc>()..add(const SnackProductsFetchRequested(limit: 6));

    // Initialize latest order bloc and fetch latest order
    _latestOrderBloc = sl<OrderBloc>()..add(const LatestOrderFetchRequested());

    // Setup glow animation - slow pulsing effect
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);

    // Setup banner auto-slide timer
    _startBannerAutoSlide();

    // Setup scroll listener for sticky header
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Show sticky header after scrolling past the original header (around 80px)
    final shouldShow = _scrollController.offset > 80;
    if (shouldShow != _showStickyHeader) {
      setState(() {
        _showStickyHeader = shouldShow;
      });
    }
  }

  void _startBannerAutoSlide() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Check if controller is attached before animating
      if (!_bannerController.hasClients) return;

      if (_bannerForward) {
        if (_currentBannerIndex < _promoBanners.length - 1) {
          _currentBannerIndex++;
        } else {
          _bannerForward = false;
          _currentBannerIndex--;
        }
      } else {
        if (_currentBannerIndex > 0) {
          _currentBannerIndex--;
        } else {
          _bannerForward = true;
          _currentBannerIndex++;
        }
      }
      _bannerController.animateToPage(
        _currentBannerIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _glowController.dispose();
    _bannerController.dispose();
    _mainPageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _snackBloc.close();
    _latestOrderBloc.close();
    super.dispose();
  }

  // Categories
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Coffee',
      'icon': Icons.coffee_rounded,
    },
    {
      'name': 'Non Coffee',
      'icon': Icons.local_cafe_rounded,
    },
    {
      'name': 'Tea',
      'icon': Icons.emoji_food_beverage_rounded,
    },
    {
      'name': 'Snack',
      'icon': Icons.bakery_dining_rounded,
    },
    {
      'name': 'Merchandise',
      'icon': Icons.shopping_bag_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        User? user;
        if (authState is AuthAuthenticated) {
          user = authState.user;
        } else if (authState is AuthProfileUpdated) {
          user = authState.user;
        } else {
          // Fallback to bloc's currentUser for other states (like AuthUserStatsLoaded)
          user = context.read<AuthBloc>().currentUser;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Main PageView for smooth transitions
              PageView(
                controller: _mainPageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Browse Content (index 0)
                  _buildBrowseContent(context),

                  // Orders Content (index 3, page 1)
                  const OrdersContent(),

                  // Profile Content (index 4, page 2)
                  const ProfileContent(),
                ],
              ),

              // Sticky Header (only show on browse page)
              if (_currentNavIndex == 0)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  top: _showStickyHeader ? 0 : -150,
                  left: 0,
                  right: 0,
                  child: _buildStickyHeader(context),
                ),

              // Floating Bottom Navigation
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomNavBar(
                  currentIndex: _currentNavIndex,
                  userPhotoUrl: user?.photoUrl,
                  cartItemCount: CartService().itemCount,
                  onTap: (index) {
                    // Handle Search - navigate to dedicated page
                    if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchPage()),
                      );
                      return;
                    }

                    int pageIndex = 0;
                    if (index == 0) {
                      pageIndex = 0;
                    } else if (index == 3) {
                      pageIndex = 1; // Orders
                    } else if (index == 4) {
                      pageIndex = 2; // Profile
                    }

                    if (index == 0 || index == 3 || index == 4) {
                      setState(() {
                        _currentNavIndex = index;
                      });
                      _mainPageController.animateToPage(
                        pageIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      // Refresh latest order when switching to browse tab
                      if (index == 0) {
                        _latestOrderBloc.add(const LatestOrderFetchRequested());
                      }
                      // Refresh user stats when switching to profile tab
                      if (index == 4) {
                        context.read<AuthBloc>().add(const AuthUserStatsFetchRequested());
                      }
                    } else {
                      setState(() {
                        _currentNavIndex = index;
                      });
                    }
                  },
                  onCartTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrowseContent(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with logo and location
          _buildHeader(),
          const SizedBox(height: 20),

          // 2. Promo Banner Slider
          _buildPromoBannerSection(),
          const SizedBox(height: 24),

          // 3. Categories Section
          _buildCategoriesSection(),
          const SizedBox(height: 24),

          // 4. Latest Order Status
          _buildLatestOrder(),
          const SizedBox(height: 24),

          // 5. Personalized Recommendations Carousel
          _buildRecommendationsSection(),
          const SizedBox(height: 24),

          // 6. Browse by City Section
          _buildBrowseByCitySection(),
          const SizedBox(height: 24),

          // 7. Primary Snack Grid
          _buildSnacksSection(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// Sticky Header that appears when scrolling
  Widget _buildStickyHeader(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 22,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // AWAKE Logo
          Text(
            'AWAKE',
            style: GoogleFonts.knewave(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),

          const Spacer(),

          // Cafe location info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cafe',
                style: AppTextStyles.caption.copyWith(fontSize: 11),
              ),
              Text(
                _cafeService.selectedCafe['name'] ?? 'Awake Sudirman',
                style: AppTextStyles.bodySemibold.copyWith(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Location icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 1. Header: AWAKE logo on left, location info on right
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // AWAKE Logo
          Text(
            'AWAKE',
            style: GoogleFonts.knewave(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),

          const Spacer(),

          // Cafe location info (text align right)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Cafe',
                style: AppTextStyles.caption,
              ),
              Text(
                _cafeService.selectedCafe['name'] ?? 'Awake Sudirman',
                style: AppTextStyles.bodySemibold,
              ),
            ],
          ),
          const SizedBox(width: 10),

          // Location icon with circle border
          Container(
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
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Latest Order Status with glowing border animation
  Widget _buildLatestOrder() {
    return BlocBuilder<OrderBloc, OrderState>(
      bloc: _latestOrderBloc,
      builder: (context, state) {
        if (state is! LatestOrderLoaded || state.order == null) {
          return const SizedBox.shrink();
        }

        final order = state.order!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: _glowAnimation.value),
                      Colors.orange.withValues(alpha: _glowAnimation.value),
                      AppColors.primary.withValues(alpha: _glowAnimation.value),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _glowAnimation.value * 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2), // 2px border
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsPage(orderId: order.id),
                  ),
                ).then((_) {
                  // Refresh latest order when returning from details page
                  _latestOrderBloc.add(const LatestOrderFetchRequested());
                });
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main card content
                  Container(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 26, bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        // Order icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Order info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.id}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                order.cafe?.name ?? 'Awake Coffee',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Arrow with circle border
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white24,
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white54,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge - overlapped above shopping icon
                  Positioned(
                    top: -10,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.displayStatus,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 4. Personalized Recommendations Carousel (Featured Products)
  Widget _buildRecommendationsSection() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured For You',
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        'Personalized picks for your daily routine',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: AppTextStyles.bodySemibold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (state is ProductLoading)
              _buildFeaturedProductsShimmer()
            else if (state is FeaturedProductsLoaded)
              _buildFeaturedProductsList(state.products)
            else if (state is ProductError)
              _buildFeaturedProductsError(state.message)
            else
              _buildFeaturedProductsShimmer(),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedProductsList(List<Product> products) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              'No featured products available',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 20),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
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
                    heroTagPrefix: 'product-image-featured',
                  ),
                ),
              );
            },
            child: Container(
              width: 170,
              margin: EdgeInsets.only(
                right: index < products.length - 1 ? 14 : 0,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    height: 120,
                    margin: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'product-image-featured-${product.id}',
                        child: product.thumbnailUrl != null &&
                                product.thumbnailUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product.thumbnailUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.coffee_rounded,
                                    size: 48,
                                    color: AppColors.textSecondary,
                                  ),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProductsShimmer() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 20),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 170,
            margin: EdgeInsets.only(right: index < 2 ? 14 : 0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    color: AppColors.divider.withValues(alpha: 0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.divider.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 140,
                        decoration: BoxDecoration(
                          color: AppColors.divider.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.divider.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProductsError(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load featured products',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  context
                      .read<ProductBloc>()
                      .add(const FeaturedProductsFetchRequested());
                },
                child: Text(
                  'Retry',
                  style: AppTextStyles.bodySemibold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 5. Primary Snack Grid (3 columns)
  Widget _buildSnacksSection() {
    return BlocBuilder<ProductBloc, ProductState>(
      bloc: _snackBloc,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Primary Snack',
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        'Perfect pair with your coffee',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductListPage(categoryName: 'Snack'),
                        ),
                      );
                    },
                    child: Text(
                      'See All',
                      style: AppTextStyles.bodySemibold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (state is ProductLoading)
              _buildSnacksShimmer()
            else if (state is SnackProductsLoaded)
              _buildSnacksGrid(state.products)
            else if (state is ProductError)
              _buildSnacksError(state.message)
            else
              _buildSnacksShimmer(),
          ],
        );
      },
    );
  }

  Widget _buildSnacksGrid(List<Product> products) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              'No snacks available',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.65,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
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
                    heroTagPrefix: 'product-image-snack',
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
                  // Image with rating badge
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Hero(
                            tag: 'product-image-snack-${product.id}',
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
                                          size: 32,
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
                                        size: 32,
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
        },
      ),
    );
  }

  Widget _buildSnacksShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.65,
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
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      color: AppColors.divider.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 50,
                        decoration: BoxDecoration(
                          color: AppColors.divider.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSnacksError(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load snacks',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  _snackBloc.add(const SnackProductsFetchRequested(limit: 6));
                },
                child: Text(
                  'Retry',
                  style: AppTextStyles.bodySemibold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 6. Browse by City Section
  Widget _buildBrowseByCitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Browse by City',
                    style: AppTextStyles.heading3,
                  ),
                  Text(
                    'Find your nearest Awake cafe',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: AppTextStyles.bodySemibold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        BlocBuilder<CityBloc, CityState>(
          builder: (context, state) {
            if (state is CityLoading) {
              return _buildCityLoadingShimmer();
            }

            if (state is CityError) {
              return _buildCityErrorState(state.message);
            }

            if (state is CitiesLoaded) {
              return _buildCityList(state.cities);
            }

            // Initial state - show loading
            return _buildCityLoadingShimmer();
          },
        ),
      ],
    );
  }

  Widget _buildCityList(List<City> cities) {
    if (cities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'No cities available',
          style: AppTextStyles.caption,
        ),
      );
    }

    return SizedBox(
      height: 145,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CityDetailsPage(
                    cityName: city.name,
                    cityImage: city.photoUrl ?? '',
                    cafesCount: city.cafesCount,
                    cityId: city.id,
                  ),
                ),
              );
            },
            child: Container(
              width: 94,
              margin: EdgeInsets.only(
                right: index < cities.length - 1 ? 12 : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circle city photo
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                      image: city.photoUrl != null && city.photoUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(city.photoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: city.photoUrl == null || city.photoUrl!.isEmpty
                        ? const Icon(
                            Icons.location_city_rounded,
                            color: AppColors.textSecondary,
                            size: 32,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  // City name
                  Text(
                    city.name,
                    style: AppTextStyles.bodySemibold.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Cafe count
                  Text(
                    '${city.cafesCount} cafes',
                    style: AppTextStyles.caption.copyWith(height: 1.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCityLoadingShimmer() {
    return SizedBox(
      height: 145,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 94,
            margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.divider.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.divider.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 40,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.divider.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCityErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                context.read<CityBloc>().add(const CitiesFetchRequested());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Retry',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Categories Section
  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _categories.map((category) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductListPage(
                    categoryName: category['name'],
                  ),
                ),
              );
            },
            child: Column(
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                // Category name
                Text(
                  category['name'],
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 7. Promo Banner Slider
  Widget _buildPromoBannerSection() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: _promoBanners.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    _promoBanners[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promoBanners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
