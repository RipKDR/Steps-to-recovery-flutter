class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const apiAuthToken = String.fromEnvironment(
    'API_AUTH_TOKEN',
    defaultValue: '',
  );
  static const googleAiApiKey = String.fromEnvironment(
    'GOOGLE_AI_API_KEY',
    defaultValue: '',
  );
  static const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  // Supabase configuration
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get hasRemoteSync => apiBaseUrl.isNotEmpty;
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static String get resolvedGoogleAiApiKey =>
      googleAiApiKey.isNotEmpty ? googleAiApiKey : geminiApiKey;

  /// Edge function URL for AI chat (avoids shipping API key on device).
  static String get aiChatEdgeFunctionUrl =>
      hasSupabase ? '$supabaseUrl/functions/v1/chat' : '';
}
