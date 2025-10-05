
import 'package:flutter/material.dart';

final class AuthQrScanOverlay extends StatelessWidget {

  const AuthQrScanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      IgnorePointer(
        child: Container(color: Colors.black.withValues(alpha: .25)),
      ),
      Center(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 2, color: Colors.white70),
          ),
        ),
      ),
      // small hints
      Positioned(
        bottom: 24,
        left: 0, right: 0,
        child: Text(
          'Align QR inside the frame',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
          ),
        ),
      ),
    ]);
  }

}