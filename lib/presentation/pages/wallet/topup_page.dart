import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/wallet_topup_info.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../blocs/wallet/wallet_state.dart';

class TopUpPage extends StatelessWidget {
  const TopUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WalletBloc>()..add(const WalletTopupInfoRequested()),
      child: const _TopUpPageContent(),
    );
  }
}

class _TopUpPageContent extends StatefulWidget {
  const _TopUpPageContent();

  @override
  State<_TopUpPageContent> createState() => _TopUpPageContentState();
}

class _TopUpPageContentState extends State<_TopUpPageContent> {
  int? _selectedAmount;
  int _uniqueCode = 0;
  File? _uploadedImage;
  String? _uploadedFileName;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  WalletTopupInfo? _topupInfo;

  int get _serviceFee => _topupInfo?.serviceFee ?? 1000;
  int get _maxUniqueCode => _topupInfo?.maxUniqueCode ?? 200;

  void _generateUniqueCode() {
    setState(() {
      _uniqueCode = Random().nextInt(_maxUniqueCode) + 1; // 1 to maxUniqueCode
    });
  }

  final List<int> _defaultAmounts = [
    50000,
    100000,
    150000,
    200000,
    250000,
    500000,
    1000000,
    2500000,
  ];

  String _formatPrice(int price) {
    return 'IDR ${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String _formatCompactPrice(int price) {
    if (price >= 1000000) {
      double val = price / 1000000;
      return val == val.roundToDouble() ? '${val.toInt()}M' : '${val.toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      double val = price / 1000;
      return val == val.roundToDouble() ? '${val.toInt()}K' : '${val.toStringAsFixed(1)}K';
    }
    return price.toString();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text.replaceAll(' ', '')));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied to clipboard',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 20),
            Text(
              'Upload Proof of Payment',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Camera option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Take Photo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Use camera to capture receipt',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Gallery option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.photo_library_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose from Gallery',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Select image from photo library',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _uploadedImage = File(pickedFile.path);
          _uploadedFileName = pickedFile.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to pick image: $e',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  void _submitTopUp() {
    if (_selectedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select an amount',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
        ),
      );
      return;
    }

    if (_uploadedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please upload proof of payment',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
        ),
      );
      return;
    }

    // Show confirmation modal
    _showConfirmationModal();
  }

  void _showConfirmationModal() {
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
                Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Confirm Top Up',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please transfer exactly',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _formatPrice(_selectedAmount! + _serviceFee - _uniqueCode),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Top up amount: ${_formatPrice(_selectedAmount!)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
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
                      _submitTopUpRequest();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Confirm',
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

  void _submitTopUpRequest() {
    context.read<WalletBloc>().add(
          WalletTopupRequested(
            amount: _selectedAmount!,
            uniqueCode: _uniqueCode,
            proofOfPayment: _uploadedImage,
          ),
        );
  }

  void _showSuccessModal(String formattedAmount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Top Up Request Submitted',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your top up request of $formattedAmount is being processed. We\'ll notify you once it\'s confirmed.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(modalContext); // Close modal
                Navigator.pop(context); // Go back to previous page
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(modalContext).padding.bottom),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletTopupInfoLoaded) {
          setState(() {
            _topupInfo = state.topupInfo;
          });
          _generateUniqueCode();
        } else if (state is WalletTopupSuccess) {
          setState(() {
            _isSubmitting = false;
          });
          // Refresh user data to update wallet balance
          context.read<AuthBloc>().add(const AuthCheckRequested());
          _showSuccessModal(state.transaction.totalAmountFormatted);
        } else if (state is WalletError) {
          setState(() {
            _isSubmitting = false;
          });
          _showError(state.message);
        } else if (state is WalletLoading) {
          // Only show submitting state when we have topup info (not initial load)
          if (_topupInfo != null) {
            setState(() {
              _isSubmitting = true;
            });
          }
        }
      },
      builder: (context, state) {
        // Show loading while fetching topup info
        if (state is WalletLoading && _topupInfo == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                _buildHeader(context),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Header
              _buildHeader(context),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wallet Mockup Card
                      _buildWalletMockup(),
                      const SizedBox(height: 24),

                      // Amount Selection
                      _buildAmountSection(),
                      const SizedBox(height: 24),

                      // Price Breakdown
                      if (_selectedAmount != null) ...[
                        _buildPriceBreakdown(),
                        const SizedBox(height: 24),
                      ],

                      // Bank Transfer Details
                      _buildBankTransferSection(),
                      const SizedBox(height: 24),

                      // Upload Proof of Payment
                      _buildUploadSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildWalletMockup() {
    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
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
                              'Top Up Amount',
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
                                  Icon(
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
                        // Amount (Top Up Amount - what user gets in wallet)
                        Text(
                          _selectedAmount != null
                              ? _formatPrice(_selectedAmount!)
                              : 'IDR 0',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        // Bottom row
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
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 30,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
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
            'Top Up Wallet',
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

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Amount',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose how much you want to top up',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: _defaultAmounts.length,
          itemBuilder: (context, index) {
            final amount = _defaultAmounts[index];
            final isSelected = _selectedAmount == amount;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAmount = amount;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _formatCompactPrice(amount),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    final total = _selectedAmount! + _serviceFee - _uniqueCode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Top Up Amount
          _buildPriceRow('Top Up Amount', _formatPrice(_selectedAmount!), false),
          const SizedBox(height: 12),

          // Service Fee
          _buildPriceRow(
              'Service Fee', _topupInfo?.serviceFeeFormatted ?? _formatPrice(_serviceFee), false),
          const SizedBox(height: 12),

          // Unique Code
          _buildPriceRow(
              'Unique Code',
              '- ${_formatPrice(_uniqueCode)}',
              false,
              isRed: true),

          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AppColors.textSecondary.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),

          // Total
          _buildPriceRow('Total Transfer', _formatPrice(total), true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isBold,
      {bool isRed = false, bool isSecondary = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: isRed
                ? AppColors.error
                : isSecondary
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
            fontStyle: isSecondary ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferSection() {
    final bankAccounts = _topupInfo?.bankAccounts ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank Transfer',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Transfer to one of our bank accounts',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (bankAccounts.isEmpty)
            Text(
              'Loading bank accounts...',
              style: AppTextStyles.caption,
            )
          else
            ...bankAccounts.map((bank) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildBankCard(bank),
                )),
        ],
      ),
    );
  }

  Widget _buildBankCard(BankAccount bank) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bank.bankName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => _copyToClipboard(bank.accountNumber),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bank.accountNumber,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bank.accountName,
            style: AppTextStyles.caption.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proof of Payment',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload your transfer receipt or screenshot',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _uploadedImage != null
                      ? AppColors.success
                      : AppColors.textSecondary.withValues(alpha: 0.3),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: _uploadedImage != null
                  ? Column(
                      children: [
                        // Image preview
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: Image.file(
                            _uploadedImage!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Image Uploaded',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      _uploadedFileName ?? '',
                                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Change',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_upload_outlined,
                              color: AppColors.textSecondary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Upload File',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'JPG, PNG or PDF (max 5MB)',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isEnabled = _selectedAmount != null && _uploadedImage != null && !_isSubmitting;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: isEnabled ? _submitTopUp : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: _isSubmitting
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Text(
                  'Submit Top Up Request',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isEnabled ? Colors.white : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
