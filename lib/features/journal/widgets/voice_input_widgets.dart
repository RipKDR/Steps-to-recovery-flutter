import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/services/voice_recording_service.dart';

/// Voice input button for journal dictation
class VoiceInputButton extends StatefulWidget {
  final void Function(String text)? onRecognizedText;
  final void Function(String text)? onFinalText;

  const VoiceInputButton({
    super.key,
    this.onRecognizedText,
    this.onFinalText,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final _service = VoiceRecordingService();
  bool _isInitialized = false;
  bool _isAvailable = false;
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _isInitialized = await _service.initialize();
    _isAvailable = await _service.isAvailable();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (!_isAvailable) {
      return Tooltip(
        message: 'Speech recognition not available',
        child: IconButton(
          icon: const Icon(Icons.mic_off),
          onPressed: null,
          color: AppColors.textMuted,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final isListening = _service.isListening;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice input button
            GestureDetector(
              onTap: () => _toggleVoiceInput(),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isListening
                      ? const LinearGradient(
                          colors: [AppColors.danger, AppColors.danger],
                        )
                      : const LinearGradient(
                          colors: AppColors.primaryGradient,
                        ),
                  shape: BoxShape.circle,
                  boxShadow: isListening
                      ? [
                          BoxShadow(
                            color: AppColors.danger.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: AppColors.primaryAmber.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                ),
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  color: AppColors.textOnDark,
                  size: 24,
                ),
              ),
            ),

            // Live transcription preview
            if (isListening && _currentText.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                constraints: const BoxConstraints(maxWidth: 200),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  _currentText,
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Status indicator
            if (isListening) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Listening...',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _toggleVoiceInput() async {
    if (_service.isListening) {
      await _service.stopListening();
      if (widget.onFinalText != null && _currentText.isNotEmpty) {
        widget.onFinalText!(_currentText);
      }
      _currentText = '';
    } else {
      _currentText = '';
      await _service.startListening(
        onResult: (text) {
          setState(() => _currentText = text);
          if (widget.onRecognizedText != null) {
            widget.onRecognizedText!(text);
          }
        },
      );
    }
    if (mounted) setState(() {});
  }
}

/// Audio recording button for journal voice notes
class AudioRecordButton extends StatefulWidget {
  final void Function(String? path)? onRecordingComplete;

  const AudioRecordButton({
    super.key,
    this.onRecordingComplete,
  });

  @override
  State<AudioRecordButton> createState() => _AudioRecordButtonState();
}

class _AudioRecordButtonState extends State<AudioRecordButton> {
  final _service = VoiceRecordingService();
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    _hasPermission = await _service.hasPermission();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Tooltip(
        message: 'Microphone permission not granted',
        child: IconButton(
          icon: const Icon(Icons.mic_off),
          onPressed: null,
          color: AppColors.textMuted,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final isRecording = _service.isRecording;
        final duration = _service.getFormattedDuration();

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Recording duration
            if (isRecording)
              Text(
                duration,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.danger,
                  fontFamily: 'monospace',
                ),
              ),

            // Record button
            GestureDetector(
              onTap: isRecording ? _stopRecording : _startRecording,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isRecording
                      ? const LinearGradient(
                          colors: [AppColors.danger, AppColors.danger],
                        )
                      : const LinearGradient(
                          colors: [AppColors.info, AppColors.info],
                        ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording ? AppColors.danger : AppColors.info)
                          .withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.stop : Icons.fiber_manual_record,
                  color: AppColors.textOnDark,
                  size: 24,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startRecording() async {
    try {
      await _service.startRecording();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start recording'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _service.stopRecording();
      if (widget.onRecordingComplete != null) {
        widget.onRecordingComplete!(path);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice note saved'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save recording'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}
