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
        fontSize: 18,
        fontWeight: FontWeight.bold
      ),
      bodyMedium: TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.bold
      ),
      bodySmall: TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.bold
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(Colors.black)
      )
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white
    )
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
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
        bodyMedium: TextStyle(
          color: Colors.grey.shade200,
          fontSize: 15,
          fontWeight: FontWeight.bold
        ),
        bodySmall: TextStyle(
          color: Colors.grey.shade200,
          fontSize: 12,
          fontWeight: FontWeight.bold
        ),
      ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(Colors.grey.shade50)
      )
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.grey.shade900,

    ),
    dividerColor: Colors.grey.shade200,
  );

  final amoledTheme = ThemeData(
    
  );

}