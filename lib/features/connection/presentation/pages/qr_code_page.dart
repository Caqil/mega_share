import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import 'package:mega_share/shared/widgets/common/custom_button.dart';

class QrCodePage extends StatelessWidget {
  final String connectionData;
  final String deviceName;

  const QrCodePage({
    super.key,
    required this.connectionData,
    required this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareQRCode(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 48,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Share this QR code',
                      style: context.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Let others scan this code to connect to your device instantly',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // QR Code
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: context.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: connectionData,
                    version: QrVersions.auto,
                    size: 250,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Device Info
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.smartphone,
                  color: context.colorScheme.primary,
                ),
                title: Text(deviceName),
                subtitle: const Text('This device'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(context),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Scan QR Code',
                    onPressed: () => _goToScanner(context),
                    variant: ButtonVariant.outline,
                    icon: Icons.qr_code_scanner,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Done',
                    onPressed: () => context.pop(),
                    variant: ButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareQRCode(BuildContext context) {
    // TODO: Implement QR code sharing using share_plus
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality will be implemented')),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: connectionData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connection data copied to clipboard')),
    );
  }

  void _goToScanner(BuildContext context) {
    context.go('/devices/qr-scanner');
  }
}
