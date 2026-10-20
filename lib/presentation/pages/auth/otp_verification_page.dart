import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../browse/browse_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final bool isLoginOtp;

  const OtpVerificationPage({
    super.key,
    required this.email,
    this.isLoginOtp = false,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isResendEnabled = false;
  int _resendCountdown = 60;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // OTP is already sent during registration/login API call
    // No need to send again here - just start the countdown for resend
    _startResendCountdown();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _sendOtp() {
    context.read<AuthBloc>().add(AuthSendOtpRequested(email: widget.email));
  }

  void _startResendCountdown() {
    setState(() {
      _isResendEnabled = false;
      _resendCountdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _isResendEnabled = true;
        }
      });
      return _resendCountdown > 0;
    });
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  bool get _isOtpComplete => _otpCode.length == 6;

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyPressed(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _otpControllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _handleVerify() {
    if (_isOtpComplete && !_isLoading) {
      if (widget.isLoginOtp) {
        // Login 2FA - verify and get auth token
        context.read<AuthBloc>().add(
              AuthVerifyLoginOtpRequested(
                email: widget.email,
                code: _otpCode,
              ),
            );
      } else {
        // Registration email verification
        context.read<AuthBloc>().add(
              AuthVerifyOtpRequested(
                email: widget.email,
                code: _otpCode,
              ),
            );
      }
    }
  }

  void _handleResendOtp() {
    if (!_isResendEnabled || _isLoading) return;
    _sendOtp();
    _startResendCountdown();
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        if (state is AuthOtpVerified) {
          _showSuccess('Email verified successfully!');
          // Refresh user data to get updated email_verified_at
          context.read<AuthBloc>().add(const AuthCheckRequested());
        } else if (state is AuthAuthenticated) {
          // Navigate to browse page (for both login 2FA and registration verification)
          _showSuccess(widget.isLoginOtp ? 'Login successful!' : 'Email verified successfully!');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const BrowsePage()),
            (route) => false,
          );
        } else if (state is AuthOtpSent) {
          _showSuccess('OTP sent to ${widget.email}');
        } else if (state is AuthError) {
          _showError(state.message);
          _clearOtpFields();
        }
      },
      builder: (context, state) {
        _isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildIllustration(),
                      const SizedBox(height: 24),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildOtpFields(),
                      const SizedBox(height: 32),
                      _buildVerifyButton(),
                      const SizedBox(height: 24),
                      _buildResendSection(),
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
            'Verification',
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

  Widget _buildIllustration() {
    return Image.asset(
      'assets/images/check_otp_awake.png',
      width: 200,
      height: 200,
      fit: BoxFit.contain,
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          widget.isLoginOtp ? 'Verify Your Login' : 'Check Your Email',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.isLoginOtp
              ? 'Enter the verification code sent to'
              : 'We have sent a verification code to',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          widget.email,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return GestureDetector(
          onTap: _isLoading ? null : () => _focusNodes[index].requestFocus(),
          child: Container(
            width: 48,
            height: 48,
            margin: EdgeInsets.only(
              right: index < 5 ? 10 : 0,
            ),
            decoration: BoxDecoration(
              color: _isLoading ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focusNodes[index].hasFocus
                    ? AppColors.primary
                    : _otpControllers[index].text.isNotEmpty
                        ? AppColors.primary
                        : AppColors.divider.withValues(alpha: 0.5),
                width: _focusNodes[index].hasFocus ? 2 : 1.5,
              ),
            ),
            child: Center(
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) => _onKeyPressed(event, index),
                child: SizedBox(
                  width: 24,
                  child: TextFormField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    cursorHeight: 20,
                    enabled: !_isLoading,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      filled: false,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) => _onOtpChanged(value, index),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    final canVerify = _isOtpComplete && !_isLoading;

    return GestureDetector(
      onTap: canVerify ? _handleVerify : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: canVerify
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Verify',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          "Didn't receive the code?",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: (_isResendEnabled && !_isLoading) ? _handleResendOtp : null,
          child: Text(
            _isResendEnabled ? 'Resend Code' : 'Resend in ${_resendCountdown}s',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: (_isResendEnabled && !_isLoading)
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
