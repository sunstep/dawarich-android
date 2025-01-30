import 'package:flutter/material.dart';

class Appbar extends StatelessWidget implements PreferredSizeWidget {

  final String title;
  final double? fontSize;

  const Appbar({
    super.key,
    required this.title,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}