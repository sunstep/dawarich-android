import 'package:flutter/material.dart';

extension AppGradients on ThemeData {

  LinearGradient get pageBackground => brightness == Brightness.dark
      ? const LinearGradient(
    colors: [ Color(0xFF512DA8), Color(0xFFE91E63) ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  )
      : const LinearGradient(
    colors: [ Color(0xFF2196F3), Color(0xFF21CBF3) ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}