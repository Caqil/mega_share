// lib/features/connection/presentation/widgets/connection_request_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/connection_entity.dart';
import '../../domain/entities/endpoint_entity.dart';
import '../bloc/connection_bloc.dart';
import '../bloc/connection_event.dart';

class ConnectionRequestDialog extends StatelessWidget {
  final EndpointEntity endpoint;
  final bool isIncoming;

  const ConnectionRequestDialog({
    super.key,
    required this.endpoint,
    required this.isIncoming,
  });

  static Future<bool?> show(
    BuildContext context, {
    required EndpointEntity endpoint,
    required bool isIncoming,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConnectionRequestDialog(
        endpoint: endpoint,
        isIncoming: isIncoming,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getDeviceIcon(endpoint.deviceType),
              color: theme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isIncoming ? 'Incoming Connection' : 'Connect to Device',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  endpoint.deviceName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            'Device Type',
            endpoint.deviceType,
            Icons.phone_android,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            'Distance',
            '${endpoint.distance.toStringAsFixed(1)}m',
            Icons.location_on,
          ),
          const SizedBox(height: 8),
          _buildConnectionCapabilities(context),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Connection will be encrypted',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (isIncoming) ...[
          TextButton(
            onPressed: () {
              context.read<ConnectionBloc>().add(
                RejectConnection(endpointId: endpoint.endpointId),
              );
              Navigator.of(context).pop(false);
            },
            child: Text(
              'Reject',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              context.read<ConnectionBloc>().add(
                AcceptConnection(endpointId: endpoint.endpointId),
              );
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              context.read<ConnectionBloc>().add(
                ConnectToDevice(endpointId: endpoint.endpointId),
              );
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Connect'),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionCapabilities(BuildContext context) {
    final theme = Theme.of(context);
    final capabilities = <String>[];
    
    if (endpoint.supportsWiFiDirect) capabilities.add('WiFi Direct');
    if (endpoint.supportsBluetooth) capabilities.add('Bluetooth');
    if (endpoint.supportsHotspot) capabilities.add('Hotspot');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supported Connections:',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: capabilities.map((capability) {
            return Chip(
              label: Text(
                capability,
                style: theme.textTheme.bodySmall,
              ),
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              side: BorderSide.none,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
      ],
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
}
