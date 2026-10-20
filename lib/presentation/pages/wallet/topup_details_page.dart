import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class TopUpDetailsPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TopUpDetailsPage({
    super.key,
    required this.transaction,
  });

  String _formatPrice(int price) {
    return 'IDR ${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String _formatDate(String date) {
    // Date is already formatted as "15 Jan 2024" from wallet_transactions_page
    // Convert abbreviated months to full month names
    final abbreviatedMonths = {
      'Jan': 'January',
      'Feb': 'February',
      'Mar': 'March',
      'Apr': 'April',
      'May': 'May',
      'Jun': 'June',
      'Jul': 'July',
      'Aug': 'August',
      'Sep': 'September',
      'Oct': 'October',
      'Nov': 'November',
      'Dec': 'December',
    };

    String result = date;
    abbreviatedMonths.forEach((abbr, full) {
      result = result.replaceAll(abbr, full);
    });
    return result;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'success':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'success':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.access_time_rounded;
      case 'rejected':
      case 'failed':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'success':
        return 'Top Up Successful';
      case 'pending':
        return 'Waiting';
      case 'rejected':
      case 'failed':
        return 'Top Up Failed';
      default:
        return 'Top Up Status';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = transaction['status'] as String? ?? 'Approved';
    final statusColor = _getStatusColor(status);
    final amount = (transaction['amount'] as int).abs(); // Pure top-up amount added to wallet

    // Get actual values from transaction
    final serviceFee = transaction['serviceFee'] as int? ?? 0;
    final uniqueCode = transaction['uniqueCode'] as int? ?? 0;
    final totalTransfer = transaction['totalAmount'] as int? ?? (amount + serviceFee - uniqueCode);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // App Bar
          _buildAppBar(context),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Status Card
                  _buildStatusCard(status, statusColor),

                  const SizedBox(height: 16),

                  // Top Up Info Card
                  _buildTopUpInfoCard(),

                  const SizedBox(height: 16),

                  // Receipt Card
                  _buildReceiptCard(amount, serviceFee, uniqueCode, totalTransfer),

                  const SizedBox(height: 24),

                  // Action Button
                  _buildActionButton(context),
                ],
              ),
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
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
            'Top Up Details',
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

  Widget _buildStatusCard(String status, Color statusColor) {
    final isPending = status.toLowerCase() == 'pending';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Main status area
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Status Icon
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

                // Status info
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

                // Amount
                Text(
                  _formatPrice((transaction['amount'] as int).abs()),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          // Pending message
          if (isPending) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your top up is being verified by our admin',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
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

  Widget _buildTopUpInfoCard() {
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
          // Section Title
          Text(
            'Transaction Information',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Transaction ID
          _buildInfoRow(
            icon: Icons.receipt_outlined,
            label: 'Transaction ID',
            value: '#${transaction['id']}',
          ),
          const SizedBox(height: 14),

          // Date
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: _formatDate(transaction['date']),
          ),
          const SizedBox(height: 14),

          // Time
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: transaction['time'],
          ),
          const SizedBox(height: 14),

          // Payment Method
          _buildInfoRow(
            icon: Icons.account_balance_rounded,
            label: 'Payment Method',
            value: transaction['description'] ?? 'Bank Transfer',
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

  Widget _buildReceiptCard(int amount, int serviceFee, int uniqueCode, int totalTransfer) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Up Details Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Up Summary',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Top Up',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Wallet Balance Added
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.success,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet Balance Added',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+${_formatPrice(amount)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notched divider
          _buildNotchedDivider(),

          // Payment Breakdown Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Breakdown',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                _buildPaymentRow('Top Up Amount', _formatPrice(amount)),
                const SizedBox(height: 10),
                _buildPaymentRow('Service Fee', _formatPrice(serviceFee)),
                const SizedBox(height: 10),
                _buildPaymentRow('Unique Code', '- ${_formatPrice(uniqueCode)}', isDeduction: true),
              ],
            ),
          ),

          // Notched divider before total
          _buildNotchedDivider(),

          // Total Transfer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Transfer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _formatPrice(totalTransfer),
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
          // Left notch
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
          // Dashed line
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dashWidth = 6.0;
                final dashSpace = 4.0;
                final dashCount = (constraints.maxWidth / (dashWidth + dashSpace)).floor();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(dashCount, (_) {
                    return Container(
                      width: dashWidth,
                      height: 1.5,
                      margin: EdgeInsets.only(right: dashSpace),
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
          // Right notch
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

  Widget _buildPaymentRow(String label, String value, {bool isDeduction = false}) {
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
            color: isDeduction ? AppColors.error : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Back to Transactions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
