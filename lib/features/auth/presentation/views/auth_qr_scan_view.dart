
import 'package:auto_route/auto_route.dart';
import 'package:dawarich/features/auth/presentation/widgets/auth_qr_scan_overlay.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

@RoutePage()
class AuthQrScanView extends StatefulWidget {
  const AuthQrScanView({super.key});
  @override
  State<AuthQrScanView> createState() => _AuthQrScanViewState();
}

class _AuthQrScanViewState extends State<AuthQrScanView> {
  final _controller = MobileScannerController();
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_handled) return;
              final code = capture.barcodes.first.rawValue;
              if (code == null || code.isEmpty) return;
              _handled = true;
              context.router.maybePop<String>(code);
            },
          ),
          AuthQrScanOverlay(),
        ],
      ),
    );
  }
}