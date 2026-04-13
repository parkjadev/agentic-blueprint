/// Environment configuration.
/// API base URL per environment — mapped to the Next.js backend.
/// Supabase credentials per environment.
enum Environment {
  development,
  staging,
  production,
}

class EnvConfig {
  const EnvConfig._({
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.environment,
  });

  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final Environment environment;

  /// Development — local Next.js dev server + Supabase project
  static const development = EnvConfig._(
    apiBaseUrl: 'http://localhost:3000/api',
    supabaseUrl: 'http://127.0.0.1:54321', // TODO: Update with your Supabase project URL
    supabaseAnonKey: 'your-anon-key', // TODO: Update with your Supabase anon key
    environment: Environment.development,
  );

  /// Staging — Vercel staging deployment
  static const staging = EnvConfig._(
    apiBaseUrl: 'https://staging.example.com/api', // TODO: Update URL
    supabaseUrl: 'https://your-project.supabase.co', // TODO: Update URL
    supabaseAnonKey: 'your-anon-key', // TODO: Update key
    environment: Environment.staging,
  );

  /// Production — Vercel production deployment
  static const production = EnvConfig._(
    apiBaseUrl: 'https://example.com/api', // TODO: Update URL
    supabaseUrl: 'https://your-project.supabase.co', // TODO: Update URL
    supabaseAnonKey: 'your-anon-key', // TODO: Update key
    environment: Environment.production,
  );

  /// Current active environment.
  /// Change this to switch environments, or use --dart-define.
  static EnvConfig get current {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    switch (env) {
      case 'staging':
        return staging;
      case 'production':
        return production;
      default:
        return development;
    }
  }

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;
}
