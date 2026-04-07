/// App-wide constants.
class AppConstants {
  AppConstants._();

  /// App name — displayed in the app bar and about screen.
  static const appName = 'App'; // TODO: Update with your app name

  /// Pagination defaults — must match Next.js API defaults.
  static const defaultPageSize = 20;
  static const maxPageSize = 100;

  /// Token storage keys
  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';

  /// Timeouts
  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 30);

  /// Animation durations
  static const shortAnimation = Duration(milliseconds: 200);
  static const mediumAnimation = Duration(milliseconds: 350);
}
