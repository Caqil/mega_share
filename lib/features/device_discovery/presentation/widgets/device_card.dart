// lib/features/device_discovery/presentation/widgets/device_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../domain/entities/device_entity.dart';
import '../bloc/device_discovery_bloc.dart';
import '../bloc/device_discovery_event.dart';

/// Device card widget
class DeviceCard extends StatelessWidget {
  final DeviceEntity device;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;
  final bool showSelection;

  const DeviceCard({
    super.key,
    required this.device,
    this.isSelected = false,
    this.onTap,
    this.onConnect,
    this.showSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          if (showSelection) {
            final bloc = context.read<DeviceDiscoveryBloc>();
            if (isSelected) {
              bloc.add(DeselectDeviceEvent(device.id));
            } else {
              bloc.add(SelectDeviceEvent(device.id));
            }
          }
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildDeviceIcon(colorScheme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getDeviceTypeText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showSelection)
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected ? colorScheme.primary : null,
                    ),
                  if (!showSelection) ...[
                    _buildSignalStrength(colorScheme),
                    const SizedBox(width: 8),
                    if (device.isConnected)
                      Icon(Icons.link, color: colorScheme.primary, size: 20)
                    else if (device.isConnectable)
                      IconButton(
                        onPressed: onConnect,
                        icon: const Icon(Icons.link),
                        tooltip: 'Connect',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildConnectionMethods(),
                  const Spacer(),
                  _buildLastSeenTime(theme),
                ],
              ),
              if (device.distance != null) ...[
                const SizedBox(height: 8),
                _buildDistanceInfo(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceIcon(ColorScheme colorScheme) {
    IconData iconData;
    Color iconColor;

    switch (device.deviceType) {
      case DeviceType.android:
        iconData = Icons.android;
        iconColor = Colors.green;
        break;
      case DeviceType.ios:
        iconData = Icons.phone_iphone;
        iconColor = Colors.blue;
        break;
      case DeviceType.windows:
        iconData = Icons.computer;
        iconColor = Colors.blueAccent;
        break;
      case DeviceType.macos:
        iconData = Icons.laptop_mac;
        iconColor = Colors.grey;
        break;
      case DeviceType.linux:
        iconData = Icons.computer;
        iconColor = Colors.orange;
        break;
      case DeviceType.unknown:
        iconData = Icons.device_unknown;
        iconColor = colorScheme.onSurface.withOpacity(0.6);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildSignalStrength(ColorScheme colorScheme) {
    Color signalColor;
    IconData signalIcon;

    switch (device.signalStrengthCategory) {
      case SignalStrength.excellent:
        signalColor = Colors.green;
        signalIcon = Icons.signal_wifi_4_bar;
        break;
      case SignalStrength.good:
        signalColor = Colors.lightGreen;
        signalIcon = Icons.signal_wifi_4_bar;
        break;
      case SignalStrength.fair:
        signalColor = Colors.orange;
        signalIcon = Icons.wifi_2_bar;
        break;
      case SignalStrength.poor:
        signalColor = Colors.deepOrange;
        signalIcon = Icons.wifi_1_bar;
        break;
      case SignalStrength.veryPoor:
        signalColor = Colors.red;
        signalIcon = Icons.signal_wifi_0_bar;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(signalIcon, color: signalColor, size: 16),
        const SizedBox(width: 4),
        Text(
          '${device.signalStrength}%',
          style: TextStyle(
            color: signalColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionMethods() {
    final methods = device.availableConnectionMethods;
    if (methods.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      children: methods.take(3).map((method) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getMethodColor(method).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _getMethodColor(method).withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            _getMethodText(method),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _getMethodColor(method),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLastSeenTime(ThemeData theme) {
    final now = DateTime.now();
    final difference = now.difference(device.lastSeen);

    String timeText;
    if (difference.inSeconds < 30) {
      timeText = 'Just now';
    } else if (difference.inMinutes < 1) {
      timeText = '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      timeText = '${difference.inMinutes}m ago';
    } else {
      timeText = '${difference.inHours}h ago';
    }

    return Text(
      timeText,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }

  Widget _buildDistanceInfo(ThemeData theme) {
    if (device.distance == null) return const SizedBox.shrink();

    final distance = device.distance!;
    String distanceText;

    if (distance < 1) {
      distanceText = '${(distance * 100).round()} cm';
    } else if (distance < 1000) {
      distanceText = '${distance.round()} m';
    } else {
      distanceText = '${(distance / 1000).toStringAsFixed(1)} km';
    }

    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 14,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 4),
        Text(
          'Distance: $distanceText',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  String _getDeviceTypeText() {
    switch (device.deviceType) {
      case DeviceType.android:
        return 'Android Device';
      case DeviceType.ios:
        return 'iOS Device';
      case DeviceType.windows:
        return 'Windows PC';
      case DeviceType.macos:
        return 'Mac Computer';
      case DeviceType.linux:
        return 'Linux Computer';
      case DeviceType.unknown:
        return 'Unknown Device';
    }
  }

  Color _getMethodColor(ConnectionType method) {
    switch (method) {
      case ConnectionType.nearbyConnections:
        return Colors.blue;
      case ConnectionType.wifiDirect:
        return Colors.green;
      case ConnectionType.wifiHotspot:
        return Colors.orange;
      case ConnectionType.bluetooth:
        return Colors.indigo;
      case ConnectionType.qrCode:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMethodText(ConnectionType method) {
    switch (method) {
      case ConnectionType.nearbyConnections:
        return 'Nearby';
      case ConnectionType.wifiDirect:
        return 'WiFi';
      case ConnectionType.wifiHotspot:
        return 'Hotspot';
      case ConnectionType.bluetooth:
        return 'BT';
      case ConnectionType.qrCode:
        return 'QR';
      default:
        return 'Unknown';
    }
  }
}
