import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../core/services/app_state_service.dart';
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
  DateTime? _sobrietyDate;

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
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: AppColors.background,
      ),
      body: Stack(
        children: [
          // Ambient top-left glow
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primaryAmber.withValues(alpha: 0.06),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Ambient bottom-right glow
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primaryAmberLight.withValues(alpha: 0.04),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo hero
                  Center(child: _buildLogo(reduceMotion)),
                  const SizedBox(height: AppSpacing.xl),

                  // Welcome text
                  _buildTitle(reduceMotion),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSubtitle(reduceMotion),
                  const SizedBox(height: AppSpacing.xxl),

                  // Email field
                  _buildEmailField(reduceMotion),
                  const SizedBox(height: AppSpacing.xl),

                  // Password field
                  _buildPasswordField(reduceMotion),
                  const SizedBox(height: AppSpacing.xl),

                  // Confirm password
                  _buildConfirmPasswordField(reduceMotion),
                  const SizedBox(height: AppSpacing.xl),

                  // Sobriety date
                  _buildSobrietyDateField(reduceMotion),
                  const SizedBox(height: AppSpacing.xl),

                  // Terms agreement
                  _buildTermsRow(reduceMotion),
                  const SizedBox(height: AppSpacing.xxl),

                  // Sign up button
                  _buildSignupButton(reduceMotion),
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
        ],
      ),
    );
  }

  Widget _buildLogo(bool reduceMotion) {
    final logo = Container(
      width: AppSpacing.quint,
      height: AppSpacing.quint,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primaryAmber.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAmber.withValues(alpha: 0.3),
            blurRadius: 24,
          ),
        ],
      ),
      child: const Icon(Icons.self_improvement, size: 40, color: Colors.white),
    );

    if (reduceMotion) return logo;

    return logo
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          curve: Curves.elasticOut,
          duration: 700.ms,
        )
        .fadeIn(duration: 500.ms);
  }

  Widget _buildTitle(bool reduceMotion) {
    final widget = Text(
      'Create your account',
      style: AppTypography.headlineMedium,
    );
    if (reduceMotion) return widget;
    return widget.animate().fadeIn(duration: 500.ms, delay: 50.ms);
  }

  Widget _buildSubtitle(bool reduceMotion) {
    final widget = Text(
      'Start your recovery journey with us',
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textMuted,
      ),
    );
    if (reduceMotion) return widget;
    return widget.animate().fadeIn(duration: 500.ms, delay: 150.ms);
  }

  Widget _buildEmailField(bool reduceMotion) {
    final field = TextField(
      controller: _emailController,
      style: AppTypography.bodyMedium,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    );
    if (reduceMotion) return field;
    return field
        .animate(delay: 100.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildPasswordField(bool reduceMotion) {
    final field = TextField(
      controller: _passwordController,
      style: AppTypography.bodyMedium,
      autofillHints: const [AutofillHints.newPassword],
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
    );
    if (reduceMotion) return field;
    return field
        .animate(delay: 200.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildConfirmPasswordField(bool reduceMotion) {
    final field = TextField(
      controller: _confirmPasswordController,
      style: AppTypography.bodyMedium,
      autofillHints: const [AutofillHints.newPassword],
      decoration: const InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: Icon(Icons.lock_outline),
      ),
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
    );
    if (reduceMotion) return field;
    return field
        .animate(delay: 300.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildSobrietyDateField(bool reduceMotion) {
    final field = Semantics(
      label: _sobrietyDate == null
          ? 'Select sobriety date, optional, tap to open date picker'
          : 'Sobriety date: ${_sobrietyDateController.text}, tap to change',
      button: true,
      child: TextField(
        controller: _sobrietyDateController,
        style: AppTypography.bodyMedium,
        decoration: const InputDecoration(
          labelText: 'Sobriety Date (optional)',
          prefixIcon: Icon(Icons.calendar_today),
          hintText: 'MM/DD/YYYY',
        ),
        readOnly: true,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            initialDate: _sobrietyDate ??
                DateTime.now().subtract(const Duration(days: 30)),
          );
          if (picked != null) {
            setState(() {
              _sobrietyDate = picked;
              _sobrietyDateController.text =
                  '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
            });
          }
        },
      ),
    );
    if (reduceMotion) return field;
    return field
        .animate(delay: 400.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildTermsRow(bool reduceMotion) {
    final row = Row(
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
    );
    if (reduceMotion) return row;
    return row.animate(delay: 500.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildSignupButton(bool reduceMotion) {
    final button = Semantics(
      label: 'Create your account',
      button: true,
      child: ElevatedButton(
        onPressed: (_agreeToTerms && !_isLoading)
            ? () async {
                await HapticFeedback.mediumImpact();
                _signup();
              }
            : null,
        child: _isLoading
            ? const SizedBox(
                height: AppSpacing.iconLg,
                width: AppSpacing.iconLg,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Create Account'),
      ),
    );
    if (reduceMotion) return button;
    return button
        .animate(delay: 600.ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  void _signup() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required.')),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    AppStateService.instance
        .signUp(
          email: email,
          password: password,
          sobrietyDate: _sobrietyDate,
        )
        .then((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _isLoading = false;
          });
          context.go('/home');
        })
        .catchError((Object error) {
          if (!mounted) {
            return;
          }
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        });
  }
}
