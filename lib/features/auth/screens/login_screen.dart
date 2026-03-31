import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
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
                  const SizedBox(height: AppSpacing.quint),

                  // Logo
                  Center(
                    child: _buildLogo(reduceMotion),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  _buildTitle(reduceMotion),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSubtitle(reduceMotion),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Email field
                  _buildEmailField(reduceMotion),
                  const SizedBox(height: AppSpacing.xl),

                  // Password field
                  _buildPasswordField(reduceMotion),
                  const SizedBox(height: AppSpacing.md),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.push('/forgot-password');
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Login button
                  _buildLoginButton(reduceMotion),
                  const SizedBox(height: AppSpacing.lg),
                  _buildGuestButton(reduceMotion),
                  const SizedBox(height: AppSpacing.lg),

                  // Sign up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: AppTypography.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/signup');
                        },
                        child: const Text('Sign Up'),
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
      'Steps to Recovery',
      style: AppTypography.displayMedium,
      textAlign: TextAlign.center,
    );
    if (reduceMotion) return widget;
    return widget.animate().fadeIn(duration: 500.ms, delay: 50.ms);
  }

  Widget _buildSubtitle(bool reduceMotion) {
    final widget = Text(
      'Good to see you again.',
      style: AppTypography.bodyLarge.copyWith(
        color: AppColors.textMuted,
      ),
      textAlign: TextAlign.center,
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
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
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
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _login(),
    );
    if (reduceMotion) return field;
    return field
        .animate(delay: 200.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildLoginButton(bool reduceMotion) {
    final button = Semantics(
      label: 'Log in to your account',
      button: true,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                await HapticFeedback.mediumImpact();
                _login();
              },
        child: _isLoading
            ? const SizedBox(
                height: AppSpacing.iconLg,
                width: AppSpacing.iconLg,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Log In'),
      ),
    );
    if (reduceMotion) return button;
    return button
        .animate(delay: 400.ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildGuestButton(bool reduceMotion) {
    final button = OutlinedButton(
      onPressed: _isLoading ? null : _continueAsGuest,
      child: const Text('Continue as Guest'),
    );
    if (reduceMotion) return button;
    return button
        .animate(delay: 500.ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AppStateService.instance.signInAnonymously();
      if (!mounted) {
        return;
      }
      context.go('/home');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    AppStateService.instance
        .signIn(
          email: email,
          password: password,
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
