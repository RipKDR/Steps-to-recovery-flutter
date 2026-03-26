import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/animated_list_item.dart';

/// Meeting Finder screen - Find and filter meetings
class MeetingFinderScreen extends StatefulWidget {
  const MeetingFinderScreen({super.key});

  @override
  State<MeetingFinderScreen> createState() => _MeetingFinderScreenState();
}

class _MeetingFinderScreenState extends State<MeetingFinderScreen> {
  String _selectedFilter = 'All';
  late Future<List<Meeting>> _meetingsFuture;

  final List<String> _filters = const ['All', 'In-Person', 'Online', 'Favorites'];

  @override
  void initState() {
    super.initState();
    _meetingsFuture = _loadMeetings();
  }

  Future<List<Meeting>> _loadMeetings() async {
    return DatabaseService().getMeetings();
  }

  Future<void> _refreshMeetings() async {
    setState(() {
      _meetingsFuture = _loadMeetings();
    });
    await _meetingsFuture;
  }

  List<Meeting> _applyFilter(List<Meeting> meetings) {
    final filtered = meetings.where((meeting) {
      switch (_selectedFilter) {
        case 'In-Person':
          return meeting.meetingType == 'in-person';
        case 'Online':
          return meeting.meetingType == 'online';
        case 'Favorites':
          return meeting.isFavorite;
        default:
          return true;
      }
    }).toList();

    filtered.sort((left, right) {
      if (left.isFavorite != right.isFavorite) {
        return left.isFavorite ? -1 : 1;
      }

      final leftDate = left.dateTime ?? DateTime(2100);
      final rightDate = right.dateTime ?? DateTime(2100);
      return leftDate.compareTo(rightDate);
    });

    return filtered;
  }

  Future<void> _openMeeting(Meeting meeting) async {
    await context.push(
      '${AppRoutes.meetingDetail}?meetingId=${Uri.encodeComponent(meeting.id)}',
    );
    if (!mounted) {
      return;
    }
    await _refreshMeetings();
  }

  Future<void> _toggleFavorite(Meeting meeting) async {
    await DatabaseService().toggleMeetingFavorite(meeting.id);
    if (!mounted) {
      return;
    }
    await _refreshMeetings();
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

  void _showFilters() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filter Meetings', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.primaryAmber.withValues(alpha: 0.18),
                      labelStyle: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.primaryAmber
                            : AppColors.textSecondary,
                      ),
                      onSelected: (selected) {
                        if (!selected) {
                          return;
                        }
                        setState(() {
                          _selectedFilter = filter;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            tooltip: 'Filter meetings',
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: FutureBuilder<List<Meeting>>(
        future: _meetingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAmber),
            );
          }

          final allMeetings = snapshot.data ?? const <Meeting>[];
          final meetings = _applyFilter(allMeetings);

          return RefreshIndicator(
            onRefresh: _refreshMeetings,
            color: AppColors.primaryAmber,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Semantics(
                          selected: isSelected,
                          label: 'Filter by $filter',
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            backgroundColor: AppColors.surfaceInteractive,
                            selectedColor: AppColors.primaryAmber.withValues(alpha: 0.18),
                            labelStyle: AppTypography.labelMedium.copyWith(
                              color: isSelected
                                  ? AppColors.primaryAmber
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        if (meetings.isEmpty)
                          _EmptyMeetingsState(filter: _selectedFilter)
                        else
                          ...meetings.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: AnimatedListItem(
                                index: entry.key,
                                child: _MeetingCard(
                                  meeting: entry.value,
                                  onTap: () => _openMeeting(entry.value),
                                  onFavoriteTap: () => _toggleFavorite(entry.value),
                                ),
                              ),
                            ),
                          ),
                      ],
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

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const _MeetingCard({
    required this.meeting,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final meetingType = _meetingTypeLabel(meeting.meetingType);
    final meetingColor = meeting.meetingType == 'online'
        ? AppColors.info
        : AppColors.success;

    final meetingLabel = '${meeting.name}, ${_meetingTypeLabel(meeting.meetingType)}'
        '${meeting.dateTime != null ? ', ${_formatMeetingTime(meeting.dateTime)}' : ''}';
    return Semantics(
      label: meetingLabel,
      button: true,
      child: Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
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
                      style: AppTypography.titleMedium,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    tooltip: meeting.isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                    icon: Icon(
                      meeting.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: meeting.isFavorite
                          ? AppColors.primaryAmber
                          : AppColors.textMuted,
                    ),
                    onPressed: onFavoriteTap,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: meetingColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      meetingType,
                      style: AppTypography.labelSmall.copyWith(
                        color: meetingColor,
                      ),
                    ),
                  ),
                  if (meeting.isFavorite) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAmber.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        'Favorite',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryAmber,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: AppSpacing.iconSm,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      meeting.address?.trim().isNotEmpty == true
                          ? meeting.address!
                          : meeting.location,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: AppSpacing.iconSm,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      _formatMeetingTime(meeting.dateTime),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (meeting.notes?.trim().isNotEmpty == true) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  meeting.notes!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
              if (meeting.formats.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: meeting.formats.map((format) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceInteractive,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        format,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _EmptyMeetingsState extends StatelessWidget {
  final String filter;

  const _EmptyMeetingsState({
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final description = filter == 'Favorites'
        ? 'Star a meeting to surface it here.'
        : 'No meetings match this filter right now.';

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_note_outlined,
              size: AppSpacing.sext,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No meetings found',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
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

String _formatMeetingTime(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Time not listed';
  }

  final now = DateUtils.dateOnly(DateTime.now());
  final meetingDay = DateUtils.dateOnly(dateTime);
  final formatter = DateFormat('EEE, MMM d • h:mm a');

  if (meetingDay == now) {
    return 'Today • ${DateFormat.jm().format(dateTime)}';
  }
  if (meetingDay == now.add(const Duration(days: 1))) {
    return 'Tomorrow • ${DateFormat.jm().format(dateTime)}';
  }

  return formatter.format(dateTime);
}
