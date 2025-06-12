import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mega_share/app/router/app_router.dart';
import 'package:mega_share/app/router/route_names.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import 'package:mega_share/presentation/bloc/theme_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Theme'),
                    subtitle: const Text('Light, Dark, or System'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemeDialog(context),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Transfer Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transfer Settings',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.auto_awesome),
                    title: const Text('Auto Accept'),
                    subtitle: const Text(
                      'Automatically accept transfers from trusted devices',
                    ),
                    value: false, // TODO: Get from settings
                    onChanged: (value) {
                      // TODO: Update settings
                    },
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.compress),
                    title: const Text('Compress Files'),
                    subtitle: const Text(
                      'Compress files to reduce transfer time',
                    ),
                    value: true, // TODO: Get from settings
                    onChanged: (value) {
                      // TODO: Update settings
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Privacy & Security
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy & Security',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Permissions'),
                    subtitle: const Text('Manage app permissions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.go('${RouteNames.settings}/permissions'),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.visibility),
                    title: const Text('Device Visibility'),
                    subtitle: const Text(
                      'Allow other devices to discover this device',
                    ),
                    value: true, // TODO: Get from settings
                    onChanged: (value) {
                      // TODO: Update settings
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Storage
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Storage',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('Storage Analytics'),
                    subtitle: const Text('View storage usage details'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.go('${RouteNames.settings}/storage-analytics'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services),
                    title: const Text('Clear Cache'),
                    subtitle: const Text(
                      'Free up space by clearing temporary files',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _clearCache(context),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // About
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About ShareIt'),
                    subtitle: const Text('Version 1.0.0'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('${RouteNames.settings}/about'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & Support'),
                    subtitle: const Text('Get help and documentation'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showHelp(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_7),
              title: const Text('Light'),
              onTap: () {
                context.read<ThemeBloc>().add(
                  const ChangeThemeMode(themeMode: ThemeMode.light),
                );
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_4),
              title: const Text('Dark'),
              onTap: () {
                context.read<ThemeBloc>().add(
                  const ChangeThemeMode(themeMode: ThemeMode.dark),
                );
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System'),
              onTap: () {
                context.read<ThemeBloc>().add(
                  const ChangeThemeMode(themeMode: ThemeMode.system),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all temporary files and cached data. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help documentation will be available soon'),
      ),
    );
  }
}
