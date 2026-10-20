import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/user.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../auth/get_started_page.dart';
import '../cart/cart_page.dart';
import '../wallet/wallet_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _formatCompactNumber(int number) {
    if (number >= 1000000000) {
      double val = number / 1000000000;
      return val == val.roundToDouble() ? '${val.toInt()}B' : '${val.toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      double val = number / 1000000;
      return val == val.roundToDouble() ? '${val.toInt()}M' : '${val.toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      double val = number / 1000;
      return val == val.roundToDouble() ? '${val.toInt()}K' : '${val.toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatPrice(int price) {
    return 'IDR ${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Navigate to get started page on logout
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const GetStartedPage()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        // Get user from auth state
        User? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Column(
                children: [
                  // App Bar
                  _buildAppBar(context),

                  // Content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<AuthBloc>().add(const AuthCheckRequested());
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // Profile Header with Stats
                            _buildProfileHeader(user),

                            // Menu Items
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                              child: Column(
                                children: [
                                  // Wallet Card
                                  _buildWalletCard(context, user),
                                  const SizedBox(height: 16),

                                  // Menu Group
                                  _buildMenuGroup(),
                                  const SizedBox(height: 16),

                                  // Logout Button
                                  _buildLogoutButton(context),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Navigation Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomNavBar(
                  currentIndex: 4,
                  cartItemCount: CartService().itemCount,
                  onTap: (index) {
                    if (index != 4) {
                      Navigator.pop(context);
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
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Avatar and Info
          Row(
            children: [
              // Profile photo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  color: AppColors.background,
                ),
                child: ClipOval(
                  child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                      ? Image.network(
                          user.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultAvatar(user.name),
                        )
                      : _buildDefaultAvatar(user?.name ?? 'U'),
                ),
              ),
              const SizedBox(width: 14),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Guest',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: AppTextStyles.caption.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Edit button
              GestureDetector(
                onTap: () {
                  // TODO: Edit profile
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats Row - TODO: Fetch from backend API
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildStatItem('0', 'Orders'),
                _buildStatDivider(),
                _buildStatItem(_formatCompactNumber(0), 'Spent'),
                _buildStatDivider(),
                _buildStatItem('0', 'Items'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.textSecondary.withValues(alpha: 0.3),
    );
  }

  Widget _buildWalletCard(BuildContext context, User? user) {
    final walletBalance = user?.walletBalance.toInt() ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalletPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Wallet icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 22,
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
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatPrice(walletBalance),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Top up button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Top Up',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroup() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.receipt_long_outlined,
            title: 'Order History',
            onTap: () {},
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Saved Addresses',
            onTap: () {},
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.favorite_outline_rounded,
            title: 'Favorites',
            onTap: () {},
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textPrimary,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: AppColors.divider.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutConfirmation(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => Container(
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
                      Icons.logout_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Log Out?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Are you sure you want to log out?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(modalContext),
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
                          onTap: () {
                            Navigator.pop(modalContext);
                            // Dispatch logout event
                            context.read<AuthBloc>().add(const AuthLogoutRequested());
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: Text(
                                'Log Out',
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
}
