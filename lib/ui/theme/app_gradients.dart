import 'package:flutter/material.dart';

extension AppGradients on ThemeData {

  Gradient get pageBackground => brightness == Brightness.dark
      ? const LinearGradient(
    colors: [
      Color(0xFF2B2B2B), // Top: more greyish dark
      Color(0xFF0F0F0F), // Bottom: rich black
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  )
      : const LinearGradient(
    colors: [
      Color(0xFFE0E0E0), // Top: softened grey
      Color(0xFFF2F2F2), // Bottom: brighter
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}