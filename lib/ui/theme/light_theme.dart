import 'package:flutter/material.dart';

class LightTheme {

  static final ThemeData primaryTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.blueAccent,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold
      ),
      bodyMedium: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
      ),
      bodySmall: TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.bold
      ),
    ),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.white)
        )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        elevation: 5,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.black
          )
      ),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.black
          )
      ),
      errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.red
          )
      ),
      focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.red
          )
      ),
      floatingLabelStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white
    ),
    dividerColor: Colors.black,
    toggleButtonsTheme: ToggleButtonsThemeData(
      fillColor: Colors.blueAccent.withOpacity(0.3),
      selectedBorderColor: Colors.blueAccent,
      borderColor: Colors.black,
      selectedColor: Colors.blueAccent,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.0),
    ),
  );

}