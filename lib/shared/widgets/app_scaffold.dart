import 'package:dawarich/features/version_check/presentation/widgets/compatibility_banner.dart';
import 'package:dawarich/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

/// A shared scaffold that places a [CompatibilityBanner] between the
/// [CustomAppbar] and the page body on every screen.
///
/// Use this instead of raw [Scaffold] + [CustomAppbar] so that the
/// banner appears globally, regardless of which page the user lands on.
final class AppScaffold extends StatelessWidget {
  final String title;
  final double? titleFontSize;
  final Color? appBarBackgroundColor;
  final Color? scaffoldBackgroundColor;
  final Widget body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.titleFontSize,
    this.appBarBackgroundColor,
    this.scaffoldBackgroundColor,
    this.drawer,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: CustomAppbar(
        title: title,
        titleFontSize: titleFontSize,
        backgroundColor: appBarBackgroundColor,
      ),
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      body: Column(
        children: [
          const CompatibilityBanner(),
          Expanded(child: body),
        ],
      ),
    );
  }
}


