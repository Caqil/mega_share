import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/common/custom_app_bar.dart';
import '../../../../shared/widgets/common/custom_button.dart';
import '../../../../shared/widgets/common/loading_widget.dart';
import '../../../../shared/widgets/common/error_widget.dart';
import '../../../../shared/widgets/common/empty_state_widget.dart';
import '../../../../shared/widgets/animations/fade_in_animation.dart';
import '../../domain/entities/device_entity.dart';
import '../bloc/device_discovery_bloc.dart';
import '../bloc/device_discovery_event.dart';
import '../bloc/device_discovery_state.dart';
import '../widgets/device_card.dart';
import '../widgets/discovery_fab.dart';
import '../widgets/discovery_status_indicator.dart';

/// Device discovery page
class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Nearby Devices',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshDiscovery(context),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_cache',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear Cache'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<DeviceDiscoveryBloc, DeviceDiscoveryState>(
        listener: (context, state) {
          state.maybeWhen(
            error: (failure, _, __, ___, ____, _____) {
              context.showErrorSnackBar(failure.message);
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return Column(
            children: [
              // Discovery status indicator
              const DiscoveryStatusIndicator(),

              // Main content
              Expanded(
                child: state.when(
                  initial: () => _buildInitialState(context),
                  loading:
                      (
                        isDiscovering,
                        isAdvertising,
                        devices,
                        selectedDevices,
                        discoveryResult,
                      ) => _buildLoadingState(context, devices, isDiscovering),
                  success:
                      (
                        devices,
                        isDiscovering,
                        isAdvertising,
                        selectedDevices,
                        discoveryResult,
                      ) =>
                          _buildSuccessState(context, devices, selectedDevices),
                  error:
                      (
                        failure,
                        isDiscovering,
                        isAdvertising,
                        devices,
                        selectedDevices,
                        discoveryResult,
                      ) => _buildErrorState(context, failure, devices),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: const DiscoveryFAB(),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return EmptyStateWidget(
      variant: EmptyStateVariant.noDevices,
      actionText: 'Start Discovery',
      onAction: () => _startDiscovery(context),
    );
  }

  Widget _buildLoadingState(
    BuildContext context,
    List<DeviceEntity> devices,
    bool isDiscovering,
  ) {
    if (devices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingWidget(
              variant: LoadingVariant.pulse,
              message: 'Searching for nearby devices...',
            ),
          ],
        ),
      );
    }

    return _buildDevicesList(context, devices, []);
  }

  Widget _buildSuccessState(
    BuildContext context,
    List<DeviceEntity> devices,
    List<String> selectedDevices,
  ) {
    if (devices.isEmpty) {
      return EmptyStateWidget(
        variant: EmptyStateVariant.noDevices,
        actionText: 'Refresh',
        onAction: () => _refreshDiscovery(context),
      );
    }

    return _buildDevicesList(context, devices, selectedDevices);
  }

  Widget _buildErrorState(
    BuildContext context,
    Failure failure,
    List<DeviceEntity> devices,
  ) {
    if (devices.isEmpty) {
      return CustomErrorWidget(
        failure: failure,
        onRetry: () => _startDiscovery(context),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: context.colorScheme.errorContainer,
          child: Row(
            children: [
              Icon(Icons.warning, color: context.colorScheme.onErrorContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Discovery failed: ${failure.message}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onErrorContainer,
                  ),
                ),
              ),
              CustomButton(
                text: 'Retry',
                onPressed: () => _startDiscovery(context),
                variant: ButtonVariant.text,
                size: ButtonSize.small,
              ),
            ],
          ),
        ),
        Expanded(child: _buildDevicesList(context, devices, [])),
      ],
    );
  }

  Widget _buildDevicesList(
    BuildContext context,
    List<DeviceEntity> devices,
    List<String> selectedDevices,
  ) {
    return RefreshIndicator(
      onRefresh: () async => _refreshDiscovery(context),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return FadeInAnimation(
            delay: Duration(milliseconds: index * 100),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DeviceCard(
                device: device,
                isSelected: selectedDevices.contains(device.id),
                onTap: () => _onDeviceTap(context, device),
                onLongPress: () => _onDeviceLongPress(context, device),
                onSelectionChanged: (selected) =>
                    _onDeviceSelectionChanged(context, device.id, selected),
              ),
            ),
          );
        },
      ),
    );
  }

  void _startDiscovery(BuildContext context) {
    context.read<DeviceDiscoveryBloc>().add(
      const StartDiscoveryEvent(
        method: ConnectionType.nearbyConnections,
      ),
    );
  }

  void _refreshDiscovery(BuildContext context) {
    context.read<DeviceDiscoveryBloc>().add(
      const RefreshDiscoveryEvent(
        method: ConnectionType.nearbyConnections,
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'clear_cache':
        context.read<DeviceDiscoveryBloc>().add(
          const ClearDiscoveryCacheEvent(),
        );
        context.showInfoSnackBar('Cache cleared');
        break;
      case 'settings':
        // Navigate to settings
        break;
    }
  }

  void _onDeviceTap(BuildContext context, DeviceEntity device) {
    if (device.isConnectable) {
      // Navigate to connection/transfer page
      context.showInfoSnackBar('Connecting to ${device.displayName}...');
    } else {
      context.showErrorSnackBar('Device is not connectable');
    }
  }

  void _onDeviceLongPress(BuildContext context, DeviceEntity device) {
    // Show device details or context menu
    _showDeviceDetails(context, device);
  }

  void _onDeviceSelectionChanged(
    BuildContext context,
    String deviceId,
    bool? selected,
  ) {
    if (selected == true) {
      context.read<DeviceDiscoveryBloc>().add(SelectDeviceEvent(deviceId));
    } else {
      context.read<DeviceDiscoveryBloc>().add(DeselectDeviceEvent(deviceId));
    }
  }

  void _showDeviceDetails(BuildContext context, DeviceEntity device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', device.deviceType.name),
            _buildDetailRow('Signal', '${device.signalStrength}%'),
            _buildDetailRow('Last Seen', _formatLastSeen(device.lastSeen)),
            if (device.ipAddress != null)
              _buildDetailRow('IP Address', device.ipAddress!),
            if (device.endpointId != null)
              _buildDetailRow('Endpoint ID', device.endpointId!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (device.isConnectable)
            CustomButton(
              text: 'Connect',
              onPressed: () {
                Navigator.of(context).pop();
                _onDeviceTap(context, device);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}
