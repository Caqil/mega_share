import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _flashEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _flashEnabled ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera placeholder (in real implementation, use qr_code_scanner package)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: const Center(
              child: Text(
                'Camera view will be implemented with qr_code_scanner package',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Scanning overlay
          _buildScanningOverlay(),

          // Bottom instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Position the QR code within the frame to scan',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Corner indicators
            ...List.generate(4, (index) => _buildCornerIndicator(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerIndicator(int index) {
    final isTop = index < 2;
    final isLeft = index % 2 == 0;

    return Positioned(
      top: isTop ? -2 : null,
      bottom: isTop ? null : -2,
      left: isLeft ? -2 : null,
      right: isLeft ? null : -2,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: context.colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? const Radius.circular(8) : Radius.zero,
            topRight: isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
            bottomLeft: !isTop && isLeft
                ? const Radius.circular(8)
                : Radius.zero,
            bottomRight: !isTop && !isLeft
                ? const Radius.circular(8)
                : Radius.zero,
          ),
        ),
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      _flashEnabled = !_flashEnabled;
    });
    // TODO: Implement flash toggle with qr_code_scanner
  }
}
