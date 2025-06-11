import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/connection_bloc.dart';
import '../bloc/connection_event.dart';
import '../bloc/connection_state.dart' as state;

class WiFiHotspotToggle extends StatelessWidget {
  final bool showLabel;
  final MainAxisAlignment alignment;

  const WiFiHotspotToggle({
    super.key,
    this.showLabel = true,
    this.alignment = MainAxisAlignment.spaceBetween,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ConnectionBloc, state.ConnectionState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: alignment,
            children: [
              if (showLabel) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: state.isWiFiHotspotEnabled
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.router,
                        color: state.isWiFiHotspotEnabled
                            ? Colors.green
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WiFi Hotspot',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.isWiFiHotspotEnabled
                              ? 'Devices can connect to you'
                              : 'Allow devices to connect',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              Switch(
                value: state.isWiFiHotspotEnabled,
                onChanged: (value) {
                  if (value) {
                    context.read<ConnectionBloc>().add(
                      const EnableWiFiHotspot(),
                    );
                  } else {
                    context.read<ConnectionBloc>().add(
                      const DisableWiFiHotspot(),
                    );
                  }
                },
                activeColor: Colors.green,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        );
      },
    );
  }
}
