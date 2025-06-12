import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../domain/entities/device_entity.dart';
import '../bloc/device_discovery_bloc.dart';
import '../bloc/device_discovery_event.dart';
import '../bloc/device_discovery_state.dart';
import '../widgets/device_card.dart';

/// Device list page with selection and filtering
class DeviceListPage extends StatelessWidget {
  final bool selectionMode;
  final List<String>? preSelectedDevices;
  final Function(List<DeviceEntity>)? onSelectionChanged;

  const DeviceListPage({
    super.key,
    this.selectionMode = false,
    this.preSelectedDevices,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<DeviceDiscoveryBloc>(),
      child: _DeviceListPageView(
        selectionMode: selectionMode,
        preSelectedDevices: preSelectedDevices,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}

class _DeviceListPageView extends StatefulWidget {
  final bool selectionMode;
  final List<String>? preSelectedDevices;
  final Function(List<DeviceEntity>)? onSelectionChanged;

  const _DeviceListPageView({
    required this.selectionMode,
    this.preSelectedDevices,
    this.onSelectionChanged,
  });

  @override
  State<_DeviceListPageView> createState() => _DeviceListPageViewState();
}

class _DeviceListPageViewState extends State<_DeviceListPageView> {
  DeviceType? _selectedDeviceType;
  ConnectionType? _selectedConnectionType;
  String _searchQuery = '';
  bool _showOnlyConnectable = false;
  bool _showOnlyRecent = false;

  @override
  void initState() {
    super.initState();
    // Pre-select devices if provided
    if (widget.preSelectedDevices != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bloc = context.read<DeviceDiscoveryBloc>();
        for (final deviceId in widget.preSelectedDevices!) {
          bloc.add(SelectDeviceEvent(deviceId));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.selectionMode
            ? const Text('Select Devices')
            : const Text('Nearby Devices'),
        actions: [
          if (widget.selectionMode)
            BlocBuilder<DeviceDiscoveryBloc, DeviceDiscoveryState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state.hasSelectedDevices
                      ? () {
                          widget.onSelectionChanged?.call(
                            state.selectedDevices.values.toList(),
                          );
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text('Done (${state.selectedDeviceCount})'),
                );
              },
            ),
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: BlocListener<DeviceDiscoveryBloc, DeviceDiscoveryState>(
              listener: (context, state) {
                if (widget.selectionMode && widget.onSelectionChanged != null) {
                  widget.onSelectionChanged!(
                    state.selectedDevices.values.toList(),
                  );
                }
              },
              child: BlocBuilder<DeviceDiscoveryBloc, DeviceDiscoveryState>(
                builder: (context, state) {
                  final filteredDevices = _getFilteredDevices(state.devices);

                  if (filteredDevices.isEmpty) {
                    return _buildEmptyState(context, state);
                  }

                  return ListView.builder(
                    itemCount: filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = filteredDevices[index];
                      return DeviceCard(
                        device: device,
                        isSelected: state.isDeviceSelected(device.id),
                        showSelection: widget.selectionMode,
                        onConnect: widget.selectionMode
                            ? null
                            : () => _connectToDevice(context, device.id),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.selectionMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                context.read<DeviceDiscoveryBloc>().add(
                  const RefreshDiscoveryEvent(),
                );
              },
              child: const Icon(Icons.refresh),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search devices...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('Connectable'),
            selected: _showOnlyConnectable,
            onSelected: (selected) {
              setState(() {
                _showOnlyConnectable = selected;
              });
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Recent'),
            selected: _showOnlyRecent,
            onSelected: (selected) {
              setState(() {
                _showOnlyRecent = selected;
              });
            },
          ),
          const SizedBox(width: 8),
          if (_selectedDeviceType != null)
            Chip(
              label: Text(_getDeviceTypeName(_selectedDeviceType!)),
              onDeleted: () {
                setState(() {
                  _selectedDeviceType = null;
                });
              },
            ),
          if (_selectedConnectionType != null) ...[
            const SizedBox(width: 8),
            Chip(
              label: Text(_getConnectionTypeName(_selectedConnectionType!)),
              onDeleted: () {
                setState(() {
                  _selectedConnectionType = null;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DeviceDiscoveryState state) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No devices match your filters',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedDeviceType = null;
                _selectedConnectionType = null;
                _showOnlyConnectable = false;
                _showOnlyRecent = false;
              });
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  List<DeviceEntity> _getFilteredDevices(List<DeviceEntity> devices) {
    return devices.where((device) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch =
            device.name.toLowerCase().contains(_searchQuery) ||
            device.deviceType.name.toLowerCase().contains(_searchQuery);
        if (!matchesSearch) return false;
      }

      // Device type filter
      if (_selectedDeviceType != null &&
          device.deviceType != _selectedDeviceType) {
        return false;
      }

      // Connection type filter
      if (_selectedConnectionType != null &&
          !device.availableConnectionMethods.contains(
            _selectedConnectionType,
          )) {
        return false;
      }

      // Connectable filter
      if (_showOnlyConnectable && !device.isConnectable) {
        return false;
      }

      // Recent filter
      if (_showOnlyRecent && !device.isRecentlySeen) {
        return false;
      }

      return true;
    }).toList();
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Devices'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Device Type'),
              subtitle: Text(_selectedDeviceType?.name ?? 'All types'),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _showDeviceTypeSelector(context),
            ),
            ListTile(
              title: const Text('Connection Type'),
              subtitle: Text(_selectedConnectionType?.name ?? 'All types'),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _showConnectionTypeSelector(context),
            ),
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

  void _showDeviceTypeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Device Type'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                _selectedDeviceType = null;
              });
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('All Types'),
          ),
          ...DeviceType.values.map(
            (type) => SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedDeviceType = type;
                });
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(_getDeviceTypeName(type)),
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectionTypeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Connection Type'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                _selectedConnectionType = null;
              });
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('All Types'),
          ),
          ...ConnectionType.values
              .where((type) => type != ConnectionType.unknown)
              .map(
                (type) => SimpleDialogOption(
                  onPressed: () {
                    setState(() {
                      _selectedConnectionType = type;
                    });
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(_getConnectionTypeName(type)),
                ),
              ),
        ],
      ),
    );
  }

  String _getDeviceTypeName(DeviceType type) {
    switch (type) {
      case DeviceType.android:
        return 'Android';
      case DeviceType.ios:
        return 'iOS';
      case DeviceType.windows:
        return 'Windows';
      case DeviceType.macos:
        return 'macOS';
      case DeviceType.linux:
        return 'Linux';
      case DeviceType.unknown:
        return 'Unknown';
    }
  }

  String _getConnectionTypeName(ConnectionType type) {
    switch (type) {
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
      case ConnectionType.unknown:
        return 'Unknown';
    }
  }

  void _connectToDevice(BuildContext context, String deviceId) {
    // TODO: Implement connection logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Connecting to device: $deviceId')));
  }
}
