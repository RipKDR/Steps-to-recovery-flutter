import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Sign Up screen
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _sobrietyDateController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _sobrietyDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome text
              Text(
                'Create your account',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Start your recovery journey with us',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              // Email field
              TextField(
                controller: _emailController,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Password field
              TextField(
                controller: _passwordController,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Confirm password
              TextField(
                controller: _confirmPasswordController,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Sobriety date
              TextField(
                controller: _sobrietyDateController,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'Sobriety Date (optional)',
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'MM/DD/YYYY',
                ),
                readOnly: true,
                onTap: () async {
                  // Show date picker
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Terms agreement
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreeToTerms = !_agreeToTerms;
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'I agree to the ',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primaryAmber,
                              ),
                            ),
                            const TextSpan(
                              text: ' and ',
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primaryAmber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              // Sign up button
              ElevatedButton(
                onPressed: (_agreeToTerms && !_isLoading) ? _signup : null,
                child: _isLoading
                    ? const SizedBox(
                        height: AppSpacing.iconLg,
                        width: AppSpacing.iconLg,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Account'),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: AppTypography.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text('Log In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signup() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate signup
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      // Navigate to onboarding or home
      context.go('/home');
    });
  }
}
