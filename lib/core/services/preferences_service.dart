import 'package:shared_preferences/shared_preferences.dart';

/// Local preferences service for app settings
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  static const String _metricAchievementShareTapped =
      'metric_achievement_share_tapped';
  static const String _metricAchievementShareCompleted =
      'metric_achievement_share_completed';

  SharedPreferences? _prefs;

  /// Initialize preferences
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Onboarding
  bool get isOnboardingComplete => _prefs?.getBool('onboarding_complete') ?? false;
  
  Future<void> setOnboardingComplete() async {
    await initialize();
    await _prefs?.setBool('onboarding_complete', true);
  }

  // Theme
  bool get isDarkMode => _prefs?.getBool('dark_mode') ?? true;
  
  Future<void> setDarkMode(bool value) async {
    await initialize();
    await _prefs?.setBool('dark_mode', value);
  }

  // Notifications
  bool get notificationsEnabled => _prefs?.getBool('notifications_enabled') ?? true;
  
  Future<void> setNotificationsEnabled(bool value) async {
    await initialize();
    await _prefs?.setBool('notifications_enabled', value);
  }

  // Biometric lock
  bool get biometricEnabled => _prefs?.getBool('biometric_enabled') ?? false;
  
  Future<void> setBiometricEnabled(bool value) async {
    await initialize();
    await _prefs?.setBool('biometric_enabled', value);
  }

  // Sobriety date
  DateTime? get sobrietyDate {
    final dateString = _prefs?.getString('sobriety_date');
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }
  
  Future<void> setSobrietyDate(DateTime date) async {
    await initialize();
    await _prefs?.setString('sobriety_date', date.toIso8601String());
  }

  // Program type
  String? get programType => _prefs?.getString('program_type');
  
  Future<void> setProgramType(String value) async {
    await initialize();
    await _prefs?.setString('program_type', value);
  }

  // AI proxy enabled
  bool get aiProxyEnabled => _prefs?.getBool('ai_proxy_enabled') ?? false;
  
  Future<void> setAiProxyEnabled(bool value) async {
    await initialize();
    await _prefs?.setBool('ai_proxy_enabled', value);
  }

  // Check-in reminder times
  String get morningReminderTime => _prefs?.getString('morning_reminder') ?? '08:00';
  String get eveningReminderTime => _prefs?.getString('evening_reminder') ?? '20:00';
  
  Future<void> setMorningReminderTime(String value) async {
    await initialize();
    await _prefs?.setString('morning_reminder', value);
  }
  
  Future<void> setEveningReminderTime(String value) async {
    await initialize();
    await _prefs?.setString('evening_reminder', value);
  }

  Future<int> incrementAchievementShareTapped() async {
    return _incrementCounter(_metricAchievementShareTapped);
  }

  Future<int> incrementAchievementShareCompleted() async {
    return _incrementCounter(_metricAchievementShareCompleted);
  }

  Future<int> getAchievementShareTappedCount() async {
    await initialize();
    return _prefs?.getInt(_metricAchievementShareTapped) ?? 0;
  }

  Future<int> getAchievementShareCompletedCount() async {
    await initialize();
    return _prefs?.getInt(_metricAchievementShareCompleted) ?? 0;
  }

  // Clear all preferences (for logout)
  Future<void> clear() async {
    await initialize();
    await _prefs?.clear();
  }

  Future<int> _incrementCounter(String key) async {
    await initialize();
    final nextValue = (_prefs?.getInt(key) ?? 0) + 1;
    await _prefs?.setInt(key, nextValue);
    return nextValue;
  }
}
