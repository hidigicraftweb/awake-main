import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    // Refresh wallet balance when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const AuthCheckRequested());
    });
  }

  String _formatPrice(int price) {
    return 'IDR ${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        User? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }

        final walletBalance = user?.walletBalance.toInt() ?? 0;

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
                    children: [
                      // Balance Card
                      _buildBalanceCard(walletBalance),
                      const SizedBox(height: 24),

                      // Quick Actions
                      _buildQuickActions(context),
                      const SizedBox(height: 24),

                      // Recent Transactions
                      _buildRecentTransactions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
            'My Wallet',
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

  Widget _buildBalanceCard(int balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Available Balance',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatPrice(balance),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_rounded,
            label: 'Top Up',
            color: AppColors.primary,
            onTap: () {
              // TODO: Navigate to top up page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Top Up feature coming soon')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.history_rounded,
            label: 'History',
            color: AppColors.textPrimary,
            onTap: () {
              // TODO: Navigate to transaction history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History feature coming soon')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
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

  Widget _buildRecentTransactions() {
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
            'Recent Transactions',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Empty state
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No transactions yet',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
