import 'package:flutter/material.dart';

/// Holds the current theme mode for the app.
///
/// A lightweight [ChangeNotifier] singleton so any screen can read or change
/// the theme without a state management package or circular imports between
/// `main.dart` and the Profile screen.
class ThemeController extends ChangeNotifier {
  ThemeController();

  static final ThemeController instance = ThemeController();

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (_mode == mode) {
      return;
    }
    _mode = mode;
    notifyListeners();
  }
}
