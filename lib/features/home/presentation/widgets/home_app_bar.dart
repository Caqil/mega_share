import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final deviceName = _getDeviceName(state);
        final hasActiveTransfers = _hasActiveTransfers(state);

        return AppBar(
          backgroundColor: context.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
          surfaceTintColor: context.colorScheme.surfaceTint,
          leading: _buildLeading(context),
          title: _buildTitle(context, deviceName),
          actions: _buildActions(context, hasActiveTransfers),
          bottom: _buildBottom(context, state),
        );
      },
    );
  }

  Widget _buildLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.share, color: context.colorScheme.primary, size: 24),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String deviceName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.appName,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.onSurface,
          ),
        ),
        if (deviceName.isNotEmpty)
          Text(
            deviceName,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context, bool hasActiveTransfers) {
    return [
      // Search button
      IconButton(
        onPressed: () => _handleSearch(context),
        tooltip: 'Search',
        icon: Icon(Icons.search, color: context.colorScheme.onSurfaceVariant),
      ),

      // Transfer status button
      if (hasActiveTransfers)
        IconButton(
          onPressed: () => _handleActiveTransfers(context),
          tooltip: 'Active Transfers',
          icon: Stack(
            children: [
              Icon(Icons.swap_horiz, color: context.colorScheme.primary),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),

      // Menu button
      PopupMenuButton<AppBarMenuItem>(
        onSelected: (item) => _handleMenuAction(context, item),
        tooltip: 'More options',
        icon: Icon(
          Icons.more_vert,
          color: context.colorScheme.onSurfaceVariant,
        ),
        itemBuilder: (context) => _buildMenuItems(context),
      ),
    ];
  }

  PreferredSizeWidget? _buildBottom(BuildContext context, HomeState state) {
    if (state is HomeLoadedState || state is HomeDataUpdatedState) {
      final data = state is HomeLoadedState
          ? state.data
          : (state as HomeDataUpdatedState).data;

      // Show status bar if there are issues
      if (!data.permissionStatus.hasAllPermissions ||
          data.storageStatus.level == StorageLevel.critical ||
          data.deviceStatus.connectionState == DeviceConnectionState.disabled) {
        return _buildStatusBar(context, data);
      }
    }

    return null;
  }

  PreferredSizeWidget _buildStatusBar(BuildContext context, HomeData data) {
    String message = '';
    Color backgroundColor = context.colorScheme.errorContainer;
    Color textColor = context.colorScheme.onErrorContainer;
    IconData icon = Icons.warning;
    VoidCallback? onTap;

    if (!data.permissionStatus.hasAllPermissions) {
      message = 'Grant permissions to enable all features';
      backgroundColor = context.colorScheme.errorContainer;
      icon = Icons.security;
      onTap = () =>
          context.read<HomeBloc>().add(const RequestPermissionsEvent());
    } else if (data.storageStatus.level == StorageLevel.critical) {
      message =
          'Storage almost full - ${data.storageStatus.usagePercentage.toStringAsFixed(1)}% used';
      backgroundColor = context.colorScheme.errorContainer;
      icon = Icons.storage;
    } else if (data.deviceStatus.connectionState ==
        DeviceConnectionState.disabled) {
      message = 'Enable WiFi or Bluetooth for device discovery';
      backgroundColor = context.colorScheme.secondaryContainer;
      textColor = context.colorScheme.onSecondaryContainer;
      icon = Icons.wifi_off;
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(40),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 40,
          color: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios, size: 12, color: textColor),
            ],
          ),
        ),
      ),
    );
  }

  List<PopupMenuEntry<AppBarMenuItem>> _buildMenuItems(BuildContext context) {
    return [
      PopupMenuItem<AppBarMenuItem>(
        value: AppBarMenuItem.scan,
        child: ListTile(
          leading: const Icon(Icons.qr_code_scanner),
          title: const Text('Scan QR Code'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem<AppBarMenuItem>(
        value: AppBarMenuItem.qrCode,
        child: ListTile(
          leading: const Icon(Icons.qr_code),
          title: const Text('Show QR Code'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<AppBarMenuItem>(
        value: AppBarMenuItem.settings,
        child: ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem<AppBarMenuItem>(
        value: AppBarMenuItem.about,
        child: ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ];
  }

  void _handleSearch(BuildContext context) {
    context.read<HomeBloc>().add(const NavigateToFeatureEvent('/search'));
  }

  void _handleActiveTransfers(BuildContext context) {
    context.read<HomeBloc>().add(
      const NavigateToFeatureEvent('/active-transfers'),
    );
  }

  void _handleMenuAction(BuildContext context, AppBarMenuItem item) {
    switch (item) {
      case AppBarMenuItem.scan:
        context.read<HomeBloc>().add(
          const NavigateToFeatureEvent('/qr-scanner'),
        );
        break;
      case AppBarMenuItem.qrCode:
        context.read<HomeBloc>().add(const NavigateToFeatureEvent('/qr-code'));
        break;
      case AppBarMenuItem.settings:
        context.read<HomeBloc>().add(const NavigateToFeatureEvent('/settings'));
        break;
      case AppBarMenuItem.about:
        context.read<HomeBloc>().add(const NavigateToFeatureEvent('/about'));
        break;
    }
  }

  String _getDeviceName(HomeState state) {
    if (state is HomeLoadedState) {
      return state.data.deviceStatus.deviceName;
    } else if (state is HomeDataUpdatedState) {
      return state.data.deviceStatus.deviceName;
    }
    return StorageService.instance.getDeviceName();
  }

  bool _hasActiveTransfers(HomeState state) {
    if (state is HomeLoadedState) {
      return state.data.transferStatus.hasActiveTransfers;
    } else if (state is HomeDataUpdatedState) {
      return state.data.transferStatus.hasActiveTransfers;
    }
    return false;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

enum AppBarMenuItem { scan, qrCode, settings, about }
