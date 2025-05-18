import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double? titleFontSize;
  final Color? backgroundColor;

  const CustomAppbar({
    super.key,
    required this.title,
    this.titleFontSize,
    this.backgroundColor,          // ← added this as optional
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,  // ← uses your passed-in color (nullable)
      elevation: backgroundColor == null ? 0 : null, // if transparent, no shadow
      title: Text(
        title,
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}