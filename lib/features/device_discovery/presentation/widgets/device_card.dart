
import 'package:flutter/material.dart';
import 'package:mega_share/core/extensions/context_extensions.dart' hide DeviceType;
import '../../../../core/constants/connection_constants.dart';
import '../../../../shared/widgets/animations/scale_animation.dart';
import '../../domain/entities/device_entity.dart';

/// Device card widget for displaying discovered devices
class DeviceCard extends StatelessWidget {
  final DeviceEntity device;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(bool?)? onSelectionChanged;
  final bool showSelection;
  final bool showDetails;
  
  const DeviceCard({
    super.key,
    required this.device,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.onSelectionChanged,
    this.showSelection = false,
    this.showDetails = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return ScaleAnimation(
      child: Card(
        elevation: isSelected ? 8 : 2,
        color: isSelected 
            ? context.colorScheme.primaryContainer 
            : context.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected 
                ? context.colorScheme.primary
                : context.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Device icon and signal indicator
                _buildDeviceIcon(context),
                const SizedBox(width: 16),
                
                // Device info
                Expanded(
                  child: _buildDeviceInfo(context),
                ),
                
                // Selection checkbox or action buttons
                if (showSelection)
                  _buildSelectionCheckbox(context)
                else
                  _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDeviceIcon(BuildContext context) {
    return Stack(
      children: [
        // Main device icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _getDeviceColor(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Icon(
            _getDeviceIcon(),
            size: 28,
            color: _getDeviceColor(context),
          ),
        ),
        
        // Signal strength indicator
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _getSignalColor(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colorScheme.surface,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                _getSignalIcon(),
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        // Connection status indicator
        if (device.isConnected)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildDeviceInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Device name
        Text(
          device.displayName,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected 
                ? context.colorScheme.onPrimaryContainer
                : context.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Device type and status
        Row(
          children: [
            Text(
              _getDeviceTypeText(),
              style: context.textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? context.colorScheme.onPrimaryContainer.withOpacity(0.8)
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _getStatusText(),
              style: context.textTheme.bodySmall?.copyWith(
                color: _getStatusColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        if (showDetails) ...[
          const SizedBox(height: 8),
          
          // Additional details
          _buildDeviceDetails(context),
        ],
      ],
    );
  }
  
  Widget _buildDeviceDetails(BuildContext context) {
    final details = <Widget>[];
    
    // Signal strength
    details.add(_buildDetailChip(
      context,
      icon: Icons.signal_cellular_alt,
      text: '${device.signalStrength}%',
      color: _getSignalColor(context),
    ));
    
    // Last seen
    if (!device.isRecentlySeen) {
      details.add(_buildDetailChip(
        context,
        icon: Icons.access_time,
        text: _getLastSeenText(),
        color: context.colorScheme.onSurfaceVariant,
      ));
    }
    
    // Connection methods
    if (device.availableConnectionMethods.isNotEmpty) {
      details.add(_buildDetailChip(
        context,
        icon: Icons.wifi,
        text: _getConnectionMethodsText(),
        color: context.colorScheme.primary,
      ));
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: details,
    );
  }
  
  Widget _buildDetailChip(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSelectionCheckbox(BuildContext context) {
    return Checkbox(
      value: isSelected,
      onChanged: onSelectionChanged,
      activeColor: context.colorScheme.primary,
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (device.isConnectable)
          _buildActionButton(
            context,
            icon: device.isConnected ? Icons.sync : Icons.send,
            tooltip: device.isConnected ? 'Transfer' : 'Connect',
            onPressed: onTap,
          )
        else
          _buildActionButton(
            context,
            icon: Icons.block,
            tooltip: 'Not Available',
            onPressed: null,
          ),
        
        const SizedBox(height: 8),
        
        _buildActionButton(
          context,
          icon: Icons.info_outline,
          tooltip: 'Details',
          onPressed: onLongPress,
        ),
      ],
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: onPressed != null 
            ? context.colorScheme.primaryContainer
            : context.colorScheme.surfaceContainerHighest,
        foregroundColor: onPressed != null
            ? context.colorScheme.onPrimaryContainer
            : context.colorScheme.onSurfaceVariant,
      ),
    );
  }
  
  IconData _getDeviceIcon() {
    switch (device.deviceType) {
      case  DeviceType.android:
        return Icons.android;
      case  DeviceType.ios:
        return Icons.phone_iphone;
      case  DeviceType.windows:
        return Icons.computer;
      case  DeviceType.macos:
        return Icons.laptop_mac;
      case  DeviceType.linux:
        return Icons.computer;
      case  DeviceType.unknown:
        return Icons.device_unknown;
    }
  }
  
  Color _getDeviceColor(BuildContext context) {
    switch (device.deviceType) {
      case  DeviceType.android:
        return Colors.green;
      case  DeviceType.ios:
        return Colors.blue;
      case  DeviceType.windows:
        return Colors.blue;
      case  DeviceType.macos:
        return Colors.grey;
      case  DeviceType.linux:
        return Colors.orange;
      case  DeviceType.unknown:
        return context.colorScheme.onSurfaceVariant;
    }
  }
  
  IconData _getSignalIcon() {
    switch (device.signalStrengthCategory) {
      case SignalStrength.excellent:
        return Icons.signal_cellular_4_bar;
      case SignalStrength.good:
        return Icons.signal_cellular_4_bar;
      case SignalStrength.fair:
        return Icons.signal_cellular_alt_2_bar;
      case SignalStrength.poor:
        return Icons.signal_cellular_alt_1_bar;
      case SignalStrength.veryPoor:
        return Icons.signal_cellular_0_bar;
    }
  }
  
  Color _getSignalColor(BuildContext context) {
    switch (device.signalStrengthCategory) {
      case SignalStrength.excellent:
      case SignalStrength.good:
        return Colors.green;
      case SignalStrength.fair:
        return Colors.orange;
      case SignalStrength.poor:
      case SignalStrength.veryPoor:
        return Colors.red;
    }
  }
  
  String _getDeviceTypeText() {
    switch (device.deviceType) {
      case  DeviceType.android:
        return 'Android';
      case  DeviceType.ios:
        return 'iPhone';
      case  DeviceType.windows:
        return 'Windows';
      case  DeviceType.macos:
        return 'Mac';
      case  DeviceType.linux:
        return 'Linux';
      case  DeviceType.unknown:
        return 'Unknown';
    }
  }
  
  String _getStatusText() {
    if (device.isConnected) return 'Connected';
    if (device.isConnectable) return 'Available';
    if (device.isStale) return 'Offline';
    return 'Discovering';
  }
  
  Color _getStatusColor(BuildContext context) {
    if (device.isConnected) return Colors.green;
    if (device.isConnectable) return context.colorScheme.primary;
    if (device.isStale) return Colors.red;
    return context.colorScheme.onSurfaceVariant;
  }
  
  String _getLastSeenText() {
    final now = DateTime.now();
    final difference = now.difference(device.lastSeen);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
  
  String _getConnectionMethodsText() {
    final methods = device.availableConnectionMethods;
    if (methods.isEmpty) return 'None';
    if (methods.length == 1) return methods.first.name;
    return '${methods.length} methods';
  }
}
