import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Floating bottom navigation bar for Awake Coffee app
/// Selected item shows icon + label, others show icon only
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String? userPhotoUrl;
  final int cartItemCount;
  final VoidCallback? onCartTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.userPhotoUrl,
    this.cartItemCount = 0,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom - 10,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavItem(0, Icons.coffee_rounded, 'Browse'),
              const SizedBox(width: 4),
              _buildNavItem(1, Icons.search_rounded, 'Search'),
              const SizedBox(width: 4),
              _buildCartIcon(), // index 2
              const SizedBox(width: 4),
              _buildNavItem(3, Icons.receipt_long_outlined, 'Orders'),
              const SizedBox(width: 4),
              _buildProfileNavItem(), // index 4
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodySemibold.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNavItem() {
    final isSelected = currentIndex == 4;

    return GestureDetector(
      onTap: () => onTap(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: isSelected ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User photo instead of icon
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: userPhotoUrl != null
                    ? Image.network(
                        userPhotoUrl!,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.person,
                        size: 16,
                        color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
                      ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                'Profile',
                style: AppTextStyles.bodySemibold.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCartIcon() {
    final isSelected = currentIndex == 2; // Cart is index 2

    return GestureDetector(
      onTap: onCartTap ?? () => onTap(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 22,
                  color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
                ),
                // Small red dot indicator (only show when not selected)
                if (cartItemCount > 0 && !isSelected)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                'My Cart',
                style: AppTextStyles.bodySemibold.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
