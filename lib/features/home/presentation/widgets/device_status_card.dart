import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/animations/transfer_animation.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class DeviceStatusCard extends StatelessWidget {
  final DeviceStatus deviceStatus;

  const DeviceStatusCard({super.key, required this.deviceStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.responsiveHorizontalPadding,
      child: Card(
        elevation: 2,
        shadowColor: context.colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            gradient: _getGradient(context, deviceStatus.connectionState),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildConnectionStatus(context),
              const SizedBox(height: 16),
              _buildDeviceInfo(context),
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildStatusIcon(context),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Device Status',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _getTextColor(context),
                ),
              ),
              Text(
                _getStatusMessage(),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: _getTextColor(context).withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        if (deviceStatus.isActive)
          PulseAnimation(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(context),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    IconData iconData;
    Color iconColor = _getTextColor(context);

    switch (deviceStatus.connectionState) {
      case DeviceConnectionState.connected:
        iconData = Icons.devices;
        break;
      case DeviceConnectionState.discovering:
        iconData = Icons.radar;
        break;
      case DeviceConnectionState.ready:
        iconData = Icons.wifi;
        break;
      case DeviceConnectionState.disabled:
        iconData = Icons.wifi_off;
        break;
    }

    Widget icon = Icon(iconData, color: iconColor, size: 32);

    if (deviceStatus.isActive) {
      icon = PulseAnimation(
        duration: const Duration(milliseconds: 1500),
        child: icon,
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getTextColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: icon,
    );
  }

  Widget _buildConnectionStatus(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusItem(
            context,
            'Connected',
            '${deviceStatus.connectedDevicesCount}',
            Icons.link,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusItem(
            context,
            'Nearby',
            '${deviceStatus.nearbyDevicesCount}',
            Icons.radar,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusItem(
            context,
            'Status',
            _getConnectionStatusText(),
            _getConnectionStatusIcon(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getTextColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: _getTextColor(context).withOpacity(0.7), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: _getTextColor(context),
            ),
          ),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: _getTextColor(context).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getTextColor(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getTextColor(context).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.smartphone,
            color: _getTextColor(context).withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceStatus.deviceName,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(context),
                  ),
                ),
                Text(
                  _getConnectivityInfo(),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: _getTextColor(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          _buildConnectivityIndicators(context),
        ],
      ),
    );
  }

  Widget _buildConnectivityIndicators(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildConnectivityDot(
          context,
          deviceStatus.isWiFiEnabled,
          Icons.wifi,
          'WiFi',
        ),
        const SizedBox(width: 8),
        _buildConnectivityDot(
          context,
          deviceStatus.isBluetoothEnabled,
          Icons.bluetooth,
          'Bluetooth',
        ),
      ],
    );
  }

  Widget _buildConnectivityDot(
    BuildContext context,
    bool isEnabled,
    IconData icon,
    String tooltip,
  ) {
    return Tooltip(
      message: '$tooltip ${isEnabled ? 'On' : 'Off'}',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isEnabled
              ? Colors.green.withOpacity(0.2)
              : _getTextColor(context).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled
              ? Colors.green
              : _getTextColor(context).withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            deviceStatus.isDiscovering ? 'Stop Discovery' : 'Start Discovery',
            deviceStatus.isDiscovering ? Icons.stop : Icons.radar,
            () => _toggleDiscovery(context),
            isActive: deviceStatus.isDiscovering,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            'View Devices',
            Icons.devices,
            () => _viewDevices(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isActive = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive
            ? _getTextColor(context)
            : _getTextColor(context).withOpacity(0.1),
        foregroundColor: isActive
            ? _getBackgroundColor(context)
            : _getTextColor(context),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  LinearGradient _getGradient(
    BuildContext context,
    DeviceConnectionState state,
  ) {
    switch (state) {
      case DeviceConnectionState.connected:
        return LinearGradient(
          colors: [
            context.colorScheme.primaryContainer,
            context.colorScheme.primaryContainer.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DeviceConnectionState.discovering:
        return LinearGradient(
          colors: [
            context.colorScheme.secondaryContainer,
            context.colorScheme.secondaryContainer.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DeviceConnectionState.ready:
        return LinearGradient(
          colors: [
            context.colorScheme.tertiaryContainer,
            context.colorScheme.tertiaryContainer.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DeviceConnectionState.disabled:
        return LinearGradient(
          colors: [
            context.colorScheme.surfaceContainerHighest,
            context.colorScheme.surfaceContainerHighest.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (deviceStatus.connectionState) {
      case DeviceConnectionState.connected:
        return context.colorScheme.onPrimaryContainer;
      case DeviceConnectionState.discovering:
        return context.colorScheme.onSecondaryContainer;
      case DeviceConnectionState.ready:
        return context.colorScheme.onTertiaryContainer;
      case DeviceConnectionState.disabled:
        return context.colorScheme.onSurfaceVariant;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (deviceStatus.connectionState) {
      case DeviceConnectionState.connected:
        return context.colorScheme.primaryContainer;
      case DeviceConnectionState.discovering:
        return context.colorScheme.secondaryContainer;
      case DeviceConnectionState.ready:
        return context.colorScheme.tertiaryContainer;
      case DeviceConnectionState.disabled:
        return context.colorScheme.surfaceContainerHighest;
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (deviceStatus.connectionState) {
      case DeviceConnectionState.connected:
        return Colors.green;
      case DeviceConnectionState.discovering:
        return context.colorScheme.primary;
      case DeviceConnectionState.ready:
        return Colors.orange;
      case DeviceConnectionState.disabled:
        return context.colorScheme.error;
    }
  }

  String _getStatusMessage() {
    switch (deviceStatus.connectionState) {
      case DeviceConnectionState.connected:
        return 'Connected to ${deviceStatus.connectedDevicesCount} device${deviceStatus.connectedDevicesCount == 1 ? '' : 's'}';
      case DeviceConnectionState.discovering:
        return 'Searching for nearby devices...';
      case DeviceConnectionState.ready:
        return 'Ready to connect with other devices';
      case DeviceConnectionState.disabled:
        return 'Enable WiFi or Bluetooth to start sharing';
    }
  }

  String _getConnectionStatusText() {
    switch (deviceStatus.connectionState) {
      case DeviceConnectionState.connected:
        return 'Active';
      case DeviceConnectionState.discovering:
        return 'Scanning';
      case DeviceConnectionState.ready:
        return 'Ready';
      case DeviceConnectionState.disabled:
        return 'Offline';
    }
  }

  IconData _getConnectionStatusIcon() {
    switch (deviceStatus.connectionState) {
      case DeviceConnectionState.connected:
        return Icons.check_circle;
      case DeviceConnectionState.discovering:
        return Icons.search;
      case DeviceConnectionState.ready:
        return Icons.wifi;
      case DeviceConnectionState.disabled:
        return Icons.wifi_off;
    }
  }

  String _getConnectivityInfo() {
    final connectivity = <String>[];
    if (deviceStatus.isWiFiEnabled) connectivity.add('WiFi');
    if (deviceStatus.isBluetoothEnabled) connectivity.add('Bluetooth');

    if (connectivity.isEmpty) {
      return 'No connectivity available';
    } else {
      return connectivity.join(' • ');
    }
  }

  void _toggleDiscovery(BuildContext context) {
    if (deviceStatus.isDiscovering) {
      // Stop discovery logic would go here
      context.read<HomeBloc>().add(
        const NavigateToFeatureEvent('/stop-discovery'),
      );
    } else {
      // Start discovery logic would go here
      context.read<HomeBloc>().add(
        const NavigateToFeatureEvent('/start-discovery'),
      );
    }
  }

  void _viewDevices(BuildContext context) {
    context.read<HomeBloc>().add(const NavigateToFeatureEvent('/devices'));
  }
}
