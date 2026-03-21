import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Onboarding screen - First-time user introduction
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.self_improvement,
      title: 'Welcome to Steps to Recovery',
      description: 'Your companion for working the 12 steps and maintaining sobriety.',
    ),
    _OnboardingPage(
      icon: Icons.edit,
      title: 'Journal Your Journey',
      description: 'Track your progress with daily check-ins, journal entries, and step work.',
    ),
    _OnboardingPage(
      icon: Icons.people,
      title: 'Find Support',
      description: 'Connect with meetings, sponsors, and a supportive community.',
    ),
    _OnboardingPage(
      icon: Icons.psychology,
      title: 'AI Companion',
      description: 'Get personalized support from an AI that understands your recovery journey.',
    ),
    _OnboardingPage(
      icon: Icons.security,
      title: 'Private & Secure',
      description: 'Your data is encrypted and stored locally. Your privacy is our priority.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Skip'),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPageContent(page: page);
                },
              ),
            ),
            
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  width: isActive ? AppSpacing.lg : AppSpacing.sm,
                  height: AppSpacing.sm,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryAmber
                        : AppColors.surfaceInteractive,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAmber,
                    foregroundColor: AppColors.textOnDark,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    await AppStateService.instance.completeOnboarding();
    if (!mounted) {
      return;
    }
    context.go('/signup');
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _OnboardingPageContent extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
            ),
            child: Icon(
              page.icon,
              size: AppSpacing.iconXxl,
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            page.title,
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            page.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
