import 'package:flutter/material.dart';

class Themes {

  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white, // Explicit drawer background color
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

  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF101110),
    scaffoldBackgroundColor: const Color(0xFF101110),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF101110),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF101110),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF101110),
      onPrimary: Colors.white,
      secondary: Colors.grey,
    ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: Colors.grey.shade200,
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
        bodyMedium: TextStyle(
          color: Colors.grey.shade200,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
        bodySmall: TextStyle(
          color: Colors.grey.shade200,
          fontSize: 13,
          fontWeight: FontWeight.bold
        ),
      ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(Colors.grey.shade50)
      )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 5,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.white),
        ),
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: Colors.white
        )
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: Colors.white
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
        color: Colors.white,
        fontWeight: FontWeight.bold
      )
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF101110),
    ),
    dividerColor: Colors.white,
    toggleButtonsTheme: const ToggleButtonsThemeData(
      selectedColor: Colors.grey,
    )
  );

  final ThemeData amoledTheme = ThemeData(
    
  );

}