import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Meeting Detail screen - Shows meeting information
class MeetingDetailScreen extends StatefulWidget {
  final String meetingId;

  const MeetingDetailScreen({
    super.key,
    required this.meetingId,
  });

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  late Future<Meeting?> _meetingFuture;

  @override
  void initState() {
    super.initState();
    _meetingFuture = _loadMeeting();
  }

  Future<Meeting?> _loadMeeting() async {
    return DatabaseService().getMeetingById(widget.meetingId);
  }

  Future<void> _refreshMeeting() async {
    setState(() {
      _meetingFuture = _loadMeeting();
    });
    await _meetingFuture;
  }

  Future<void> _toggleFavorite(Meeting meeting) async {
    await DatabaseService().toggleMeetingFavorite(meeting.id);
    if (!mounted) {
      return;
    }
    await _refreshMeeting();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          meeting.isFavorite ? 'Removed from favorites' : 'Added to favorites',
        ),
      ),
    );
  }

  Future<void> _shareMeeting(Meeting meeting) async {
    final buffer = StringBuffer()
      ..writeln(meeting.name)
      ..writeln(_meetingTypeLabel(meeting.meetingType))
      ..writeln(_formatDateTime(meeting.dateTime))
      ..writeln(meeting.address?.trim().isNotEmpty == true
          ? meeting.address
          : meeting.location);

    if (meeting.notes?.trim().isNotEmpty == true) {
      buffer.writeln(meeting.notes);
    }

    await Share.share(buffer.toString().trim());
  }

  Future<void> _openDirections(Meeting meeting) async {
    final uri = _buildDirectionsUri(meeting);
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open directions on this device.'),
        ),
      );
    }
  }

  Uri _buildDirectionsUri(Meeting meeting) {
    if (meeting.latitude != null && meeting.longitude != null) {
      return Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${meeting.latitude},${meeting.longitude}',
      );
    }

    final query = Uri.encodeComponent(
      meeting.address?.trim().isNotEmpty == true ? meeting.address! : meeting.location,
    );
    return Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
  }

  void _checkIn(Meeting meeting) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${meeting.name} saved locally as attended.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            tooltip: 'Share meeting',
            icon: const Icon(Icons.share),
            onPressed: () async {
              final meeting = await _meetingFuture;
              if (meeting != null && mounted) {
                await _shareMeeting(meeting);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Meeting?>(
        future: _meetingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAmber),
            );
          }

          final meeting = snapshot.data;
          if (meeting == null) {
            return _MeetingNotFoundState(
              onBack: () => context.pop(),
            );
          }

          final meetingType = _meetingTypeLabel(meeting.meetingType);
          final meetingColor = meeting.meetingType == 'online'
              ? AppColors.info
              : AppColors.success;

          return RefreshIndicator(
            onRefresh: _refreshMeeting,
            color: AppColors.primaryAmber,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          meeting.name,
                          style: AppTypography.displaySmall,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          meeting.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: meeting.isFavorite
                              ? AppColors.primaryAmber
                              : AppColors.textMuted,
                        ),
                        onPressed: () => _toggleFavorite(meeting),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _Badge(
                        icon: Icons.event_available,
                        label: meetingType,
                        color: meetingColor,
                      ),
                      if (meeting.isFavorite)
                        const _Badge(
                          icon: Icons.favorite,
                          label: 'Favorite',
                          color: AppColors.primaryAmber,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _DetailSection(
                    title: 'When',
                    icon: Icons.access_time,
                    children: [
                      _DetailRow(
                        label: 'Date',
                        value: _formatDateTime(meeting.dateTime),
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
                        value: meeting.location,
                      ),
                      if (meeting.address?.trim().isNotEmpty == true)
                        _DetailRow(
                          label: 'Address',
                          value: meeting.address!,
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
                        value: meetingType,
                      ),
                      _DetailRow(
                        label: 'Formats',
                        value: meeting.formats.isEmpty
                            ? 'Not listed'
                            : meeting.formats.join(', '),
                      ),
                    ],
                  ),
                  if (meeting.notes?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _DetailSection(
                      title: 'Notes',
                      icon: Icons.notes,
                      children: [
                        Text(
                          meeting.notes!,
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openDirections(meeting),
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _checkIn(meeting),
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
        },
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSpacing.iconSm,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _MeetingNotFoundState extends StatelessWidget {
  final VoidCallback onBack;

  const _MeetingNotFoundState({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: AppSpacing.sext,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Meeting not found',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'The meeting may have been removed locally.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: onBack,
              child: const Text('Back to meetings'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
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

String _meetingTypeLabel(String type) {
  switch (type) {
    case 'online':
      return 'Online';
    case 'hybrid':
      return 'Hybrid';
    case 'phone':
      return 'Phone';
    default:
      return 'In-Person';
  }
}

String _formatDateTime(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Time not listed';
  }
  return DateFormat('EEEE, MMM d • h:mm a').format(dateTime);
}
