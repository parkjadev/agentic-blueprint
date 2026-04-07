import 'package:flutter/material.dart';

/// Convenience extensions on BuildContext for common lookups.
extension ContextExtensions on BuildContext {
  /// Current theme data.
  ThemeData get theme => Theme.of(this);

  /// Current colour scheme.
  ColorScheme get colours => theme.colorScheme;

  /// Current text theme.
  TextTheme get textTheme => theme.textTheme;

  /// Media query data.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Screen size.
  Size get screenSize => mediaQuery.size;

  /// Show a snackbar with a message.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colours.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show an error snackbar.
  void showError(String message) => showSnackBar(message, isError: true);

  /// Show a success snackbar.
  void showSuccess(String message) => showSnackBar(message);
}
