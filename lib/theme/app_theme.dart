import 'dart:ffi';

import 'package:flutter/material.dart';

class Themes {

  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
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
        fontSize: 15,
        fontWeight: FontWeight.bold
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.white)
      )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      elevation: const WidgetStatePropertyAll<double>(5.0),
      side: WidgetStateProperty.all<BorderSide>(const BorderSide(
        color: Colors.black
      ))
    )),
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
    scaffoldBackgroundColor: Colors.grey.shade900,
    primaryColor: Colors.grey.shade900,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.grey.shade900,
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
          fontSize: 15,
          fontWeight: FontWeight.bold
        ),
      ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(Colors.grey.shade50)
      )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey.shade900),
        elevation: const WidgetStatePropertyAll<double>(5.0),
        side: const WidgetStatePropertyAll<BorderSide>(BorderSide(
          color: Colors.white
        ))
      )
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
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.grey.shade900,

    ),
    dividerColor: Colors.grey.shade200,
    toggleButtonsTheme: const ToggleButtonsThemeData(
      selectedColor: Colors.grey,
    )
  );

  final amoledTheme = ThemeData(
    
  );

}