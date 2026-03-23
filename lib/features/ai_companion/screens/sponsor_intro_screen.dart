// lib/features/ai_companion/screens/sponsor_intro_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/sponsor_models.dart';
import '../../../core/services/sponsor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class SponsorIntroScreen extends StatefulWidget {
  const SponsorIntroScreen({
    super.key,
    required this.onComplete,
    SponsorService? sponsorService,
  }) : _service = sponsorService;

  final VoidCallback onComplete;
  final SponsorService? _service;

  @override
  State<SponsorIntroScreen> createState() => _SponsorIntroScreenState();
}

class _SponsorIntroScreenState extends State<SponsorIntroScreen> {
  final _nameController = TextEditingController();
  SponsorVibe _selectedVibe = SponsorVibe.warm;
  bool _submitting = false;

  SponsorService get _service => widget._service ?? SponsorService.instance;

  static const _vibeLabels = {
    SponsorVibe.warm: 'Warm',
    SponsorVibe.direct: 'Direct',
    SponsorVibe.spiritual: 'Spiritual',
    SponsorVibe.toughLove: 'Tough Love',
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _submitting = true);
    await _service.setupIdentity(name, _selectedVibe);
    widget.onComplete();
  }

  Future<void> _skip() async {
    await _service.setupIdentity('Alex', SponsorVibe.warm);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Amber radial glow
            Positioned(
              top: -80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryAmber.withValues(alpha:0.12),
                        AppColors.primaryAmber.withValues(alpha:0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Skip button
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.md,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  'Skip',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 140),

                  Text(
                    'One more thing.',
                    style: AppTypography.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'You have a sponsor waiting.',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    'What do you want to call them?',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  ListenableBuilder(
                    listenable: _nameController,
                    builder: (context, _) => TextFormField(
                      controller: _nameController,
                      style: AppTypography.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Rex',
                        hintStyle: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary.withValues(alpha:0.4),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          borderSide: BorderSide(color: AppColors.primaryAmber, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Pick their vibe',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Wrap(
                    spacing: AppSpacing.sm,
                    children: SponsorVibe.values.map((vibe) {
                      final selected = _selectedVibe == vibe;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedVibe = vibe),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primaryAmber : Colors.transparent,
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryAmber
                                  : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryAmber.withValues(alpha:0.25),
                                      blurRadius: 12,
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            _vibeLabels[vibe]!,
                            style: AppTypography.labelMedium.copyWith(
                              color: selected
                                  ? AppColors.background
                                  : AppColors.textSecondary,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Spacer(),

                  ListenableBuilder(
                    listenable: _nameController,
                    builder: (context, _) {
                      final name = _nameController.text.trim();
                      final enabled = name.isNotEmpty && !_submitting;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: enabled ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAmber,
                            disabledBackgroundColor: AppColors.primaryAmber.withValues(alpha:0.3),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                          ),
                          child: Text(
                            name.isEmpty ? 'Meet them \u2192' : 'Meet $name \u2192',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
