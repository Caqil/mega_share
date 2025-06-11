import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../domain/entities/connection_entity.dart';
import '../bloc/connection_bloc.dart';
import '../bloc/connection_event.dart';

class ConnectionStatusCard extends StatelessWidget {
  final ConnectionEntity connection;
  final VoidCallback? onTap;

  const ConnectionStatusCard({super.key, required this.connection, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _buildStatusIcon(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          connection.deviceName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildConnectionTypeChip(context),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(context, value),
                    itemBuilder: (context) => [
                      if (connection.isActive) ...[
                        const PopupMenuItem(
                          value: 'disconnect',
                          child: ListTile(
                            leading: Icon(Icons.close),
                            title: Text('Disconnect'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      const PopupMenuItem(
                        value: 'details',
                        child: ListTile(
                          leading: Icon(Icons.info),
                          title: Text('Details'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              if (connection.isActive) ...[
                const SizedBox(height: 12),
                _buildConnectionStats(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;

    switch (connection.status) {
      case ConnectionStatus.connected:
      case ConnectionStatus.authenticated:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case ConnectionStatus.connecting:
      case ConnectionStatus.authenticating:
        icon = Icons.sync;
        color = Colors.orange;
        break;
      case ConnectionStatus.failed:
      case ConnectionStatus.rejected:
        icon = Icons.error;
        color = Colors.red;
        break;
      case ConnectionStatus.lost:
        icon = Icons.wifi_off;
        color = Colors.grey;
        break;
      default:
        icon = Icons.device_unknown;
        color = theme.textTheme.bodySmall?.color ?? Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildConnectionTypeChip(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    String label;

    switch (connection.type) {
      case ConnectionType.wifiDirect:
        icon = Icons.wifi;
        label = 'WiFi Direct';
        break;
      case ConnectionType.bluetooth:
        icon = Icons.bluetooth;
        label = 'Bluetooth';
        break;
      case ConnectionType.wifiHotspot:
        icon = Icons.router;
        label = 'Hotspot';
        break;
      default:
        icon = Icons.device_unknown;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStats(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              'Signal',
              '${(connection.signalStrength * 100).toInt()}%',
              Icons.signal_cellular_alt,
            ),
          ),
          Container(width: 1, height: 20, color: theme.dividerColor),
          Expanded(
            child: _buildStatItem(
              context,
              'Speed',
              _formatSpeed(connection.transferSpeed),
              Icons.speed,
            ),
          ),
          Container(width: 1, height: 20, color: theme.dividerColor),
          Expanded(
            child: _buildStatItem(
              context,
              'Data',
              _formatBytes(connection.dataTransferred),
              Icons.data_usage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 16, color: theme.textTheme.bodySmall?.color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
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

  String _getStatusText() {
    switch (connection.status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.authenticated:
        return 'Connected & Authenticated';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.authenticating:
        return 'Authenticating...';
      case ConnectionStatus.failed:
        return 'Connection Failed';
      case ConnectionStatus.rejected:
        return 'Connection Rejected';
      case ConnectionStatus.lost:
        return 'Connection Lost';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (connection.status) {
      case ConnectionStatus.connected:
      case ConnectionStatus.authenticated:
        return Colors.green;
      case ConnectionStatus.connecting:
      case ConnectionStatus.authenticating:
        return Colors.orange;
      case ConnectionStatus.failed:
      case ConnectionStatus.rejected:
        return Colors.red;
      case ConnectionStatus.lost:
      case ConnectionStatus.disconnected:
        return Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    }
  }

  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'disconnect':
        context.read<ConnectionBloc>().add(
          DisconnectFromDevice(endpointId: connection.endpointId),
        );
        break;
      case 'details':
        _showConnectionDetails(context);
        break;
    }
  }

  void _showConnectionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connection Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device: ${connection.deviceName}'),
            Text('Type: ${connection.type.name}'),
            Text('Status: ${connection.status.name}'),
            Text('Connected: ${connection.connectedAt}'),
            if (connection.lastActiveAt != null)
              Text('Last Active: ${connection.lastActiveAt}'),
            Text('Encrypted: ${connection.isEncrypted ? "Yes" : "No"}'),
            Text('Signal: ${(connection.signalStrength * 100).toInt()}%'),
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
}
