import 'package:flutter/material.dart';

final class LightTheme {
  static final ThemeData primaryTheme = ThemeData(
    brightness: Brightness.light,

    // overall backgrounds
    scaffoldBackgroundColor: const Color(0xFFEDEDED),
    cardColor: Colors.white,

    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Color(0xFF1E88E5),
      onSecondary: Colors.white,
      surface: Color(0xFFF8F8F8),       // slightly lifted from scaffold
      onSurface: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
    ),

    // AppBar sits flat on the grey background
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F5F5),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),

    // Text styles
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: Colors.black,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: Colors.black, fontSize: 20),
      bodyMedium: TextStyle(color: Colors.black87, fontSize: 18),
      bodySmall: TextStyle(color: Colors.black54, fontSize: 14),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1E88E5),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1E88E5), width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF1E88E5),
        fontWeight: FontWeight.bold,
      ),
    ),

    // Icons (including our cloud/avatar)
    iconTheme: const IconThemeData(color: Colors.black87),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      elevation: 12,
    ),


    // Dividers inside the stepper, etc.
    dividerColor: Colors.grey.shade900,
  );
}