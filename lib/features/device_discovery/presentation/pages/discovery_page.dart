// lib/features/connection/presentation/pages/device_discovery_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mega_share/app/router/app_router.dart';
import 'package:mega_share/app/router/route_names.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import 'package:mega_share/shared/widgets/common/custom_button.dart';
import 'package:mega_share/shared/widgets/common/empty_state_widget.dart';

class DiscoveryPage extends StatefulWidget {
  final String mode;
  final bool isFullscreen;

  const DiscoveryPage({
    super.key,
    this.mode = 'discover',
    this.isFullscreen = false,
  });

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage>
    with TickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late AnimationController _fadeController;
  bool _isScanning = false;
  List<DiscoveredDevice> _discoveredDevices = [];

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();

    if (widget.mode == 'receive') {
      _startDiscovery();
    }
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeController,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header section
              _buildHeader(),

              const SizedBox(height: 24),

              // Connection options
              if (!_isScanning) _buildConnectionOptions(),

              // Scanning indicator
              if (_isScanning) _buildScanningIndicator(),

              const SizedBox(height: 24),

              // Device list
              Expanded(child: _buildDeviceList()),

              // Bottom actions
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_getPageTitle()),
      leading: widget.isFullscreen
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            )
          : null,
      actions: [
        if (_isScanning)
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _stopDiscovery,
            tooltip: 'Stop scanning',
          )
        else
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _showQrCode,
            tooltip: 'Show QR code',
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              _getHeaderIcon(),
              size: 48,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              _getHeaderTitle(),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getHeaderSubtitle(),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Methods',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildConnectionMethodCard(
                    'WiFi Direct',
                    'Fast & Secure',
                    Icons.wifi,
                    () => _startDiscovery(method: 'wifi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildConnectionMethodCard(
                    'Bluetooth',
                    'Universal',
                    Icons.bluetooth,
                    () => _startDiscovery(method: 'bluetooth'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Scan QR Code',
              onPressed: _scanQrCode,
              variant: ButtonVariant.outline,
              icon: Icons.qr_code_scanner,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionMethodCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: context.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            RotationTransition(
              turns: _scanAnimationController,
              child: Icon(
                Icons.radar,
                size: 64,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scanning for devices...',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure nearby devices are discoverable',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    if (_discoveredDevices.isEmpty && !_isScanning) {
      return const EmptyStateWidget(
        variant: EmptyStateVariant.noDevices,
        actionText: 'Start Scanning',
      );
    }

    if (_discoveredDevices.isEmpty && _isScanning) {
      return const SizedBox(); // Show scanning indicator instead
    }

    return ListView.builder(
      itemCount: _discoveredDevices.length,
      itemBuilder: (context, index) {
        final device = _discoveredDevices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: context.colorScheme.primaryContainer,
              child: Icon(
                _getDeviceIcon(device.type),
                color: context.colorScheme.primary,
              ),
            ),
            title: Text(device.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.type),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getConnectionIcon(device.connectionType),
                      size: 14,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      device.connectionType,
                      style: context.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 14,
                      color: _getSignalColor(device.signalStrength),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${device.signalStrength}%',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _connectToDevice(device),
              child: const Text('Connect'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActions() {
    return Column(
      children: [
        if (!_isScanning)
          CustomButton(
            text: 'Start Discovery',
            onPressed: _startDiscovery,
            variant: ButtonVariant.primary,
            icon: Icons.search,
          )
        else
          CustomButton(
            text: 'Stop Scanning',
            onPressed: _stopDiscovery,
            variant: ButtonVariant.outline,
            icon: Icons.stop,
          ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Show QR Code',
                onPressed: _showQrCode,
                variant: ButtonVariant.outline,
                icon: Icons.qr_code,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Scan QR Code',
                onPressed: _scanQrCode,
                variant: ButtonVariant.outline,
                icon: Icons.qr_code_scanner,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getPageTitle() {
    switch (widget.mode) {
      case 'send':
        return 'Select Device';
      case 'receive':
        return 'Waiting for Connection';
      default:
        return 'Nearby Devices';
    }
  }

  IconData _getHeaderIcon() {
    switch (widget.mode) {
      case 'send':
        return Icons.send;
      case 'receive':
        return Icons.download;
      default:
        return Icons.devices;
    }
  }

  String _getHeaderTitle() {
    switch (widget.mode) {
      case 'send':
        return 'Send Files';
      case 'receive':
        return 'Receive Files';
      default:
        return 'Discover Devices';
    }
  }

  String _getHeaderSubtitle() {
    switch (widget.mode) {
      case 'send':
        return 'Select a device to send your files to';
      case 'receive':
        return 'Waiting for incoming file transfers';
      default:
        return 'Find nearby devices to share files with';
    }
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'iphone':
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
        return Icons.computer;
      case 'mac':
        return Icons.laptop_mac;
      default:
        return Icons.device_unknown;
    }
  }

  IconData _getConnectionIcon(String connectionType) {
    switch (connectionType.toLowerCase()) {
      case 'wifi':
      case 'wifi direct':
        return Icons.wifi;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'hotspot':
        return Icons.router;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getSignalColor(int strength) {
    if (strength >= 75) return Colors.green;
    if (strength >= 50) return Colors.orange;
    return Colors.red;
  }

  void _startDiscovery({String? method}) {
    setState(() {
      _isScanning = true;
      _discoveredDevices.clear();
    });

    _scanAnimationController.repeat();

    // Simulate device discovery
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _isScanning) {
        setState(() {
          _discoveredDevices = [
            DiscoveredDevice(
              id: '1',
              name: 'John\'s iPhone',
              type: 'iPhone',
              connectionType: 'WiFi Direct',
              signalStrength: 85,
            ),
            DiscoveredDevice(
              id: '2',
              name: 'Sarah\'s Android',
              type: 'Android',
              connectionType: 'WiFi Direct',
              signalStrength: 72,
            ),
            DiscoveredDevice(
              id: '3',
              name: 'Mike\'s Laptop',
              type: 'Windows',
              connectionType: 'Bluetooth',
              signalStrength: 58,
            ),
          ];
        });
      }
    });
  }

  void _stopDiscovery() {
    setState(() {
      _isScanning = false;
    });
    _scanAnimationController.stop();
  }

  void _showQrCode() {
    final connectionData = 'shareit://connect?device=MyDevice&id=12345';
    context.go(
      RouteNames.qrScanner,
      extra: {'connectionData': connectionData, 'deviceName': 'My Device'},
    );
  }

  void _scanQrCode() {
    context.go(RouteNames.qrScanner);
  }

  void _connectToDevice(DiscoveredDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect to ${device.name}'),
        content: Text('Do you want to connect to ${device.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleConnection(device);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _handleConnection(DiscoveredDevice device) {
    // TODO: Implement actual connection logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connecting to ${device.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate connection success
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${device.name}'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.mode == 'send') {
          // Navigate to transfer page or file selection
          context.go('/transfer/12345');
        }
      }
    });
  }
}

// Model class for discovered devices
class DiscoveredDevice {
  final String id;
  final String name;
  final String type;
  final String connectionType;
  final int signalStrength;

  DiscoveredDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.connectionType,
    required this.signalStrength,
  });
}
