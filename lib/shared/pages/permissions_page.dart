import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import 'package:mega_share/core/utils/permission_utils.dart';
import 'package:mega_share/shared/widgets/common/custom_button.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  Map<String, bool> _permissionStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    final status = await PermissionUtils.getPermissionStatus();
    setState(() {
      _permissionStatus = status;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.security,
                            size: 48,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'App Permissions',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ShareIt needs these permissions to function properly',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Permission List
                  Text(
                    'Required Permissions',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildPermissionCard(
                    'Storage',
                    'Access files and folders on your device',
                    Icons.storage,
                    _permissionStatus['storage'] ?? false,
                    () => _requestPermission('storage'),
                  ),

                  _buildPermissionCard(
                    'Location',
                    'Discover nearby devices for file sharing',
                    Icons.location_on,
                    _permissionStatus['location'] ?? false,
                    () => _requestPermission('location'),
                  ),

                  _buildPermissionCard(
                    'Camera',
                    'Scan QR codes for quick device connection',
                    Icons.camera_alt,
                    _permissionStatus['camera'] ?? false,
                    () => _requestPermission('camera'),
                  ),

                  _buildPermissionCard(
                    'Notifications',
                    'Show transfer progress and completion updates',
                    Icons.notifications,
                    _permissionStatus['notification'] ?? false,
                    () => _requestPermission('notification'),
                  ),

                  if (_permissionStatus['nearby_devices'] != null)
                    _buildPermissionCard(
                      'Nearby Devices',
                      'Connect to nearby devices via WiFi Direct',
                      Icons.devices,
                      _permissionStatus['nearby_devices'] ?? false,
                      () => _requestPermission('nearby_devices'),
                    ),

                  const SizedBox(height: 32),

                  // Grant All Button
                  if (!_allPermissionsGranted())
                    CustomButton(
                      text: 'Grant All Permissions',
                      onPressed: _requestAllPermissions,
                      variant: ButtonVariant.primary,
                      icon: Icons.check_circle,
                    ),

                  const SizedBox(height: 16),

                  // App Settings Button
                  CustomButton(
                    text: 'Open App Settings',
                    onPressed: _openAppSettings,
                    variant: ButtonVariant.outline,
                    icon: Icons.settings,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPermissionCard(
    String title,
    String description,
    IconData icon,
    bool isGranted,
    VoidCallback onRequest,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isGranted
                    ? context.colorScheme.primaryContainer
                    : context.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isGranted
                    ? context.colorScheme.primary
                    : context.colorScheme.error,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isGranted ? Icons.check_circle : Icons.error,
                        size: 16,
                        color: isGranted
                            ? context.colorScheme.primary
                            : context.colorScheme.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!isGranted)
              TextButton(onPressed: onRequest, child: const Text('Grant')),
          ],
        ),
      ),
    );
  }

  bool _allPermissionsGranted() {
    return _permissionStatus.values.every((granted) => granted);
  }

  Future<void> _requestPermission(String permissionType) async {
    bool granted = false;

    switch (permissionType) {
      case 'storage':
        granted = await PermissionUtils.requestStoragePermissions();
        break;
      case 'location':
        granted = await PermissionUtils.requestLocationPermissions();
        break;
      case 'camera':
        granted = await PermissionUtils.requestCameraPermissions();
        break;
      case 'notification':
        granted = await PermissionUtils.requestNotificationPermissions();
        break;
      case 'nearby_devices':
        // Handle nearby devices permission
        break;
    }

    if (granted) {
      await _loadPermissionStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$permissionType permission granted')),
        );
      }
    }
  }

  Future<void> _requestAllPermissions() async {
    await PermissionUtils.requestAllPermissions();
    await _loadPermissionStatus();
  }

  Future<void> _openAppSettings() async {
    await PermissionUtils.openAppSettings();
  }
}
