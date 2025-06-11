import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/animations/transfer_animation.dart';
import '../bloc/device_discovery_bloc.dart';
import '../bloc/device_discovery_state.dart';

/// Discovery status indicator widget
class DiscoveryStatusIndicator extends StatelessWidget {
  const DiscoveryStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceDiscoveryBloc, DeviceDiscoveryState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading:
              (
                isDiscovering,
                isAdvertising,
                devices,
                selectedDevices,
                discoveryResult,
              ) => _buildLoadingIndicator(
                context,
                isDiscovering,
                isAdvertising,
                devices.length,
              ),
          success:
              (
                devices,
                isDiscovering,
                isAdvertising,
                selectedDevices,
                discoveryResult,
              ) => _buildSuccessIndicator(
                context,
                devices.length,
                isDiscovering,
                isAdvertising,
              ),
          error:
              (
                failure,
                isDiscovering,
                isAdvertising,
                devices,
                selectedDevices,
                discoveryResult,
              ) => _buildErrorIndicator(context, failure.message),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(
    BuildContext context,
    bool isDiscovering,
    bool isAdvertising,
    int deviceCount,
  ) {
    if (!isDiscovering && !isAdvertising) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: context.colorScheme.primaryContainer,
      child: Row(
        children: [
          PulseAnimation(
            child: Icon(
              isDiscovering ? Icons.search : Icons.radar,
              color: context.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLoadingTitle(isDiscovering, isAdvertising),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (deviceCount > 0)
                  Text(
                    '$deviceCount device${deviceCount == 1 ? '' : 's'} found',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onPrimaryContainer.withOpacity(
                        0.8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildStatusDots(context),
        ],
      ),
    );
  }

  Widget _buildSuccessIndicator(
    BuildContext context,
    int deviceCount,
    bool isDiscovering,
    bool isAdvertising,
  ) {
    if (deviceCount == 0 && !isDiscovering && !isAdvertising) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: context.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(
            deviceCount > 0 ? Icons.devices : Icons.search_off,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              deviceCount > 0
                  ? '$deviceCount device${deviceCount == 1 ? '' : 's'} available'
                  : 'No devices found',
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (isAdvertising)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PulseAnimation(
                    child: Icon(
                      Icons.radar,
                      size: 16,
                      color: context.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Discoverable',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator(BuildContext context, String errorMessage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: context.colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: context.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discovery Failed',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  errorMessage,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onErrorContainer.withOpacity(
                      0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDots(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: context.colorScheme.onPrimaryContainer.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  String _getLoadingTitle(bool isDiscovering, bool isAdvertising) {
    if (isDiscovering && isAdvertising) {
      return 'Discovering & Advertising';
    } else if (isDiscovering) {
      return 'Searching for devices...';
    } else if (isAdvertising) {
      return 'Device is discoverable';
    }
    return 'Active';
  }
}
