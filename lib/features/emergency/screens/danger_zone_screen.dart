import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/empty_state.dart';

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
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Warning banner
            Semantics(
            liveRegion: true,
            label: 'Warning: These contacts have been flagged as risky. You will be warned before calling them.',
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(color: AppColors.danger),
                ),
              ),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: const Icon(
                      Icons.warning,
                      color: AppColors.danger,
                    ),
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
          ),

          // Contacts list
          Expanded(
            child: _contacts.isEmpty
                ? EmptyState(
                    icon: Icons.shield,
                    title: 'No risky contacts',
                    message: 'Add contacts that might trigger cravings',
                  )
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
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Add risky contact',
        child: FloatingActionButton(
          onPressed: () {
            // Add risky contact
          },
          backgroundColor: AppColors.danger,
          foregroundColor: AppColors.textOnDark,
          tooltip: 'Add risky contact',
          child: const Icon(Icons.add),
        ),
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
    return Semantics(
      label: 'Risky contact: ${contact.name}. ${contact.phone}. Reason: ${contact.reason}',
      child: Card(
        color: AppColors.surfaceCard,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: const Icon(
                        Icons.dangerous,
                        color: AppColors.danger,
                        size: AppSpacing.iconLg,
                      ),
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
                    tooltip: 'Remove ${contact.name} from risky contacts',
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
                    ExcludeSemantics(
                      child: const Icon(
                        Icons.info_outline,
                        size: AppSpacing.iconSm,
                        color: AppColors.warning,
                      ),
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
      ),
    );
  }
}

