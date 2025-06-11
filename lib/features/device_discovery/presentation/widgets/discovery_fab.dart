import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/animations/transfer_animation.dart';
import '../../../../shared/widgets/common/custom_bottom_sheet.dart';
import '../bloc/device_discovery_bloc.dart';
import '../bloc/device_discovery_event.dart';
import '../bloc/device_discovery_state.dart';

/// Discovery floating action button
class DiscoveryFAB extends StatelessWidget {
  const DiscoveryFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceDiscoveryBloc, DeviceDiscoveryState>(
      builder: (context, state) {
        final isDiscovering = state.isCurrentlyDiscovering;
        final isAdvertising = state.isCurrentlyAdvertising;
        final hasSelectedDevices = state.hasSelectedDevices;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Transfer FAB (when devices are selected)
            if (hasSelectedDevices)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FloatingActionButton(
                  heroTag: 'transfer',
                  onPressed: () => _handleTransfer(context, state),
                  backgroundColor: context.colorScheme.tertiary,
                  foregroundColor: context.colorScheme.onTertiary,
                  child: const Icon(Icons.send),
                ),
              ),

            // Main discovery FAB
            FloatingActionButton.extended(
              heroTag: 'discovery',
              onPressed: () => _handleDiscoveryAction(context, isDiscovering),
              backgroundColor: isDiscovering
                  ? context.colorScheme.error
                  : context.colorScheme.primary,
              foregroundColor: isDiscovering
                  ? context.colorScheme.onError
                  : context.colorScheme.onPrimary,
              icon: isDiscovering
                  ? const Icon(Icons.stop)
                  : (isAdvertising
                        ? const PulseAnimation(child: Icon(Icons.radar))
                        : const Icon(Icons.search)),
              label: Text(isDiscovering ? 'Stop' : 'Discover'),
            ),
          ],
        );
      },
    );
  }

  void _handleDiscoveryAction(BuildContext context, bool isDiscovering) {
    if (isDiscovering) {
      context.read<DeviceDiscoveryBloc>().add(const StopDiscoveryEvent());
    } else {
      _showDiscoveryOptions(context);
    }
  }

  void _handleTransfer(BuildContext context, DeviceDiscoveryState state) {
    final selectedDevices = state.selectedDeviceEntities;
    if (selectedDevices.isEmpty) return;

    context.showInfoSnackBar(
      'Starting transfer to ${selectedDevices.length} device(s)...',
    );

    // Navigate to file selection or transfer page
    // This would typically navigate to the file transfer feature
  }

  void _showDiscoveryOptions(BuildContext context) {
    CustomBottomSheet.show(
      context,
      title: 'Discovery Options',
      children: [
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text('Quick Discovery'),
          subtitle: const Text('Find nearby devices using all methods'),
          onTap: () {
            Navigator.pop(context);
            _startDiscovery(context, null);
          },
        ),
        ListTile(
          leading: const Icon(Icons.wifi),
          title: const Text('WiFi Direct'),
          subtitle: const Text('High-speed direct connection'),
          onTap: () {
            Navigator.pop(context);
            _startDiscovery(
              context,
              ConnectionType.wifiDirect,
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.nearby_error),
          title: const Text('Nearby Connections'),
          subtitle: const Text('Google\'s nearby connections API'),
          onTap: () {
            Navigator.pop(context);
            _startDiscovery(
              context,
             ConnectionType.nearbyConnections,
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.wifi_tethering),
          title: const Text('WiFi Hotspot'),
          subtitle: const Text('Create or join WiFi hotspot'),
          onTap: () {
            Navigator.pop(context);
            _startDiscovery(
              context,
              ConnectionType.wifiHotspot,
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.qr_code),
          title: const Text('QR Code'),
          subtitle: const Text('Connect using QR code'),
          onTap: () {
            Navigator.pop(context);
            _showQRCodeOptions(context);
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _startAdvertising(context);
                },
                icon: const Icon(Icons.radar),
                label: const Text('Make Discoverable'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _startDiscovery(BuildContext context, ConnectionType? method) {
    context.read<DeviceDiscoveryBloc>().add(
      StartDiscoveryEvent(method: method),
    );
  }

  void _startAdvertising(BuildContext context) {
    context.read<DeviceDiscoveryBloc>().add(const StartAdvertisingEvent());
  }

  void _showQRCodeOptions(BuildContext context) {
    CustomBottomSheet.show(
      context,
      title: 'QR Code Connection',
      children: [
        ListTile(
          leading: const Icon(Icons.qr_code_scanner),
          title: const Text('Scan QR Code'),
          subtitle: const Text('Scan another device\'s QR code'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to QR scanner
          },
        ),
        ListTile(
          leading: const Icon(Icons.qr_code),
          title: const Text('Show QR Code'),
          subtitle: const Text('Display QR code for others to scan'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to QR code display
          },
        ),
      ],
    );
  }
}
