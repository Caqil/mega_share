import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/connection_constants.dart';
import '../bloc/device_discovery_bloc.dart';
import '../bloc/device_discovery_state.dart';

/// Discovery status indicator widget
class DiscoveryStatusIndicator extends StatelessWidget {
  const DiscoveryStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceDiscoveryBloc, DeviceDiscoveryState>(
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatusIcon(state),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discovery Status',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            state.statusDescription,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (state.isDiscovering)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                if (state.hasDevices) ...[
                  const SizedBox(height: 16),
                  _buildDeviceStats(context, state),
                ],
                if (state.discoveryMethod != null) ...[
                  const SizedBox(height: 8),
                  _buildDiscoveryMethod(context, state),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(DeviceDiscoveryState state) {
    IconData icon;
    Color color;

    switch (state.status) {
      case DeviceDiscoveryStatus.idle:
        icon = Icons.search_off;
        color = Colors.grey;
        break;
      case DeviceDiscoveryStatus.starting:
      case DeviceDiscoveryStatus.discovering:
        icon = Icons.search;
        color = Colors.blue;
        break;
      case DeviceDiscoveryStatus.stopping:
        icon = Icons.stop;
        color = Colors.orange;
        break;
      case DeviceDiscoveryStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case DeviceDiscoveryStatus.error:
        icon = Icons.error;
        color = Colors.red;
        break;
    }

    return Icon(icon, color: color, size: 28);
  }

  Widget _buildDeviceStats(BuildContext context, DeviceDiscoveryState state) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total',
            value: state.devices.length.toString(),
            icon: Icons.devices,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Connectable',
            value: state.connectableDevices.length.toString(),
            icon: Icons.link,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Connected',
            value: state.connectedDevices.length.toString(),
            icon: Icons.check_circle,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryMethod(
    BuildContext context,
    DeviceDiscoveryState state,
  ) {
    if (state.discoveryMethod == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final methodName = _getMethodName(state.discoveryMethod!);

    return Row(
      children: [
        Icon(
          _getMethodIcon(state.discoveryMethod!),
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          'Method: $methodName',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  String _getMethodName(ConnectionType method) {
    switch (method) {
      case ConnectionType.nearbyConnections:
        return 'Nearby Connections';
      case ConnectionType.wifiDirect:
        return 'WiFi Direct';
      case ConnectionType.wifiHotspot:
        return 'WiFi Hotspot';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.qrCode:
        return 'QR Code';
      default:
        return 'Unknown';
    }
  }

  IconData _getMethodIcon(ConnectionType method) {
    switch (method) {
      case ConnectionType.nearbyConnections:
        return Icons.devices;
      case ConnectionType.wifiDirect:
        return Icons.wifi;
      case ConnectionType.wifiHotspot:
        return Icons.wifi_tethering;
      case ConnectionType.bluetooth:
        return Icons.bluetooth;
      case ConnectionType.qrCode:
        return Icons.qr_code;
      default:
        return Icons.device_unknown;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: theme.textTheme.bodySmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
