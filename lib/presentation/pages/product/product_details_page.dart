import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';
import '../../blocs/product/product_bloc.dart';
import '../../blocs/product/product_event.dart';
import '../../blocs/product/product_state.dart';
import '../cart/cart_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final int? productId;
  final String name;
  final String description;
  final int price;
  final String image;
  final bool isAssetImage;
  final String category; // 'drink' or 'snack'
  final String heroTagPrefix; // prefix for hero animation tag

  // Cafe information (optional - set when browsing from a specific cafe)
  final int? cafeId;
  final String? cafeName;
  final String? cafeAddress;
  final String? cafeImageUrl;

  const ProductDetailsPage({
    super.key,
    this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.isAssetImage = true,
    this.category = 'drink',
    this.heroTagPrefix = 'product-image',
    this.cafeId,
    this.cafeName,
    this.cafeAddress,
    this.cafeImageUrl,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeader = false;

  // Animation for sticky header image
  late AnimationController _headerImageController;
  late Animation<double> _headerImageScale;
  late Animation<double> _headerImageOpacity;

  // Selected options (index in the list for each type)
  final Map<String, int> _selectedOptions = {};
  int _quantity = 1;

  // Cached product data
  Product? _product;

  bool get _isSnack => widget.category == 'snack' ||
      (_product?.category?.slug == 'snack');

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Setup header image animation
    _headerImageController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _headerImageScale = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerImageController, curve: Curves.easeOutBack),
    );
    _headerImageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerImageController, curve: Curves.easeOut),
    );
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 200;
    if (shouldShow != _showStickyHeader) {
      setState(() {
        _showStickyHeader = shouldShow;
      });
      // Trigger header image animation
      if (shouldShow) {
        _headerImageController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _headerImageController.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    return 'IDR ${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  // Get the name to display
  String get _displayName => _product?.name ?? widget.name;

  // Get the description to display
  String get _displayDescription => _product?.about ?? widget.description;

  // Get the image to display
  String get _displayImage => _product?.thumbnailUrl ?? widget.image;

  // Get the base price
  int get _basePrice => _product?.price ?? widget.price;

  // Get the rating
  double get _rating => _product?.rate ?? 4.9;

  // Calculate additional price from selected options
  int get _optionsPrice {
    if (_product == null || _isSnack) return 0;

    int additionalPrice = 0;
    for (final group in _product!.options) {
      final selectedIndex = _selectedOptions[group.type] ?? 0;
      if (selectedIndex < group.items.length) {
        additionalPrice += group.items[selectedIndex].price;
      }
    }
    return additionalPrice;
  }

  int get _unitPrice => _basePrice + _optionsPrice;
  int get _totalPrice => _unitPrice * _quantity;

  void _initDefaultOptions(Product product) {
    // Set default selection (first item) for each option group
    for (final group in product.options) {
      if (!_selectedOptions.containsKey(group.type)) {
        _selectedOptions[group.type] = 0;
      }
    }
  }

  void _showAddedToCartModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAddedToCartModal(),
    );
  }

  Widget _buildAddedToCartModal() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Product image
                SizedBox(
                  width: 80,
                  height: 80,
                  child: _displayImage.isNotEmpty && !widget.isAssetImage
                      ? Image.network(
                          _displayImage,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.coffee_rounded,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : widget.isAssetImage && widget.image.isNotEmpty
                          ? Image.asset(widget.image, fit: BoxFit.contain)
                          : const Icon(
                              Icons.coffee_rounded,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  'Added to Cart!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Product info
                Text(
                  '$_quantity x $_displayName',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 4),

                // Price
                Text(
                  _formatPrice(_totalPrice),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Continue Shopping button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Close modal
                          Navigator.pop(context); // Go back to browse
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.textSecondary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              'Add Other',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // View Cart button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Close modal
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartPage()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              'View Cart',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If productId is provided, fetch from backend
    if (widget.productId != null) {
      return BlocProvider(
        create: (context) => sl<ProductBloc>()
          ..add(ProductFetchRequested(productId: widget.productId!)),
        child: BlocConsumer<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductLoaded) {
              setState(() {
                _product = state.product;
                _initDefaultOptions(state.product);
              });
            }
          },
          builder: (context, state) {
            return _buildContent(context, state is ProductLoading);
          },
        ),
      );
    }

    // Otherwise use passed props (for backward compatibility)
    return _buildContent(context, false);
  }

  Widget _buildContent(BuildContext context, bool isLoading) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Main scrollable content
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Big Product Image Section
                      _buildProductImage(context),

                      // Product Info Section
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name + Description + Rating Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Name + Description
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _displayName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _displayDescription,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                          height: 1.5,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Rating badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 22,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _rating.toStringAsFixed(1),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Options from backend (only for non-snacks)
                            if (!_isSnack && _product != null)
                              ..._buildOptionsFromBackend()
                            else if (!_isSnack && isLoading)
                              _buildOptionsLoading(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Sticky Header
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  top: _showStickyHeader ? 0 : -150,
                  left: 0,
                  right: 0,
                  child: _buildStickyHeader(context),
                ),
              ],
            ),
          ),

          // Bottom Bar with Price and Add to Cart
          _buildBottomBar(context),
        ],
      ),
    );
  }

  List<Widget> _buildOptionsFromBackend() {
    if (_product == null) return [];

    final widgets = <Widget>[];
    final iconMap = {
      'size': Icons.local_cafe_outlined,
      'dairy': Icons.water_drop_outlined,
      'sweetness': Icons.cake_outlined,
      'ice': Icons.ac_unit_outlined,
    };
    final labelMap = {
      'size': 'Size',
      'dairy': 'Dairy',
      'sweetness': 'Sweetness',
      'ice': 'Ice Cube',
    };

    for (final group in _product!.options) {
      widgets.add(_buildOptionSection(
        icon: iconMap[group.type] ?? Icons.tune,
        label: labelMap[group.type] ?? group.type,
        options: group.items,
        selectedIndex: _selectedOptions[group.type] ?? 0,
        onSelect: (index) {
          setState(() {
            _selectedOptions[group.type] = index;
          });
        },
      ));
      widgets.add(const SizedBox(height: 24));
    }

    return widgets;
  }

  Widget _buildOptionsLoading() {
    return Column(
      children: List.generate(4, (index) => Column(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      )),
    );
  }

  Widget _buildOptionSection({
    required IconData icon,
    required String label,
    required List<ProductOption> options,
    required int selectedIndex,
    required Function(int) onSelect,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.heading3.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          ...List.generate(options.length, (index) {
            final option = options[index];
            final isSelected = selectedIndex == index;
            final hasPrice = option.price > 0;
            return GestureDetector(
              onTap: () => onSelect(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: index < options.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: AppColors.divider.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    // Option name
                    Expanded(
                      child: Text(
                        option.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // Price (if any)
                    if (hasPrice) ...[
                      Text(
                        '+${option.priceFormatted}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    // Radio button
                    _buildRadioButton(isSelected),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildRadioButton(bool isSelected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center content - Product image and name
          AnimatedBuilder(
            animation: _headerImageController,
            builder: (context, child) {
              return Transform.scale(
                scale: _headerImageScale.value,
                child: Opacity(
                  opacity: _headerImageOpacity.value,
                  child: child,
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product image thumbnail
                SizedBox(
                  height: 50,
                  width: 50,
                  child: widget.isAssetImage && widget.image.isNotEmpty
                      ? Image.asset(
                          widget.image,
                          fit: BoxFit.contain,
                        )
                      : _displayImage.isNotEmpty
                          ? Image.network(
                              _displayImage,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.coffee_rounded,
                                size: 24,
                                color: AppColors.textSecondary,
                              ),
                            )
                          : const Icon(
                              Icons.coffee_rounded,
                              size: 24,
                              color: AppColors.textSecondary,
                            ),
                ),
                const SizedBox(width: 10),
                // Product name
                Text(
                  _displayName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Back button - left
          Positioned(
            left: 0,
            child: GestureDetector(
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
          ),

          // Favorite button - right
          Positioned(
            right: 0,
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
                  Icons.favorite_border_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return Stack(
      children: [
        // Product Image - Big and prominent with Hero animation
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.38,
          margin: const EdgeInsets.only(top: 130, bottom: 30),
          child: Hero(
            tag: '${widget.heroTagPrefix}-${widget.productId ?? widget.name}',
            child: widget.isAssetImage && widget.image.isNotEmpty
                ? Image.asset(
                    widget.image,
                    fit: BoxFit.contain,
                  )
                : _displayImage.isNotEmpty
                    ? Image.network(
                        _displayImage,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.coffee_rounded,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.coffee_rounded,
                          size: 80,
                          color: AppColors.textSecondary,
                        ),
                      ),
          ),
        ),

        // Back Button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),

        // Favorite Button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 16,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity Selector
          Row(
            children: [
              // Minus button (border only)
              GestureDetector(
                onTap: () {
                  if (_quantity > 1) {
                    setState(() => _quantity--);
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _quantity > 1
                          ? AppColors.textPrimary
                          : AppColors.disabled,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: _quantity > 1
                        ? AppColors.textPrimary
                        : AppColors.disabled,
                    size: 18,
                  ),
                ),
              ),
              // Quantity
              SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    '$_quantity',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              // Plus button
              GestureDetector(
                onTap: () {
                  setState(() => _quantity++);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Add Button with Price (CTA - Red)
          Expanded(
            child: GestureDetector(
              onTap: () async {
                // Build selected options for cart
                Map<String, dynamic>? cartOptions;
                if (!_isSnack && _product != null) {
                  cartOptions = {};
                  for (final group in _product!.options) {
                    final selectedIndex = _selectedOptions[group.type] ?? 0;
                    if (selectedIndex < group.items.length) {
                      final option = group.items[selectedIndex];
                      cartOptions[group.type] = option.name;
                      cartOptions['${group.type}Price'] = option.price;
                      cartOptions['${group.type}Id'] = option.id;
                    }
                  }
                }

                final cartService = CartService();

                // Set the selected cafe if provided
                if (widget.cafeId != null && widget.cafeName != null) {
                  await cartService.setSelectedCafe(CartCafe(
                    id: widget.cafeId!,
                    name: widget.cafeName!,
                    address: widget.cafeAddress,
                    imageUrl: widget.cafeImageUrl,
                  ));
                }

                // Add item to cart
                final cartItem = CartItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  productId: widget.productId,
                  name: _displayName,
                  image: _displayImage.isNotEmpty ? _displayImage : widget.image,
                  basePrice: _basePrice,
                  quantity: _quantity,
                  options: cartOptions,
                );
                await cartService.addItem(cartItem);

                // Show follow-up modal
                _showAddedToCartModal();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    'Add - ${_formatPrice(_totalPrice)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
