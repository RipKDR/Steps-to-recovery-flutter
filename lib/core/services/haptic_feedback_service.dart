import 'package:flutter/services.dart';

/// Haptic feedback service for tactile interactions.
///
/// Provides consistent haptic feedback across the app.
/// All methods respect system accessibility settings.
///
/// Usage:
/// ```dart
/// // On button tap
/// HapticFeedbackService().lightImpact();
///
/// // On milestone celebration
/// HapticFeedbackService().mediumImpact();
///
/// // On slider/selection change
/// HapticFeedbackService().selectionClick();
/// ```
class HapticFeedbackService {
  static final HapticFeedbackService _instance = HapticFeedbackService._internal();
  factory HapticFeedbackService() => _instance;
  HapticFeedbackService._internal();

  /// Light haptic feedback for standard button taps
  void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for important confirmations
  /// Use for: milestone celebrations, completed actions
  void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for destructive/major actions
  /// Use for: delete confirmations, sign out
  void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click for slider changes, picker selections
  /// Use for: CravingSlider, MoodRating, settings toggles
  void selectionClick() {
    HapticFeedback.selectionClick();
  }
}
