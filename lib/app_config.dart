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

  // Sentry crash reporting
  static const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
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

  // OpenClaw gateway — direct path when Supabase edge functions are not used.
  // In production, set OPENCLAW_GATEWAY_URL and OPENCLAW_GATEWAY_TOKEN as
  // Supabase edge function secrets (not dart-defines) so they stay off-device.
  static const openclawGatewayUrl = String.fromEnvironment(
    'OPENCLAW_GATEWAY_URL',
    defaultValue: '',
  );
  static const openclawGatewayToken = String.fromEnvironment(
    'OPENCLAW_GATEWAY_TOKEN',
    defaultValue: '',
  );

  static bool get hasRemoteSync => apiBaseUrl.isNotEmpty;
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasOpenClaw =>
      openclawGatewayUrl.isNotEmpty && openclawGatewayToken.isNotEmpty;
  
  /// Check if direct Google AI API key is configured (NOT recommended for production)
  /// This should only be used for local development
  static bool get hasDirectGoogleAiKey =>
      googleAiApiKey.isNotEmpty || geminiApiKey.isNotEmpty;
  
  /// Get resolved Google AI API key (only for development)
  static String get resolvedGoogleAiApiKey =>
      googleAiApiKey.isNotEmpty ? googleAiApiKey : geminiApiKey;

  /// Edge function URL for AI chat (avoids shipping API key on device).
  /// 
  /// Priority: Supabase edge function → OpenClaw direct → Google AI direct (dev only)
  /// 
  /// SECURITY: In production, always use edge functions to keep API keys server-side.
  /// Direct Google AI calls should only be used for local development.
  static String get aiChatEdgeFunctionUrl {
    // Prefer Supabase edge function (API key stays server-side)
    if (hasSupabase) {
      return '$supabaseUrl/functions/v1/chat';
    }
    // Fall back to OpenClaw gateway (also keeps key server-side)
    if (hasOpenClaw) {
      return openclawGatewayUrl;
    }
    // WARNING: Direct API key usage - only for development
    // In production, this should never be used
    return '';
  }
  
  /// Check if server-side AI is available (preferred for production)
  static bool get hasServerSideAi => hasSupabase || hasOpenClaw;
}
