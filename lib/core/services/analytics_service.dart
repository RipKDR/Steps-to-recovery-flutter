import 'package:shared_preferences/shared_preferences.dart';

import 'logger_service.dart';

/// Privacy-respecting analytics service.
///
/// Tracks only non-sensitive usage events: screen views, feature usage counts,
/// session duration. Never tracks: content, mood, craving levels, journal text,
/// step answers, or any recovery-specific data.
///
/// Users can opt out via Settings.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static const String _keyOptOut = 'analytics_opt_out';
  final _logger = LoggerService();

  SharedPreferences? _prefs;
  bool _optedOut = false;
  bool _initialized = false;

  bool get isOptedOut => _optedOut;

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _optedOut = _prefs?.getBool(_keyOptOut) ?? false;
    _initialized = true;
  }

  Future<void> setOptOut(bool value) async {
    _optedOut = value;
    await _prefs?.setBool(_keyOptOut, value);
  }

  /// Log a screen view event.
  void trackScreenView(String screenName) {
    if (_optedOut) return;
    _logger.debug('[analytics] screen=$screenName');
    // In production: send to Supabase edge function or PostHog
  }

  /// Log a feature usage event.
  void trackFeatureUsed(String featureName) {
    if (_optedOut) return;
    _logger.debug('[analytics] feature=$featureName');
  }

  /// Log a non-sensitive event with optional metadata.
  /// Never include recovery content in [properties].
  void trackEvent(String name, {Map<String, String>? properties}) {
    if (_optedOut) return;
    _logger.debug('[analytics] event=$name props=$properties');
  }
}
