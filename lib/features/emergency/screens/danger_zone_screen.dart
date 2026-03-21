import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Danger Zone screen - Manage risky contacts
class DangerZoneScreen extends StatefulWidget {
  const DangerZoneScreen({super.key});

  @override
  State<DangerZoneScreen> createState() => _DangerZoneScreenState();
}

class _DangerZoneScreenState extends State<DangerZoneScreen> {
  final List<RiskyContact> _contacts = [
    RiskyContact(
      name: 'Using Buddy',
      reason: 'Active user - triggers cravings',
      phone: '(555) 111-2222',
    ),
    RiskyContact(
      name: 'Old Dealer',
      reason: 'Source of substances',
      phone: '(555) 333-4444',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danger Zone'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.danger,
      ),
      body: Column(
        children: [
          // Warning banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: AppColors.danger),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning,
                  color: AppColors.danger,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'These contacts have been flagged as risky. You\'ll be warned before calling them.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contacts list
          Expanded(
            child: _contacts.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return _RiskyContactCard(
                        contact: contact,
                        onRemove: () {
                          setState(() {
                            _contacts.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add risky contact
        },
        backgroundColor: AppColors.danger,
        foregroundColor: AppColors.textOnDark,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RiskyContact {
  final String name;
  final String reason;
  final String phone;

  RiskyContact({
    required this.name,
    required this.reason,
    required this.phone,
  });
}

class _RiskyContactCard extends StatelessWidget {
  final RiskyContact contact;
  final VoidCallback onRemove;

  const _RiskyContactCard({
    required this.contact,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceCard,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.dangerous,
                    color: AppColors.danger,
                    size: AppSpacing.iconLg,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        contact.phone,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.textMuted,
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceInteractive,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: AppSpacing.iconSm,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      contact.reason,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield,
            size: AppSpacing.sext,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No risky contacts',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add contacts that might trigger cravings',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
