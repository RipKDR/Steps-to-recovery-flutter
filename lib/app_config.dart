class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const apiAuthToken = String.fromEnvironment(
    'API_AUTH_TOKEN',
    defaultValue: '',
  );

  static bool get hasRemoteSync => apiBaseUrl.isNotEmpty;
}
