import 'package:flutter/material.dart';

class DarkTheme {
  static final ThemeData primaryTheme = ThemeData(
    brightness: Brightness.dark,

    // overall backgrounds
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: Colors.black,
    cardTheme: CardThemeData(
      color: Colors.black,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // AppBar & drawer
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF121212),
    ),

    // Core colors
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,           // main “ink” color
      onPrimary: Colors.black,         // for text/icons on white
      secondary: Color(0xFF90CAF9),    // a soft sky-blue accent
      onSecondary: Colors.black,
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
      error: Colors.redAccent,
      onError: Colors.black,
    ),

    // Text styles
    textTheme: const TextTheme(
      headlineSmall: TextStyle(  // page title
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 20),
      bodyMedium: TextStyle(color: Colors.white60, fontSize: 18),
      bodySmall: TextStyle(color: Colors.white54, fontSize: 14),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF90CAF9), // secondary
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF90CAF9),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),           // dark input background
      contentPadding: const EdgeInsets.symmetric(
        vertical: 20, horizontal: 16,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF90CAF9),
        fontWeight: FontWeight.bold,
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1C1C1C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      elevation: 12,
    ),

    // Icon theme
    iconTheme: const IconThemeData(color: Colors.white70),

    // Divider (e.g. in Stepper connectors)
    dividerColor: Colors.white24,

  );
}