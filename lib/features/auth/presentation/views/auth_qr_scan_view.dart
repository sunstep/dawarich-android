
import 'package:auto_route/auto_route.dart';
import 'package:dawarich/features/auth/presentation/widgets/auth_qr_scan_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

@RoutePage()
class AuthQrScanView extends StatefulWidget {
  const AuthQrScanView({super.key});
  @override
  State<AuthQrScanView> createState() => _AuthQrScanViewState();
}

class _AuthQrScanViewState extends State<AuthQrScanView> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: Stack(
        children: [
          ReaderWidget(
            showScannerOverlay: false,
            showFlashlight: false,
            showToggleCamera: false,
            onScan: (Code? code) {
              if (_handled) {
                return;
              }

              final String value = code?.text ?? '';
              final bool isValid = code?.isValid == true;

              if (!isValid || value.isEmpty) {
                return;
              }

              _handled = true;
              context.router.maybePop<String>(value);
            },
          ),
          AuthQrScanOverlay(),
        ],
      ),
    );
  }
}