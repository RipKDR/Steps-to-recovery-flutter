import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Meeting Detail screen - Shows meeting information
class MeetingDetailScreen extends StatelessWidget {
  final String meetingId;

  const MeetingDetailScreen({
    super.key,
    required this.meetingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Toggle favorite
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share meeting
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meeting name
            Text(
              'Morning Serenity Group',
              style: AppTypography.displaySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Meeting type badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: AppSpacing.iconSm,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'In-Person Meeting',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Meeting details
            _DetailSection(
              title: 'When',
              icon: Icons.access_time,
              children: [
                _DetailRow(
                  label: 'Day',
                  value: 'Monday, Wednesday, Friday',
                ),
                _DetailRow(
                  label: 'Time',
                  value: '7:00 AM - 8:00 AM',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            _DetailSection(
              title: 'Where',
              icon: Icons.location_on,
              children: [
                _DetailRow(
                  label: 'Location',
                  value: 'Community Center',
                ),
                _DetailRow(
                  label: 'Address',
                  value: '123 Recovery Lane, City, State 12345',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            _DetailSection(
              title: 'Format',
              icon: Icons.info_outline,
              children: [
                _DetailRow(
                  label: 'Type',
                  value: 'Discussion',
                ),
                _DetailRow(
                  label: 'Open/Closed',
                  value: 'Open',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Get directions
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Check in
                    },
                    icon: const Icon(Icons.event_available),
                    label: const Text('Check In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAmber,
                      foregroundColor: AppColors.textOnDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: AppSpacing.iconMd,
              color: AppColors.primaryAmber,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
