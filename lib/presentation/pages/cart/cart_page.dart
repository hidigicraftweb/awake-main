import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/services/cafe_service.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/datasources/order_remote_datasource.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/order/order_bloc.dart';
import '../../blocs/order/order_event.dart';
import '../../blocs/order/order_state.dart';
import '../browse/browse_page.dart';
import '../wallet/topup_page.dart' show TopUpPage;

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  final CafeService _cafeService = CafeService();
  final TextEditingController _promoCodeController = TextEditingController();
  String? _appliedPromoCode;

  List<CartItem> get _cartItems => _cartService.items;

  // Get selected cafe - first from cart service, then from cafe service as fallback
  CartCafe? get _selectedCafe {
    // First check cart service
    if (_cartService.selectedCafe != null) {
      return _cartService.selectedCafe;
    }

    // Fallback to cafe service
    final cafeData = _cafeService.selectedCafe;
    if (cafeData['id'] != null) {
      return CartCafe(
        id: cafeData['id'] as int,
        name: cafeData['name'] as String,
        address: cafeData['address'] as String?,
        imageUrl: cafeData['imageUrl'] as String?,
        isOpen: cafeData['isOpen'] as bool? ?? true,
      );
    }

    return null;
  }

  bool _isSubmitting = false;


  // Get wallet balance from auth state
  int get _walletBalance {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.walletBalance.toInt();
    }
    return 0;
  }

  int get _subtotal => _cartService.subtotal;

  int get _tax {
    return (_subtotal * 0.10).round(); // 10% tax (matches backend)
  }

  int get _serviceFee => 2000; // Matches backend service fee

  int get _total => _subtotal + _tax + _serviceFee;

  int get _totalItems => _cartService.itemCount;

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    return 'IDR ${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  void _showProductDetailsModal(CartItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildProductDetailsModal(item),
    );
  }

  void _showDeleteConfirmationModal(CartItem item, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildDeleteConfirmationModal(item, index),
    );
  }

  Widget _buildDeleteConfirmationModal(CartItem item, int index) {
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Product info
                Row(
                  children: [
                    // Product image
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: _buildItemImage(item.image),
                    ),
                    const SizedBox(width: 14),

                    // Product name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatPrice(item.unitPrice),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Confirmation text
                Text(
                  'Are you sure you want to remove this item from your cart?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                              'Cancel',
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

                    // Remove button
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await _cartService.removeItem(index);
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              'Remove',
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

  // Store bloc context for use in methods
  BuildContext? _blocContext;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrderBloc>(),
      child: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderCreateLoading) {
            setState(() {
              _isSubmitting = true;
            });
          } else if (state is OrderCreateSuccess) {
            setState(() {
              _isSubmitting = false;
            });
            // Refresh user data to update wallet balance
            context.read<AuthBloc>().add(const AuthCheckRequested());
            // Show success modal
            _showOrderSuccessModal();
          } else if (state is OrderError) {
            setState(() {
              _isSubmitting = false;
            });
            // Show error snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Store the bloc context for use in other methods
          _blocContext = context;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                // App Bar
                _buildAppBar(context),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cafe Info Card
                        _buildCafeCard(),
                        const SizedBox(height: 24),

                        // Cart Items Section
                        Text(
                          'Your Order',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 12),

                        // Cart Items List
                        ...List.generate(_cartItems.length, (index) {
                          return _buildCartItem(_cartItems[index], index);
                        }),

                        const SizedBox(height: 24),

                        // My Wallet
                        _buildWalletCard(),
                        const SizedBox(height: 16),

                        // Promo Code Section
                        _buildPromoCodeSection(),
                        const SizedBox(height: 16),

                        // Order Summary
                        _buildOrderSummary(),
                      ],
                    ),
                  ),
                ),

                // Bottom Bar with Checkout Button
                _buildBottomBar(context),
              ],
            ),
          );
        },
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
            'My Cart',
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

  Widget _buildCafeCard() {
    final cafe = _selectedCafe;

    // Show placeholder if no cafe selected
    if (cafe == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 78,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.store_outlined,
                color: AppColors.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'No cafe selected',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Cafe image (landscape)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 78,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.background,
                image: cafe.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(cafe.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: cafe.imageUrl == null
                  ? const Icon(
                      Icons.store_outlined,
                      color: AppColors.textSecondary,
                      size: 32,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // Cafe name and address
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        cafe.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Open/Closed badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cafe.isOpen
                            ? Colors.green.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cafe.isOpen ? 'Open' : 'Closed',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: cafe.isOpen ? Colors.green : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (cafe.address != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    cafe.address!,
                    style: AppTextStyles.caption.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final walletBalance = authState is AuthAuthenticated
            ? authState.user.walletBalance.toInt()
            : 0;
        final isBalanceSufficient = walletBalance >= _total;

        return CustomPaint(
          painter: DashedBorderPainter(
            color: AppColors.textSecondary.withValues(alpha: 0.4),
            strokeWidth: 1,
            dashWidth: 6,
            dashSpace: 4,
            borderRadius: 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Wallet icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Wallet info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Wallet',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatPrice(walletBalance),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status indicator / Top Up button
                GestureDetector(
                  onTap: isBalanceSufficient
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TopUpPage()),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isBalanceSufficient
                          ? Colors.green.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isBalanceSufficient
                              ? Icons.check_circle_outline_rounded
                              : Icons.add_circle_outline_rounded,
                          size: 16,
                          color: isBalanceSufficient ? Colors.green : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isBalanceSufficient ? 'Sufficient' : 'Top Up',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isBalanceSufficient ? Colors.green : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    final hasOptions = item.options != null;

    return Container(
      margin: EdgeInsets.only(bottom: index < _cartItems.length - 1 ? 12 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product image
          SizedBox(
            width: 70,
            height: 70,
            child: _buildItemImage(item.image),
          ),
          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  item.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                // View Options link
                if (hasOptions) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _showProductDetailsModal(item),
                    child: Text(
                      'View Options',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Price
                Text(
                  _formatPrice(item.unitPrice),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minus or Delete
              GestureDetector(
                onTap: () async {
                  if (item.quantity > 1) {
                    await _cartService.updateQuantity(index, item.quantity - 1);
                    setState(() {});
                  } else {
                    // Show delete confirmation modal
                    _showDeleteConfirmationModal(item, index);
                  }
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item.quantity == 1
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    item.quantity == 1 ? Icons.delete_outline : Icons.remove,
                    size: 14,
                    color: item.quantity == 1
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              // Quantity
              SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    '${item.quantity}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              // Plus
              GestureDetector(
                onTap: () async {
                  await _cartService.updateQuantity(index, item.quantity + 1);
                  setState(() {});
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textPrimary,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promo Code',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Input field and button
          Row(
            children: [
              // Text field
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _promoCodeController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textSecondary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Apply button
              GestureDetector(
                onTap: () {
                  if (_promoCodeController.text.isNotEmpty) {
                    setState(() {
                      _appliedPromoCode = _promoCodeController.text;
                    });
                    // TODO: Validate promo code
                  }
                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Apply',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Applied promo code indicator
          if (_appliedPromoCode != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Promo "$_appliedPromoCode" applied',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _appliedPromoCode = null;
                        _promoCodeController.clear();
                      });
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Total items
          _buildSummaryRow('Items', '$_totalItems item${_totalItems > 1 ? 's' : ''}'),
          const SizedBox(height: 8),

          // Subtotal
          _buildSummaryRow('Subtotal', _formatPrice(_subtotal)),
          const SizedBox(height: 8),

          // Tax
          _buildSummaryRow('Tax (10%)', _formatPrice(_tax)),
          const SizedBox(height: 8),

          // Service fee
          _buildSummaryRow('Service Fee', _formatPrice(_serviceFee)),
          const SizedBox(height: 12),

          _buildSummaryRow('Discount', _formatPrice(0)),
          const SizedBox(height: 12),

          // Divider
          Divider(
            color: AppColors.divider.withValues(alpha: 0.5),
            height: 1,
          ),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _formatPrice(_total),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final isEmpty = _cartItems.isEmpty;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 12,
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
      child: isEmpty
          ? Center(
              child: Text(
                'No products added. Please add products to cart.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : GestureDetector(
              onTap: () => _showCheckoutConfirmationModal(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    'Checkout - ${_formatPrice(_total)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _submitOrder() {
    if (_blocContext == null) return;

    // Check if cafe is selected
    if (_selectedCafe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a cafe first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Build the order items from cart
    final items = _cartItems
        .where((item) => item.productId != null)
        .map((item) => CreateOrderItem(
              productId: item.productId!,
              quantity: item.quantity,
              optionIds: _extractOptionIds(item.options),
            ))
        .toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid items to order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create the order request
    final request = CreateOrderRequest(
      cafeId: _selectedCafe!.id,
      paymentMethod: 'wallet',
      items: items,
    );

    // Submit order through bloc using the stored bloc context
    _blocContext!.read<OrderBloc>().add(OrderCreateRequested(request: request));
  }

  List<int>? _extractOptionIds(Map<String, dynamic>? options) {
    if (options == null) return null;

    final optionIds = <int>[];

    // Extract option IDs if they exist
    if (options['sizeId'] != null) {
      optionIds.add(options['sizeId'] as int);
    }
    if (options['dairyId'] != null) {
      optionIds.add(options['dairyId'] as int);
    }
    if (options['sweetnessId'] != null) {
      optionIds.add(options['sweetnessId'] as int);
    }
    if (options['iceId'] != null) {
      optionIds.add(options['iceId'] as int);
    }

    return optionIds.isEmpty ? null : optionIds;
  }

  void _showCafeClosedModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
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

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.store_rounded,
                      color: AppColors.error,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Store is Closed',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Sorry, ${_selectedCafe?.name ?? 'this store'} is currently closed. Please try again during opening hours or select a different store.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Text(
                          'Got it',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutConfirmationModal() {
    // Check if cafe is selected
    if (_selectedCafe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a cafe first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if cafe is open
    if (!_selectedCafe!.isOpen) {
      _showCafeClosedModal();
      return;
    }

    // Check if wallet balance is sufficient
    final authState = context.read<AuthBloc>().state;
    final walletBalance = authState is AuthAuthenticated
        ? authState.user.walletBalance.toInt()
        : 0;

    if (walletBalance < _total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient wallet balance. Please top up ${_formatPrice(_total - walletBalance)} more.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
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

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Confirm Order',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'You are about to place an order for ${_formatPrice(_total)}. Continue?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Order summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Items',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '$_totalItems item${_totalItems > 1 ? 's' : ''}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Payment',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Awake Wallet',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _formatPrice(_total),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textSecondary.withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
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
                      Expanded(
                        child: GestureDetector(
                          onTap: _isSubmitting ? null : () {
                            Navigator.pop(context);
                            _submitOrder();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _isSubmitting
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Confirm',
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
      ),
    );
  }

  void _showOrderSuccessModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => Container(
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

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                children: [
                  // Success Illustration
                  Image.asset(
                    'assets/images/order_finished.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Order Placed!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Your order has been successfully placed.\nWe\'ll notify you when it\'s ready.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Done button
                  GestureDetector(
                    onTap: () async {
                      // Clear cart and go to orders page
                      await _cartService.clear();
                      Navigator.pop(context); // Close modal
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BrowsePage(initialNavIndex: 3),
                        ),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Text(
                          'Done',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailsModal(CartItem item) {
    final options = item.options;

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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product header
                Row(
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: AppColors.background,
                        child: _buildItemImage(item.image),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Product name and price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatPrice(item.unitPrice),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quantity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Divider
                Divider(
                  color: AppColors.divider.withValues(alpha: 0.5),
                  height: 1,
                ),

                const SizedBox(height: 20),

                // Options Title
                Text(
                  'Selected Options',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                // Size
                if (options != null) ...[
                  _buildOptionRow(
                    'Size',
                    options['size'] ?? 'Regular',
                    (options['sizePrice'] as int? ?? 0) > 0
                        ? '+${_formatPrice(options['sizePrice'] as int)}'
                        : null,
                  ),

                  const SizedBox(height: 12),

                  // Sweetness
                  _buildOptionRow('Sweetness', options['sweetness'] ?? 'Normal', null),

                  const SizedBox(height: 12),

                  // Ice
                  _buildOptionRow('Ice', options['ice'] ?? 'Normal', null),

                  const SizedBox(height: 12),

                  // Dairy
                  _buildOptionRow(
                    'Dairy',
                    options['dairy'] ?? 'Regular Milk',
                    (options['dairyPrice'] as int? ?? 0) > 0
                        ? '+${_formatPrice(options['dairyPrice'] as int)}'
                        : null,
                  ),
                ],

                const SizedBox(height: 20),

                // Close button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        'Close',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(String imagePath) {
    // Check if it's a network image (starts with http) or asset image
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.coffee_rounded,
          size: 32,
          color: AppColors.textSecondary,
        ),
      );
    } else if (imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.coffee_rounded,
          size: 32,
          color: AppColors.textSecondary,
        ),
      );
    } else {
      return const Icon(
        Icons.coffee_rounded,
        size: 32,
        color: AppColors.textSecondary,
      );
    }
  }

  Widget _buildOptionRow(String label, String value, String? price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Label
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 13),
        ),

        // Value and Price
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (price != null) ...[
              const SizedBox(width: 8),
              Text(
                price,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = _createDashedPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source) {
    final dashPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final length = dashWidth;
        if (distance + length > metric.length) {
          dashPath.addPath(
            metric.extractPath(distance, metric.length),
            Offset.zero,
          );
        } else {
          dashPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length + dashSpace;
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
