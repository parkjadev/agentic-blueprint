/// Route path constants.
/// Centralised here to avoid magic strings throughout the app.
class Routes {
  Routes._();

  // Auth
  static const login = '/login';
  static const register = '/register';

  // Main
  static const home = '/';
  static const profile = '/profile';

  // Example CRUD
  static const examples = '/examples';
  static String exampleDetail(String id) => '/examples/$id';
}
