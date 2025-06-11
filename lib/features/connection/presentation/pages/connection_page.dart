import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../domain/entities/connection_entity.dart';
import '../../domain/entities/endpoint_entity.dart';
import '../bloc/connection_bloc.dart';
import '../bloc/connection_event.dart';
import '../bloc/connection_state.dart' as c;
import '../widgets/connection_request_dialog.dart';
import '../widgets/connection_status_card.dart';
import '../widgets/qr_code_generator.dart';
import '../widgets/wifi_hotspot_toggle.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load initial connection info
    context.read<ConnectionBloc>().add(const LoadConnectionInfo());
    context.read<ConnectionBloc>().add(const CheckPermissions());
    context.read<ConnectionBloc>().add(const CheckWiFiHotspotStatus());
  }

  @override
  void dispose() {
    _tabController.dispose();
    qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Connections'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Devices', icon: Icon(Icons.devices)),
            Tab(text: 'QR Code', icon: Icon(Icons.qr_code)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: BlocConsumer<ConnectionBloc, c.ConnectionState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildDevicesTab(context, state),
              _buildQRCodeTab(context, state),
              _buildSettingsTab(context, state),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildDevicesTab(BuildContext context, c.ConnectionState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ConnectionBloc>().add(const LoadConnectionInfo());
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildConnectionStatus(context, state),
            ),
          ),
          if (state.activeConnections.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Active Connections (${state.activeConnections.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final connection = state.activeConnections[index];
                return ConnectionStatusCard(
                  connection: connection,
                  onTap: () => _showConnectionDetails(context, connection),
                );
              }, childCount: state.activeConnections.length),
            ),
          ],
          if (state.discoveredDevices.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nearby Devices (${state.discoveredDevices.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.isDiscovering)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final endpoint = state.discoveredDevices[index];
                return _buildEndpointCard(context, endpoint);
              }, childCount: state.discoveredDevices.length),
            ),
          ] else if (state.isDiscovering) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Searching for nearby devices...',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.devices, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No nearby devices found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start discovery to find devices around you',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context, c.ConnectionState state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  context,
                  'Connected',
                  '${state.activeConnections.length}',
                  Icons.link,
                  Colors.green,
                ),
              ),
              Container(width: 1, height: 40, color: theme.dividerColor),
              Expanded(
                child: _buildStatusItem(
                  context,
                  'Discovered',
                  '${state.discoveredDevices.length}',
                  Icons.radar,
                  Colors.blue,
                ),
              ),
              Container(width: 1, height: 40, color: theme.dividerColor),
              Expanded(
                child: _buildStatusItem(
                  context,
                  'Capacity',
                  '${state.activeConnections.length}/${state.maxConnections}',
                  Icons.device_hub,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.canStartDiscovery
                      ? () => context.read<ConnectionBloc>().add(
                          const StartDiscovery(),
                        )
                      : null,
                  icon: Icon(state.isDiscovering ? Icons.stop : Icons.search),
                  label: Text(
                    state.isDiscovering ? 'Stop Discovery' : 'Start Discovery',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isDiscovering
                        ? Colors.red
                        : theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEndpointCard(BuildContext context, EndpointEntity endpoint) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Icon(
            _getDeviceIcon(endpoint.deviceType),
            color: theme.primaryColor,
          ),
        ),
        title: Text(
          endpoint.deviceName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${endpoint.deviceType} • ${endpoint.distance.toStringAsFixed(1)}m away',
        ),
        trailing: OutlinedButton(
          onPressed: () => _connectToEndpoint(context, endpoint),
          child: const Text('Connect'),
        ),
        onTap: () => _showEndpointDetails(context, endpoint),
      ),
    );
  }

  Widget _buildQRCodeTab(BuildContext context, c.ConnectionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (state.qrCodeData != null) ...[
            QRCodeGenerator(qrData: state.qrCodeData!),
            const SizedBox(height: 24),
          ],
          ElevatedButton.icon(
            onPressed: () {
              context.read<ConnectionBloc>().add(const GenerateQRCode());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Generate New QR Code'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Scan QR Code',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.red,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 250,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context, c.ConnectionState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const WiFiHotspotToggle(),
        const SizedBox(height: 16),
        _buildPermissionsCard(context, state),
        const SizedBox(height: 16),
        _buildDeviceInfoCard(context, state),
        const SizedBox(height: 16),
        _buildActionsCard(context),
      ],
    );
  }

  Widget _buildPermissionsCard(BuildContext context, c.ConnectionState state) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  state.hasRequiredPermissions
                      ? Icons.check_circle
                      : Icons.warning,
                  color: state.hasRequiredPermissions
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Permissions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              state.hasRequiredPermissions
                  ? 'All required permissions granted'
                  : 'Some permissions are missing',
              style: theme.textTheme.bodyMedium,
            ),
            if (!state.hasRequiredPermissions) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  context.read<ConnectionBloc>().add(
                    const RequestPermissions(),
                  );
                },
                child: const Text('Grant Permissions'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(BuildContext context, c.ConnectionState state) {
    final theme = Theme.of(context);
    final connectionInfo = state.connectionInfo;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (connectionInfo != null) ...[
              _buildInfoRow('Device Name', connectionInfo.deviceName),
              _buildInfoRow('Device ID', connectionInfo.deviceId),
              _buildInfoRow(
                'Available Types',
                connectionInfo.availableConnectionTypes
                    .map((e) => e.name)
                    .join(', '),
              ),
              _buildInfoRow(
                'Max Connections',
                connectionInfo.maxConnections.toString(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Disconnect All'),
              subtitle: const Text('Disconnect from all devices'),
              onTap: () => _disconnectAll(context),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh Connections'),
              subtitle: const Text('Reload connection information'),
              onTap: () {
                context.read<ConnectionBloc>().add(const LoadConnectionInfo());
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return BlocBuilder<ConnectionBloc, c.ConnectionState>(
      builder: (context, state) {
        return FloatingActionButton(
          onPressed: state.canStartDiscovery
              ? () => context.read<ConnectionBloc>().add(const StartDiscovery())
              : null,
          child: Icon(state.isDiscovering ? Icons.stop : Icons.search),
        );
      },
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        context.read<ConnectionBloc>().add(
          ConnectFromQRCode(qrData: scanData.code!),
        );
        controller.pauseCamera();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code scanned! Attempting to connect...'),
          ),
        );
      }
    });
  }

  void _connectToEndpoint(BuildContext context, EndpointEntity endpoint) {
    ConnectionRequestDialog.show(
      context,
      endpoint: endpoint,
      isIncoming: false,
    );
  }

  void _showEndpointDetails(BuildContext context, EndpointEntity endpoint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(endpoint.deviceName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${endpoint.deviceType}'),
            Text('Distance: ${endpoint.distance.toStringAsFixed(1)}m'),
            Text('Reachable: ${endpoint.isReachable ? "Yes" : "No"}'),
            Text('Discovered: ${endpoint.discoveredAt}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _connectToEndpoint(context, endpoint);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _showConnectionDetails(
    BuildContext context,
    ConnectionEntity connection,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connection Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device: ${connection.deviceName}'),
            Text('Status: ${connection.status.name}'),
            Text('Type: ${connection.type.name}'),
            Text('Signal: ${(connection.signalStrength * 100).toInt()}%'),
            Text('Data: ${_formatBytes(connection.dataTransferred)}'),
            Text('Speed: ${_formatSpeed(connection.transferSpeed)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _disconnectAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect All'),
        content: const Text(
          'Are you sure you want to disconnect from all devices?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ConnectionBloc>().add(const DisconnectFromDevice());
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disconnect All'),
          ),
        ],
      ),
    );
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
      case 'macos':
        return Icons.laptop_mac;
      default:
        return Icons.device_unknown;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024)
      return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    if (bytesPerSecond < 1024 * 1024)
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}
