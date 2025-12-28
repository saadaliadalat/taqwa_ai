/// Environment configuration for Taqwa AI
/// 
/// Supports development, staging, and production environments
enum Environment { dev, staging, prod }

class EnvConfig {
  static Environment _environment = Environment.dev;
  
  static Environment get environment => _environment;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  /// API Base URL
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'http://localhost:5001/taqwa-ai/us-central1/api';
      case Environment.staging:
        return 'https://us-central1-taqwa-ai-staging.cloudfunctions.net/api';
      case Environment.prod:
        return 'https://us-central1-taqwa-ai.cloudfunctions.net/api';
    }
  }
  
  /// Quran API URL
  static String get quranApiUrl {
    return 'https://api.alquran.cloud/v1';
  }
  
  /// App name
  static String get appName {
    switch (_environment) {
      case Environment.dev:
        return 'Taqwa AI (Dev)';
      case Environment.staging:
        return 'Taqwa AI (Staging)';
      case Environment.prod:
        return 'Taqwa AI';
    }
  }
  
  /// Is production
  static bool get isProduction => _environment == Environment.prod;
  
  /// Is development
  static bool get isDevelopment => _environment == Environment.dev;
  
  /// Enable debug logging
  static bool get enableLogging => !isProduction;
  
  /// Enable analytics
  static bool get enableAnalytics => isProduction;
  
  /// Request timeout in seconds
  static int get requestTimeout => isProduction ? 30 : 60;
  
  /// Max retry attempts for failed requests
  static int get maxRetryAttempts => 3;
  
  /// Retry delay in milliseconds
  static int get retryDelayMs => 1000;
}
