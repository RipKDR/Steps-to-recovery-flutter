// Example: Using Haptic Feedback
// Perfect for crisis button, craving slider, mood ratings

import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

/// Crisis button with haptic feedback
/// 
/// Usage:
/// ```dart
/// HapticCrisisButton(onPressed: () => _handleEmergency())
/// ```
class HapticCrisisButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HapticCrisisButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        // Heavy impact on press down (anticipation)
        HapticFeedback.heavyImpact();
      },
      onTap: onPressed,
      onTapUp: (_) {
        // Success feedback on release
        HapticFeedback.success();
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.emergency,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Craving slider with haptic feedback
/// 
/// Provides tactile feedback as user slides through craving levels
class HapticCravingSlider extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final double initialValue;

  const HapticCravingSlider({
    super.key,
    required this.onChanged,
    this.initialValue = 0,
  });

  @override
  State<HapticCravingSlider> createState() => _HapticCravingSliderState();
}

class _HapticCravingSliderState extends State<HapticCravingSlider> {
  double _value = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.amber,
            inactiveTrackColor: Colors.amber.withOpacity(0.3),
            thumbColor: Colors.amber,
            overlayColor: Colors.amber.withOpacity(0.2),
          ),
          child: Slider(
            value: _value,
            divisions: 10,
            label: _value.round().toString(),
            onChanged: (value) {
              setState(() {
                _value = value;
              });
              
              // Light impact on each division change
              HapticFeedback.lightImpact();
              
              widget.onChanged(value);
            },
            onChangeEnd: (value) {
              // Medium impact when user finishes sliding
              HapticFeedback.mediumImpact();
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('No craving', style: Theme.of(context).textTheme.bodySmall),
            Text('Strong craving', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

/// Mood rating with haptic feedback
class HapticMoodRating extends StatelessWidget {
  final int selectedRating;
  final ValueChanged<int> onRatingChanged;

  const HapticMoodRating({
    super.key,
    required this.selectedRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final rating = index + 1;
        return GestureDetector(
          onTap: () {
            // Selection click for each tap
            HapticFeedback.selectionClick();
            
            // Success feedback when rating is selected
            if (rating == selectedRating) {
              HapticFeedback.lightImpact();
            }
            
            onRatingChanged(rating);
          },
          child: Icon(
            _getMoodIcon(rating),
            size: 40,
            color: rating <= selectedRating ? Colors.amber : Colors.grey,
          ),
        );
      }),
    );
  }

  IconData _getMoodIcon(int rating) {
    switch (rating) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
    }
  }
}

/// Checkbox with haptic feedback
class HapticCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const HapticCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Light impact on toggle
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      child: Icon(
        value ? Icons.check_box : Icons.check_box_outline_blank,
        color: value ? Colors.amber : Colors.grey,
      ),
    );
  }
}

/// Button with haptic feedback
class HapticButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const HapticButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
      },
      onTap: isLoading ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey : Colors.amber,
          borderRadius: BorderRadius.circular(8),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

// Example usage in a screen:
//
// // Crisis button
// HapticCrisisButton(
//   onPressed: () {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => EmergencyScreen()));
//   },
// );
//
// // Craving check-in
// HapticCravingSlider(
//   onChanged: (value) {
//     setState(() => _cravingLevel = value);
//   },
// );
//
// // Mood rating
// HapticMoodRating(
//   selectedRating: _moodRating,
//   onRatingChanged: (rating) => setState(() => _moodRating = rating),
// );
