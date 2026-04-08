import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/mindfulness_models.dart';
import '../services/mindfulness_audio_service.dart';

/// Full-screen audio player for mindfulness tracks
class FullScreenAudioPlayer extends StatelessWidget {
  const FullScreenAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MindfulnessAudioService(),
      builder: (context, _) {
        final service = MindfulnessAudioService();
        final track = service.currentTrack;

        if (track == null) {
          return const SizedBox.shrink();
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Now Playing'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  const Spacer(),

                  // Album art / visualization
                  _buildAlbumArt(track),

                  const SizedBox(height: AppSpacing.xxl),

                  // Track info
                  Text(
                    track.title,
                    style: AppTypography.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    track.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAmber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Text(
                      track.category,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryAmber,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Progress bar
                  _buildProgressBar(service),

                  const SizedBox(height: AppSpacing.xl),

                  // Playback controls
                  _buildControls(service),

                  const SizedBox(height: AppSpacing.xl),

                  // Speed and volume controls
                  _buildOptions(service),

                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumArt(MindfulnessTrack track) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryAmber.withValues(alpha: 0.3),
            AppColors.info.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAmber.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          track.mindfulnessCategory.icon,
          size: 120,
          color: AppColors.primaryAmber,
        ),
      ),
    );
  }

  Widget _buildProgressBar(MindfulnessAudioService service) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primaryAmber,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primaryAmber,
            overlayColor: AppColors.primaryAmber.withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: service.position.inSeconds.toDouble(),
            min: 0,
            max: service.duration.inSeconds.toDouble().clamp(
              1,
              double.infinity,
            ),
            onChanged: (value) {
              service.seek(Duration(seconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(service.position),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                _formatDuration(service.duration),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(MindfulnessAudioService service) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip backward
        IconButton(
          icon: const Icon(Icons.replay_10),
          iconSize: 32,
          color: AppColors.textPrimary,
          onPressed: () => service.skipBackward(),
        ),

        const SizedBox(width: AppSpacing.lg),

        // Play/Pause
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAmber.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              service.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 48,
            ),
            color: AppColors.textOnDark,
            onPressed: service.playPause,
          ),
        ),

        const SizedBox(width: AppSpacing.lg),

        // Skip forward
        IconButton(
          icon: const Icon(Icons.forward_10),
          iconSize: 32,
          color: AppColors.textPrimary,
          onPressed: () => service.skipForward(),
        ),
      ],
    );
  }

  Widget _buildOptions(MindfulnessAudioService service) {
    return Column(
      children: [
        // Speed control
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Speed:', style: AppTypography.bodySmall),
            const SizedBox(width: AppSpacing.sm),
            ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
              final isSelected = service.speed == speed;
              return Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: ChoiceChip(
                  label: Text('${speed}x'),
                  selected: isSelected,
                  onSelected: (_) => service.setSpeed(speed),
                  selectedColor: AppColors.primaryAmber,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.textOnDark
                        : AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              );
            }),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Volume control
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.volume_down, size: 20, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Slider(
                value: service.volume,
                min: 0,
                max: 1,
                onChanged: (value) => service.setVolume(value),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.volume_up, size: 20, color: AppColors.textMuted),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
