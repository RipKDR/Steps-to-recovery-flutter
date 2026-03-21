import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Sponsor screen - Manage sponsor connection
class SponsorScreen extends StatefulWidget {
  const SponsorScreen({super.key});

  @override
  State<SponsorScreen> createState() => _SponsorScreenState();
}

class _SponsorScreenState extends State<SponsorScreen> {
  late Future<Contact?> _sponsorFuture;

  @override
  void initState() {
    super.initState();
    _sponsorFuture = _loadSponsor();
  }

  Future<Contact?> _loadSponsor() async {
    final database = DatabaseService();
    final currentUser = await database.getCurrentUser();
    if (currentUser == null) {
      return null;
    }
    return database.getSponsor(currentUser.id);
  }

  Future<void> _refreshSponsor() async {
    setState(() {
      _sponsorFuture = _loadSponsor();
    });
    await _sponsorFuture;
  }

  Future<void> _openSponsorEditor({Contact? sponsor}) async {
    final nameController = TextEditingController(text: sponsor?.name ?? '');
    final phoneController = TextEditingController(text: sponsor?.phoneNumber ?? '');
    final emailController = TextEditingController(text: sponsor?.email ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(sponsor == null ? 'Add Sponsor' : 'Edit Sponsor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved != true) {
      nameController.dispose();
      phoneController.dispose();
      emailController.dispose();
      return;
    }

    final database = DatabaseService();
    final currentUser = await database.getCurrentUser();
    if (currentUser == null) {
      nameController.dispose();
      phoneController.dispose();
      emailController.dispose();
      return;
    }

    await database.saveContact(
      Contact(
        id: sponsor?.id ?? '',
        userId: currentUser.id,
        name: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        relationship: 'sponsor',
        isPrimary: true,
        createdAt: sponsor?.createdAt ?? DateTime.now(),
      ),
    );

    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();

    if (!mounted) {
      return;
    }
    await _refreshSponsor();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sponsor saved locally')),
    );
  }

  Future<void> _deleteSponsor(Contact sponsor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove sponsor?'),
        content: Text('Remove ${sponsor.name} from your local sponsor list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    await DatabaseService().deleteContact(sponsor.id);
    if (!mounted) {
      return;
    }
    await _refreshSponsor();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sponsor removed')),
    );
  }

  Future<void> _launchContact(Uri uri) async {
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the contact action.')),
      );
    }
  }

  Future<void> _callSponsor(Contact sponsor) async {
    await _launchContact(Uri(scheme: 'tel', path: sponsor.phoneNumber));
  }

  Future<void> _emailSponsor(Contact sponsor) async {
    if (sponsor.email == null || sponsor.email!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email address is saved for this sponsor.')),
      );
      return;
    }
    await _launchContact(Uri(
      scheme: 'mailto',
      path: sponsor.email!.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsor'),
        backgroundColor: AppColors.background,
      ),
      body: FutureBuilder<Contact?>(
        future: _sponsorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAmber),
            );
          }

          final sponsor = snapshot.data;

          return RefreshIndicator(
            onRefresh: _refreshSponsor,
            color: AppColors.primaryAmber,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _CurrentSponsorCard(
                  sponsor: sponsor,
                  onAdd: () => _openSponsorEditor(),
                  onEdit: sponsor == null ? null : () => _openSponsorEditor(sponsor: sponsor),
                  onDelete: sponsor == null ? null : () => _deleteSponsor(sponsor),
                  onCall: sponsor == null ? null : () => _callSponsor(sponsor),
                  onEmail: sponsor == null ? null : () => _emailSponsor(sponsor),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Benefits of Having a Sponsor',
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                const _BenefitCard(
                  icon: Icons.lightbulb,
                  title: 'Guidance',
                  description: 'Get support from someone who has walked the path',
                ),
                const SizedBox(height: AppSpacing.md),
                const _BenefitCard(
                  icon: Icons.support,
                  title: 'Accountability',
                  description: 'Stay committed to your recovery goals',
                ),
                const SizedBox(height: AppSpacing.md),
                const _BenefitCard(
                  icon: Icons.share,
                  title: 'Experience',
                  description: 'Learn from their experience, strength, and hope',
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openSponsorEditor(sponsor: sponsor),
                    icon: const Icon(Icons.edit),
                    label: Text(sponsor == null ? 'Add Sponsor' : 'Edit Sponsor'),
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
          );
        },
      ),
    );
  }
}

class _CurrentSponsorCard extends StatelessWidget {
  final Contact? sponsor;
  final VoidCallback onAdd;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCall;
  final VoidCallback? onEmail;

  const _CurrentSponsorCard({
    required this.sponsor,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onCall,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    final hasSponsor = sponsor != null;

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
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasSponsor ? Icons.person : Icons.person_add,
              color: AppColors.primaryAmber,
              size: AppSpacing.iconLg,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            hasSponsor ? sponsor!.name : 'No Sponsor Yet',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textOnDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasSponsor
                ? '${sponsor!.phoneNumber}${sponsor!.email == null ? '' : ' • ${sponsor!.email}'}'
                : 'A sponsor can provide structure, accountability, and support during hard moments.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnDark.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton(
                onPressed: onAdd,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textOnDark,
                  side: const BorderSide(color: AppColors.white),
                ),
                child: Text(hasSponsor ? 'Replace Sponsor' : 'Add Sponsor'),
              ),
              if (hasSponsor && onEdit != null)
                OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textOnDark,
                    side: const BorderSide(color: AppColors.white),
                  ),
                  child: const Text('Edit'),
                ),
              if (hasSponsor && onDelete != null)
                OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textOnDark,
                    side: const BorderSide(color: AppColors.white),
                  ),
                  child: const Text('Remove'),
                ),
            ],
          ),
          if (hasSponsor) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                if (onCall != null)
                  OutlinedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textOnDark,
                      side: const BorderSide(color: AppColors.white),
                    ),
                  ),
                if (onEmail != null && sponsor?.email?.trim().isNotEmpty == true)
                  OutlinedButton.icon(
                    onPressed: onEmail,
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textOnDark,
                      side: const BorderSide(color: AppColors.white),
                    ),
                  ),
              ],
            ),
          ],
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
                color: AppColors.primaryAmber.withValues(alpha: 0.2),
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
