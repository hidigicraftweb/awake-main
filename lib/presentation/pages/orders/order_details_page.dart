import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/order_detail.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/order/order_bloc.dart';
import '../../blocs/order/order_event.dart';
import '../../blocs/order/order_state.dart';

class OrderDetailsPage extends StatelessWidget {
  final int orderId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<OrderBloc>()..add(OrderDetailFetchRequested(orderId: orderId)),
      child: _OrderDetailsContent(orderId: orderId),
    );
  }
}

class _OrderDetailsContent extends StatelessWidget {
  final int orderId;

  const _OrderDetailsContent({required this.orderId});

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

  String _getStatusMessage(String status) {
    switch (status) {
      case 'Pending':
        return 'Waiting kitchen confirmation';
      case 'Preparing':
        return 'Your order is being prepared';
      case 'Finished':
        return 'Order Completed';
      case 'Cancelled':
        return 'Order Cancelled';
      default:
        return 'Order Status';
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderCancelSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Order cancelled successfully',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(20),
            ),
          );
          // Refresh user balance
          context.read<AuthBloc>().add(const AuthCheckRequested());
        } else if (state is OrderReorderSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Order placed successfully!',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(20),
            ),
          );
          // Refresh user balance
          context.read<AuthBloc>().add(const AuthCheckRequested());
          // Navigate to the new order details
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailsPage(orderId: state.newOrder.id),
            ),
          );
        } else if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(20),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, OrderState state) {
    if (state is OrderDetailLoading || state is OrderLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is OrderError) {
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
                state.message,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  context
                      .read<OrderBloc>()
                      .add(OrderDetailFetchRequested(orderId: orderId));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

    if (state is OrderDetailLoaded || state is OrderCancelSuccess) {
      final orderDetail = state is OrderDetailLoaded
          ? state.orderDetail
          : (state as OrderCancelSuccess).orderDetail;
      return _buildOrderDetails(context, orderDetail);
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildOrderDetails(BuildContext context, OrderDetail order) {
    final status = order.displayStatus;
    final statusColor = _getStatusColor(status);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Status Card
          _buildStatusCard(order, status, statusColor),

          const SizedBox(height: 16),

          // Order Info Card
          _buildOrderInfoCard(order),

          const SizedBox(height: 16),

          // Receipt Card (Items + Payment)
          _buildReceiptCard(order),

          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(context, order),
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
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
            'Order Details',
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
    );
  }

  Widget _buildStatusCard(
      OrderDetail order, String status, Color statusColor) {
    final isActive = order.isActive;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusMessage(status),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isActive && order.statusMessage.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: status == 'Preparing' ? 0.6 : 0.2,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    status == 'Preparing' ? AppColors.info : AppColors.warning,
                  ),
                  minHeight: 4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    status == 'Preparing'
                        ? Icons.local_fire_department_rounded
                        : Icons.access_time_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.statusMessage,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
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

  Widget _buildOrderInfoCard(OrderDetail order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Information',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.receipt_outlined,
            label: 'Order ID',
            value: '#AWK${order.id.toString().padLeft(5, '0')}',
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.store_rounded,
            label: 'Cafe',
            value: order.cafe?.name ?? 'Unknown',
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date & Time',
            value: _formatDate(order.createdAt),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Payment',
            value: order.paymentMethod == 'wallet' ? 'Awake Wallet' : order.paymentMethod,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptCard(OrderDetail order) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Items Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Items Ordered',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${order.items.length} items',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...order.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == order.items.length - 1;

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.product?.name ?? 'Unknown'} x${item.quantity}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (item.options.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    item.options
                                        .map((o) => o.name)
                                        .join(', '),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            item.totalAmountFormatted,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (!isLast) ...[
                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          color: AppColors.divider.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),

          _buildNotchedDivider(),

          // Payment Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Summary',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPaymentRow('Subtotal', order.subtotalFormatted),
                const SizedBox(height: 10),
                _buildPaymentRow(
                    'Tax (${order.taxPercentage.toInt()}%)', order.taxAmountFormatted),
                const SizedBox(height: 10),
                _buildPaymentRow('Service Fee', order.serviceFeeFormatted),
                if (order.discount > 0) ...[
                  const SizedBox(height: 10),
                  _buildPaymentRow(
                      'Discount', '- ${order.discountFormatted}',
                      isDiscount: true),
                ],
              ],
            ),
          ),

          _buildNotchedDivider(),

          // Total
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Payment',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  order.grandTotalFormatted,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotchedDivider() {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const dashWidth = 6.0;
                const dashSpace = 4.0;
                final dashCount =
                    (constraints.maxWidth / (dashWidth + dashSpace)).floor();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(dashCount, (_) {
                    return Container(
                      width: dashWidth,
                      height: 1.5,
                      margin: const EdgeInsets.only(right: dashSpace),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          Container(
            width: 12,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDiscount ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderDetail order) {
    final canCancel = order.canCancel;

    return Row(
      children: [
        if (canCancel)
          Expanded(
            child: GestureDetector(
              onTap: () => _showCancelConfirmation(context, order),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.close_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Share receipt
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Share',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _showReorderConfirmation(context, order),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reorder',
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
        ),
      ],
    );
  }

  void _showCancelConfirmation(BuildContext context, OrderDetail order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_outlined,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Cancel Order?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to cancel this order? Your payment will be refunded to your wallet.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(modalContext),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Keep Order',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(modalContext);
                      context
                          .read<OrderBloc>()
                          .add(OrderCancelRequested(orderId: order.id));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Cancel Order',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(modalContext).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showReorderConfirmation(BuildContext context, OrderDetail order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Reorder?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This will create a new order with the same items at ${order.cafe?.name ?? 'the same cafe'}.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${order.grandTotalFormatted}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(modalContext),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(modalContext);
                      context
                          .read<OrderBloc>()
                          .add(OrderReorderRequested(orderId: order.id));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Confirm Reorder',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(modalContext).padding.bottom),
          ],
        ),
      ),
    );
  }
}
