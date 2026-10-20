import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/wallet_transaction.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../orders/order_details_page.dart';
import 'topup_page.dart';
import 'topup_details_page.dart';

class WalletTransactionsPage extends StatelessWidget {
  const WalletTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WalletBloc>()..add(const WalletTransactionsFetchRequested()),
      child: const _WalletTransactionsContent(),
    );
  }
}

class _WalletTransactionsContent extends StatefulWidget {
  const _WalletTransactionsContent();

  @override
  State<_WalletTransactionsContent> createState() => _WalletTransactionsContentState();
}

class _WalletTransactionsContentState extends State<_WalletTransactionsContent> {
  String _selectedFilter = 'All';
  final ScrollController _scrollController = ScrollController();

  final List<String> _filters = ['All', 'Top Up', 'Purchase', 'Refund'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Refresh wallet balance when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const AuthCheckRequested());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<WalletBloc>().add(const WalletTransactionsLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  String? _getApiType(String displayFilter) {
    switch (displayFilter) {
      case 'All':
        return null;
      case 'Top Up':
        return 'topup';
      case 'Purchase':
        return 'payment';
      case 'Refund':
        return 'refund';
      default:
        return null;
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    context.read<WalletBloc>().add(
          WalletTransactionsFetchRequested(type: _getApiType(filter)),
        );
  }

  // Get wallet balance from auth state
  int get _walletBalance {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.walletBalance.toInt();
    }
    return 0;
  }

  String _formatPrice(int price, {bool isTopup = false}) {
    final formatted = price.abs().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '${isTopup ? '+' : '-'}IDR $formatted';
  }

  String _formatBalance(int price) {
    return 'IDR ${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with balance
          _buildHeader(context),

          // Content
          Expanded(
            child: BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                if (state is WalletLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is WalletError) {
                  return _buildErrorState(state.message);
                }

                if (state is WalletTransactionsLoaded) {
                  if (state.transactions.isEmpty && state.currentTypeFilter == null) {
                    return _buildNoTransactionsYet();
                  }

                  return Column(
                    children: [
                      // Filter chips
                      _buildFilterChips(),

                      // Transactions list
                      Expanded(
                        child: state.transactions.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                onRefresh: () async {
                                  // Refresh wallet balance
                                  context.read<AuthBloc>().add(const AuthCheckRequested());
                                  // Refresh transactions list
                                  context.read<WalletBloc>().add(
                                        WalletTransactionsFetchRequested(
                                          type: _getApiType(_selectedFilter),
                                          refresh: true,
                                        ),
                                      );
                                },
                                child: _buildTransactionsList(state),
                              ),
                      ),
                    ],
                  );
                }

                return _buildNoTransactionsYet();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(WalletTransactionsLoaded state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: state.transactions.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.transactions.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final transaction = state.transactions[index];
        final showDateHeader = index == 0 ||
            _formatDate(state.transactions[index - 1].createdAt) !=
                _formatDate(transaction.createdAt);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) ...[
              if (index > 0) const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _formatDate(transaction.createdAt),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            _buildTransactionCard(transaction),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // App bar
          Row(
            children: [
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
              Text(
                'Wallet Transactions',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 20),

          // Balance card - Wallet Mockup Style
          SizedBox(
            width: double.infinity,
            height: 230,
            child: Stack(
              children: [
                // Back card - Black
                Positioned(
                  left: 20,
                  top: 0,
                  right: 0,
                  bottom: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles on black card
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 20,
                          top: 20,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        // Card chip icon
                        Positioned(
                          left: 20,
                          top: 20,
                          child: Container(
                            width: 40,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Container(
                                width: 30,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.amber.shade700,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Awake text on black card
                        Positioned(
                          right: 20,
                          bottom: 20,
                          child: Text(
                            'AWAKE',
                            style: GoogleFonts.knewave(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.3),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Front card - Red/Primary
                Positioned(
                  left: 0,
                  top: 30,
                  right: 20,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles on red card
                        Positioned(
                          left: -40,
                          bottom: -40,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Current Balance',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.account_balance_wallet_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Wallet',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Balance Amount
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, authState) {
                                  final walletBalance = authState is AuthAuthenticated
                                      ? authState.user.walletBalance.toInt()
                                      : 0;
                                  return Text(
                                    _formatBalance(walletBalance),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                              // Bottom row with Top Up button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'AWAKE COFFEE',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withValues(alpha: 0.6),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const TopUpPage()),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add_rounded,
                                            color: AppColors.primary,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Top Up',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () => _onFilterChanged(filter),
              child: Container(
                margin: EdgeInsets.only(
                  right: filter != _filters.last ? 10 : 0,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.textPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(WalletTransaction transaction) {
    final isTopUp = transaction.type == 'topup';
    final isRefund = transaction.type == 'refund';
    final isCredit = isTopUp || isRefund; // Money coming in
    final isPending = transaction.status == 'pending';

    // Determine icon color based on type and status
    Color iconColor;
    if (isTopUp) {
      iconColor = isPending ? AppColors.warning : AppColors.success;
    } else if (isRefund) {
      iconColor = AppColors.success;
    } else {
      iconColor = AppColors.primary;
    }

    // Build title based on type
    String title;
    String description;
    if (isTopUp) {
      title = 'Wallet Top Up';
      description = 'Via Bank Transfer';
    } else if (isRefund) {
      title = 'Order Refund';
      description = 'Order cancelled - refunded';
    } else {
      title = 'Order Payment';
      description = transaction.totalAmountFormatted;
    }

    return GestureDetector(
      onTap: () {
        if (isTopUp) {
          // Navigate to TopUp Details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TopUpDetailsPage(
                transaction: {
                  'id': transaction.id,
                  'type': transaction.type,
                  'status': _getDisplayStatus(transaction.status),
                  'amount': transaction.amount, // Pure top-up amount added to wallet
                  'totalAmount': transaction.totalAmount, // Total transfer amount
                  'uniqueCode': transaction.uniqueCode ?? 0,
                  'serviceFee': transaction.serviceFee ?? 0,
                  'proofOfPaymentUrl': transaction.proofOfPaymentUrl,
                  'date': _formatDate(transaction.createdAt),
                  'time': _formatTime(transaction.createdAt),
                },
              ),
            ),
          );
        } else if ((isRefund || transaction.type == 'payment') && transaction.orderId != null) {
          // Navigate to Order Details for payment/refund transactions
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(orderId: transaction.orderId!),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isTopUp
                    ? (isPending ? Icons.access_time_rounded : Icons.add_rounded)
                    : (isRefund ? Icons.replay_rounded : Icons.shopping_bag_outlined),
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.bodySemibold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPending) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Pending',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Amount and time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  // For top-up/refund: show amount (what gets added to wallet)
                  // For payment: show totalAmount (what was paid)
                  _formatPrice(isCredit ? transaction.amount : transaction.totalAmount, isTopup: isCredit),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isPending
                        ? AppColors.warning
                        : (isCredit ? AppColors.success : AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(transaction.createdAt),
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Widget _buildNoTransactionsYet() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Illustration
          Image.asset(
            'assets/images/empty_state_no_data.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'No Transactions Yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'Your wallet is ready! Start by topping up\nyour balance to enjoy seamless payments\nat any Awake Coffee location.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Top Up Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TopUpPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Top Up Now',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              'No Transactions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No transactions found for this filter',
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

  Widget _buildErrorState(String message) {
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
              'Something went wrong',
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
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                context.read<WalletBloc>().add(
                      WalletTransactionsFetchRequested(
                        type: _getApiType(_selectedFilter),
                      ),
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
}
