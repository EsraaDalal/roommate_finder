/// Configuration for Supabase Storage integration.
///
/// NOTE:
/// - Only public, client-safe credentials (Project URL and Anon Key) should ever
///   be configured here or passed via `--dart-define`.
/// - NEVER use or expose the Supabase `service_role` secret key in Flutter client code.
/// - Firebase Authentication remains the application's primary authentication system.
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL (e.g. 'https://xyzproject.supabase.co').
  ///
  /// Can be supplied at build/run time via:
  /// `--dart-define=SUPABASE_URL=https://your-project-id.supabase.co`
  /// or set directly in [_defaultUrl] for local development.
  static const String _envUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _defaultUrl = 'https://gvgqlzfvchcyzmmzxsef.supabase.co';

  static String get url => _envUrl.isNotEmpty ? _envUrl : _defaultUrl;

  /// Supabase Anon / Publishable public key.
  ///
  /// Can be supplied at build/run time via:
  /// `--dart-define=SUPABASE_ANON_KEY=your-anon-key`
  /// or set directly in [_defaultAnonKey] for local development.
  static const String _envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _defaultAnonKey = 'sb_publishable_4vFlzmTvXHwEf3P9JjNNlA_XBJYKNQv';

  static String get anonKey =>
      _envAnonKey.isNotEmpty ? _envAnonKey : _defaultAnonKey;

  /// Alias for [anonKey] matching current Supabase client naming.
  static String get publishableKey => anonKey;

  /// Dedicated Supabase Storage bucket name for listing photos.
  static const String listingImagesBucket = 'listing-images';

  /// Name of the Supabase Edge Function that sends push notifications via FCM.
  static const String sendNotificationFunction = 'send-notification';

  /// Whether valid Supabase credentials have been provided.
  static bool get isConfigured =>
      url.trim().isNotEmpty && anonKey.trim().isNotEmpty;
}
