import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Sponsor screen - Manage sponsor connection
class SponsorScreen extends StatelessWidget {
  const SponsorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsor'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Current sponsor card
            _CurrentSponsorCard(),
            const SizedBox(height: AppSpacing.xxl),
            
            // Benefits section
            Text(
              'Benefits of Having a Sponsor',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _BenefitCard(
              icon: Icons.lightbulb,
              title: 'Guidance',
              description: 'Get support from someone who\'s walked the path',
            ),
            const SizedBox(height: AppSpacing.md),
            _BenefitCard(
              icon: Icons.support,
              title: 'Accountability',
              description: 'Stay committed to your recovery goals',
            ),
            const SizedBox(height: AppSpacing.md),
            _BenefitCard(
              icon: Icons.share,
              title: 'Experience',
              description: 'Learn from their experience, strength, and hope',
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Find sponsor button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Find sponsor
                },
                icon: const Icon(Icons.search),
                label: const Text('Find a Sponsor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  foregroundColor: AppColors.textOnDark,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentSponsorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        children: [
          Container(
            width: AppSpacing.quint,
            height: AppSpacing.quint,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.primaryAmber,
              size: AppSpacing.iconLg,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Sponsor Yet',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'A sponsor can provide invaluable guidance on your recovery journey',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnDark.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () {
              // Add sponsor
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textOnDark,
              side: const BorderSide(color: AppColors.white),
            ),
            child: const Text('Add Sponsor'),
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryAmber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryAmber,
                size: AppSpacing.iconLg,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
