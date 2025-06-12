import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/connection_constants.dart';
import '../bloc/device_discovery_bloc.dart';
import '../bloc/device_discovery_event.dart';
import '../bloc/device_discovery_state.dart';

/// Discovery floating action button
class DiscoveryFab extends StatelessWidget {
  const DiscoveryFab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceDiscoveryBloc, DeviceDiscoveryState>(
      builder: (context, state) {
        if (state.isDiscovering) {
          return FloatingActionButton.extended(
            onPressed: () {
              context.read<DeviceDiscoveryBloc>().add(
                const StopDiscoveryEvent(),
              );
            },
            icon: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            label: const Text('Stop'),
            backgroundColor: Colors.red,
          );
        }

        return FloatingActionButton.extended(
          onPressed: () {
            _showDiscoveryOptions(context);
          },
          icon: const Icon(Icons.search),
          label: const Text('Discover'),
        );
      },
    );
  }

  void _showDiscoveryOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _DiscoveryOptionsSheet(),
    );
  }
}

class _DiscoveryOptionsSheet extends StatelessWidget {
  const _DiscoveryOptionsSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Start Discovery', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text('Choose discovery method:', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _DiscoveryMethodTile(
            title: 'Nearby Connections',
            subtitle: 'Fast, direct connection between devices',
            icon: Icons.devices,
            method: ConnectionType.nearbyConnections,
            color: Colors.blue,
          ),
          _DiscoveryMethodTile(
            title: 'WiFi Direct',
            subtitle: 'Connect directly through WiFi',
            icon: Icons.wifi,
            method: ConnectionType.wifiDirect,
            color: Colors.green,
          ),
          _DiscoveryMethodTile(
            title: 'WiFi Hotspot',
            subtitle: 'Share through hotspot connection',
            icon: Icons.wifi_tethering,
            method: ConnectionType.wifiHotspot,
            color: Colors.orange,
          ),
          _DiscoveryMethodTile(
            title: 'Bluetooth',
            subtitle: 'Low energy Bluetooth connection',
            icon: Icons.bluetooth,
            method: ConnectionType.bluetooth,
            color: Colors.indigo,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DiscoveryMethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ConnectionType method;
  final Color color;

  const _DiscoveryMethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.method,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.of(context).pop();
          context.read<DeviceDiscoveryBloc>().add(
            StartDiscoveryEvent(method: method),
          );
        },
      ),
    );
  }
}
