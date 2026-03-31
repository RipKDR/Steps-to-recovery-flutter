import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/haptic_feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Onboarding screen — cinematic redesign with Rat Park framing
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.self_improvement_outlined,
      title: 'What are you\nworking through?',
      description:
          'Whatever brought you here — you\'re in the right place. No labels required.',
      accentColor: AppColors.primaryAmber,
    ),
    _OnboardingPage(
      icon: Icons.spa_outlined,
      title: 'Build your\nRat Park',
      description:
          'The opposite of addiction is connection. Every day here is a day building a life worth living.',
      accentColor: AppColors.accentTeal,
    ),
    _OnboardingPage(
      icon: Icons.menu_book_outlined,
      title: 'Your journey,\nyour pace',
      description:
          'Track progress, reflect daily, work the steps — or just show up. All paths welcome.',
      accentColor: AppColors.primaryAmber,
    ),
    _OnboardingPage(
      icon: Icons.psychology_outlined,
      title: 'An AI that\nactually listens',
      description:
          'Your AI companion learns your patterns, your voice, and when you need a nudge.',
      accentColor: AppColors.accentBlue,
    ),
    _OnboardingPage(
      icon: Icons.lock_outline,
      title: 'Private by design',
      description:
          'Your data is encrypted end-to-end. The server never sees your recovery. Only you do.',
      accentColor: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await AppStateService.instance.completeOnboarding();
    if (!mounted) {
      return;
    }
    context.go('/signup');
  }

  void _handlePageChanged(int index) {
    HapticFeedbackService().selectionClick();
    setState(() {
      _currentPage = index;
    });
  }

  void _handleButtonTap() {
    HapticFeedbackService().lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final currentAccent = _pages[_currentPage].accentColor;
    final isLastPage = _currentPage == _pages.length - 1;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Layer 1: Ambient radial glow — changes per page
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.4),
                radius: 0.8,
                colors: [
                  currentAccent.withValues(alpha: 0.04),
                  AppColors.background,
                ],
              ),
            ),
          ),

          // Layer 2: Page content
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, index) {
              return _OnboardingPageContent(
                page: _pages[index],
                isActive: index == _currentPage,
                disableAnimations: disableAnimations,
              );
            },
          ),

          // Layer 3: Skip button (top-right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: AppSpacing.lg,
            child: AnimatedOpacity(
              opacity: isLastPage ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: isLastPage,
                child: Semantics(
                  label: 'Skip onboarding',
                  button: true,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedbackService().lightImpact();
                      _completeOnboarding();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Layer 4: Bottom controls (dots + button)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + AppSpacing.xl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Page indicator dots
                Semantics(
                  label: 'Page ${_currentPage + 1} of ${_pages.length}',
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: const WormEffect(
                      dotColor: AppColors.surfaceInteractive,
                      activeDotColor: AppColors.primaryAmber,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 12,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // CTA button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: _buildButton(
                      context,
                      isLastPage: isLastPage,
                      disableAnimations: disableAnimations,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required bool isLastPage,
    required bool disableAnimations,
  }) {
    final button = isLastPage
        ? Semantics(
            label: 'Begin your journey',
            button: true,
            child: ElevatedButton(
              onPressed: _handleButtonTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAmber,
                foregroundColor: AppColors.textOnDark,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md + 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                elevation: 0,
              ),
              child: Text(
                'Begin Your Journey',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnDark,
                ),
              ),
            ),
          )
        : Semantics(
            label: 'Continue to next page',
            button: true,
            child: OutlinedButton(
              onPressed: _handleButtonTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryAmber,
                side: const BorderSide(
                  color: AppColors.primaryAmber,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md + 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              child: Text(
                'Continue',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryAmber,
                ),
              ),
            ),
          );

    if (disableAnimations) return button;

    return button.animate(delay: 450.ms).fadeIn(duration: 300.ms);
  }
}

/// Per-page content with entrance animations keyed to page index
class _OnboardingPageContent extends StatelessWidget {
  final _OnboardingPage page;
  final bool isActive;
  final bool disableAnimations;

  const _OnboardingPageContent({
    required this.page,
    required this.isActive,
    required this.disableAnimations,
  });

  @override
  Widget build(BuildContext context) {
    final bottomControlsHeight = 160.0 + MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: bottomControlsHeight,
        top: MediaQuery.of(context).padding.top + AppSpacing.quint,
      ),
      child: Container(
        key: ValueKey<int>(isActive ? 1 : 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(disableAnimations),
            const SizedBox(height: AppSpacing.xxxl),
            _buildTitle(disableAnimations),
            const SizedBox(height: AppSpacing.lg),
            _buildDescription(disableAnimations),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(bool disableAnimations) {
    final icon = Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            page.accentColor.withValues(alpha: 0.18),
            page.accentColor.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: page.accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: page.accentColor.withValues(alpha: 0.15),
            blurRadius: 32,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(page.icon, size: 56, color: Colors.white),
    );

    if (disableAnimations) return icon;

    return icon
        .animate()
        .scale(
          begin: const Offset(0.7, 0.7),
          curve: Curves.elasticOut,
          duration: 600.ms,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildTitle(bool disableAnimations) {
    final title = Text(
      page.title,
      style: AppTypography.displayMedium.copyWith(
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );

    if (disableAnimations) return title;

    return title
        .animate(delay: 200.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.15, end: 0, duration: 500.ms);
  }

  Widget _buildDescription(bool disableAnimations) {
    final desc = Text(
      page.description,
      style: AppTypography.bodyLarge.copyWith(
        color: AppColors.textMuted,
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    );

    if (disableAnimations) return desc;

    return desc.animate(delay: 350.ms).fadeIn(duration: 500.ms);
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}
