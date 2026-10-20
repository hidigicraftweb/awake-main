import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/order.dart';
import '../../blocs/order/order_bloc.dart';
import '../../blocs/order/order_event.dart';
import '../../blocs/order/order_state.dart';
import 'order_details_page.dart';

class OrdersContent extends StatelessWidget {
  const OrdersContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrderBloc>()..add(const OrdersFetchRequested()),
      child: const _OrdersContentBody(),
    );
  }
}

class _OrdersContentBody extends StatefulWidget {
  const _OrdersContentBody();

  @override
  State<_OrdersContentBody> createState() => _OrdersContentBodyState();
}

class _OrdersContentBodyState extends State<_OrdersContentBody> {
  String _selectedStatus = 'All';
  final ScrollController _scrollController = ScrollController();

  final List<String> _statuses = ['All', 'Preparing', 'Finished', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<OrderBloc>().add(const OrdersLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  String? _getApiStatus(String displayStatus) {
    switch (displayStatus) {
      case 'All':
        return null;
      case 'Preparing':
        return 'preparing';
      case 'Finished':
        return 'finished';
      case 'Cancelled':
        return 'cancelled';
      default:
        return null;
    }
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
    context.read<OrderBloc>().add(
          OrdersFetchRequested(orderStatus: _getApiStatus(status)),
        );
  }

  String _formatPrice(double price) {
    return 'IDR ${price.toInt().toString().replaceAllMapped(
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
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.warning;
      case 'Preparing':
        return AppColors.info;
      case 'Finished':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.access_time_rounded;
      case 'Preparing':
        return Icons.local_fire_department_rounded;
      case 'Finished':
        return Icons.check_circle_rounded;
      case 'Cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context),
        _buildFilters(),
        Expanded(
          child: BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              if (state is OrderLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is OrderError) {
                return _buildErrorState(state.message);
              }

              if (state is OrdersLoaded) {
                if (state.orders.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<OrderBloc>().add(
                          OrdersFetchRequested(
                            orderStatus: _getApiStatus(_selectedStatus),
                            refresh: true,
                          ),
                        );
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    itemCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.orders.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _buildOrderCard(state.orders[index]);
                    },
                  ),
                );
              }

              return _buildNoOrdersYet();
            },
          ),
        ),
      ],
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
      child: Center(
        child: Text(
          'My Orders',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: _statuses.map((status) {
          final isSelected = _selectedStatus == status;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onStatusChanged(status),
              child: Container(
                margin: EdgeInsets.only(
                  right: status != _statuses.last ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.textPrimary : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    status,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoOrdersYet() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/empty_state_no_data.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 24),
          Text(
            'No Orders Yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your order history is empty. Start exploring\nour menu and place your first order\nat any Awake Coffee location.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
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
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your filters or place a new order',
              style: AppTextStyles.caption,
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
                context.read<OrderBloc>().add(
                      OrdersFetchRequested(
                        orderStatus: _getApiStatus(_selectedStatus),
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

  Widget _buildOrderCard(Order order) {
    final status = order.displayStatus;
    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(orderId: order.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Order ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#AWK${order.id.toString().padLeft(5, '0')}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Cafe and Items count
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.totalItems} item${order.totalItems > 1 ? 's' : ''}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (order.cafe != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          order.cafe!.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Cafe icon
                if (order.cafe != null)
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.store_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Divider
            Divider(
              height: 1,
              color: AppColors.divider.withValues(alpha: 0.5),
            ),

            const SizedBox(height: 12),

            // Footer: Date + Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(order.createdAt),
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  _formatPrice(order.grandTotalAmount),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            // Active order indicator
            if (order.isActive && order.statusMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: (order.orderStatus == 'preparing' ? AppColors.info : AppColors.warning).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      order.orderStatus == 'preparing'
                          ? Icons.local_fire_department_rounded
                          : Icons.access_time_rounded,
                      size: 16,
                      color: order.orderStatus == 'preparing' ? AppColors.info : AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.statusMessage,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: order.orderStatus == 'preparing' ? AppColors.info : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
