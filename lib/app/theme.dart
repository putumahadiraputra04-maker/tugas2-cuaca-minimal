import 'package:flutter/material.dart';

/// Satu warna utama. Selebihnya hanya putih dan hitam.
const Color kPrimary = Color(0xFF0F766E);
const Color kBorder = Color(0x1F000000); // hitam 12%
const Color kMuted = Color(0x99000000); // hitam 60%

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: kPrimary,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimary,
        side: const BorderSide(color: kPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
