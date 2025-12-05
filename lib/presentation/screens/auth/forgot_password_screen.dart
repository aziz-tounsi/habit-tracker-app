import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/galaxy_background.dart';
import '../../widgets/common/glass_container.dart';

/// Forgot password screen for password reset functionality
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;
  late AnimationController _checkmarkController;

  @override
  void initState() {
    super.initState();
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });
      _checkmarkController.forward();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'An error occurred'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      authProvider.clearError();
    }
  }

  void _backToLogin() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GalaxyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Back button
                    FadeInLeft(
                      duration: const Duration(milliseconds: 400),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: _backToLogin,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: const Icon(
                              Iconsax.arrow_left,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Header
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: _emailSent
                                  ? AppColors.successGradient
                                  : AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (_emailSent
                                          ? AppColors.success
                                          : AppColors.primaryPurple)
                                      .withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                _emailSent ? Iconsax.tick_circle : Iconsax.lock,
                                key: ValueKey(_emailSent),
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.primaryGradient.createShader(bounds),
                            child: Text(
                              _emailSent ? 'Email Sent!' : 'Forgot Password?',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _emailSent
                                ? 'Check your inbox for a password reset link.'
                                : "Don't worry! Enter your email and we'll send you a reset link.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    if (!_emailSent) ...[
                      // Email form
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(24),
                          useBackdropFilter: true,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Email field
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Iconsax.sms,
                                  hint: 'Enter your email',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Send button
                                GestureDetector(
                                  onTap:
                                      authProvider.isLoading ? null : _sendResetLink,
                                  child: Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryPurple
                                              .withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: authProvider.isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Send Reset Link',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Success animation
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(32),
                          useBackdropFilter: true,
                          child: Column(
                            children: [
                              // Animated checkmark
                              AnimatedBuilder(
                                animation: _checkmarkController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 0.5 + (_checkmarkController.value * 0.5),
                                    child: Opacity(
                                      opacity: _checkmarkController.value,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: AppColors.successGradient,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.success
                                                  .withOpacity(0.4),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Iconsax.tick_circle,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'We\'ve sent a password reset link to:',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _emailController.text.trim(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Please check your inbox and follow the instructions to reset your password.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.6),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Back to login
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: _backToLogin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Back to Login',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryPurple.withOpacity(0.5),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error.withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error.withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
