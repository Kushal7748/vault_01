// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

// Vault_01 Dark Palette
const Color _primaryColor = Color(0xFF4FC3F7);
const Color _backgroundColor = Color(0xFF121212);
const Color _surfaceColor = Color(0xFF1E1E1E);
const Color _onPrimaryColor = Colors.black;
const Color _onSurfaceColor = Color(0xFFE0E0E0);

final ThemeData vaultDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _backgroundColor,
  colorScheme: const ColorScheme.dark(
    primary: _primaryColor,
    surface: _surfaceColor,
    onPrimary: _onPrimaryColor,
    onSurface: _onSurfaceColor,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: _surfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: Color(0xFF616161)),
  ),
);
