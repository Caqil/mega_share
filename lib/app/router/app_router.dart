// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mega_share/main.dart';

import '../../features/connection/presentation/pages/connection_page.dart';
import '../../features/connection/presentation/pages/connection_request_page.dart';
import '../../features/file_management/presentation/pages/file_explorer_page.dart';
import '../../features/file_management/presentation/pages/file_selector_page.dart';
import '../../features/file_management/presentation/pages/media_gallery_page.dart';
import '../../features/file_management/domain/entities/file_entity.dart';
import '../../features/connection/domain/entities/endpoint_entity.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Route
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Home Route with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => HomePage(),
        routes: [
          // Main Dashboard
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            builder: (context, state) => const DashboardTab(),
          ),

          // File Explorer
          GoRoute(
            path: RouteNames.fileExplorer,
            name: 'fileExplorer',
            builder: (context, state) => const FileExplorerPage(),
          ),

          // Connections
          GoRoute(
            path: RouteNames.connections,
            name: 'connections',
            builder: (context, state) => const ConnectionPage(),
          ),

          // Active Transfers
          // GoRoute(
          //   path: RouteNames.activeTransfers,
          //   name: 'activeTransfers',
          //   builder: (context, state) => const TransferPage(),
          // ),
        ],
      ),

      // Connection Routes
      GoRoute(
        path: RouteNames.connectionRequest,
        name: 'connectionRequest',
        builder: (context, state) {
          final endpoint = state.extra as EndpointEntity;
          return ConnectionRequestPage(endpoint: endpoint);
        },
      ),

      GoRoute(
        path: RouteNames.qrScanner,
        name: 'qrScanner',
        builder: (context, state) => const QRScannerPage(),
      ),

      GoRoute(
        path: RouteNames.deviceDiscovery,
        name: 'deviceDiscovery',
        builder: (context, state) => const DeviceDiscoveryPage(),
      ),

      // File Management Routes
      GoRoute(
        path: RouteNames.fileSelector,
        name: 'fileSelector',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>?;
          return FileSelectorPage(
            allowedTypes: params?['allowedTypes'] as List<FileType>?,
            multiSelect: params?['multiSelect'] as bool? ?? false,
            title: params?['title'] as String? ?? 'Select Files',
            maxSelection: params?['maxSelection'] as int?,
          );
        },
      ),

      GoRoute(
        path: RouteNames.mediaGallery,
        name: 'mediaGallery',
        builder: (context, state) {
          final mediaType = state.extra as FileType? ?? FileType.image;
          return MediaGalleryPage(mediaType: mediaType);
        },
      ),

      GoRoute(
        path: RouteNames.filePreview,
        name: 'filePreview',
        builder: (context, state) {
          final file = state.extra as FileEntity;
          return FilePreviewPage(file: file);
        },
      ),

      // GoRoute(
      //   path: RouteNames.storageAnalytics,
      //   name: 'storageAnalytics',
      //   builder: (context, state) => const StorageAnalyticsPage(),
      // ),

      // Category Routes
      GoRoute(
        path: RouteNames.images,
        name: 'images',
        builder: (context, state) =>
            const MediaGalleryPage(mediaType: FileType.image),
      ),

      GoRoute(
        path: RouteNames.videos,
        name: 'videos',
        builder: (context, state) =>
            const MediaGalleryPage(mediaType: FileType.video),
      ),

      GoRoute(
        path: RouteNames.audio,
        name: 'audio',
        builder: (context, state) =>
            const MediaGalleryPage(mediaType: FileType.audio),
      ),

      GoRoute(
        path: RouteNames.documents,
        name: 'documents',
        builder: (context, state) =>
            const MediaGalleryPage(mediaType: FileType.document),
      ),

      GoRoute(
        path: RouteNames.applications,
        name: 'applications',
        builder: (context, state) =>
            const MediaGalleryPage(mediaType: FileType.application),
      ),

      // Transfer Routes
      GoRoute(
        path: RouteNames.transferHistory,
        name: 'transferHistory',
        builder: (context, state) => const TransferHistoryPage(),
      ),

      GoRoute(
        path: RouteNames.transferQueue,
        name: 'transferQueue',
        builder: (context, state) => const TransferQueuePage(),
      ),

      // Settings and Utility Routes
      // GoRoute(
      //   path: RouteNames.settings,
      //   name: 'settings',
      //   builder: (context, state) => const SettingsPage(),
      // ),

      // GoRoute(
      //   path: RouteNames.permissions,
      //   name: 'permissions',
      //   builder: (context, state) => const PermissionsPage(),
      // ),

      // GoRoute(
      //   path: RouteNames.about,
      //   name: 'about',
      //   builder: (context, state) => const AboutPage(),
      // ),
      GoRoute(
        path: RouteNames.help,
        name: 'help',
        builder: (context, state) => const HelpPage(),
      ),

      GoRoute(
        path: RouteNames.feedback,
        name: 'feedback',
        builder: (context, state) => const FeedbackPage(),
      ),

      // Error Routes
      GoRoute(
        path: RouteNames.error,
        name: 'error',
        builder: (context, state) {
          final error = state.extra as String?;
          return ErrorPage(error: error);
        },
      ),

      GoRoute(
        path: RouteNames.notFound,
        name: 'notFound',
        builder: (context, state) => const NotFoundPage(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => ErrorPage(error: state.error?.toString()),

    // Redirect logic
    redirect: (context, state) {
      // Add any global redirect logic here
      // For example, checking if user needs to grant permissions
      return null;
    },
  );

  static GoRouter get router => _router;

  // Navigation helpers
  static void go(String location, {Object? extra}) {
    _router.go(location, extra: extra);
  }

  static void push(String location, {Object? extra}) {
    _router.push(location, extra: extra);
  }

  static void pop() {
    _router.pop();
  }

  static void replace(String location, {Object? extra}) {
    _router.replace(location, extra: extra);
  }

  // Typed navigation methods
  static void goToHome() => go(RouteNames.home);

  static void goToFiles() => go(RouteNames.fileExplorer);

  static void goToConnections() => go(RouteNames.connections);

  static void goToTransfers() => go(RouteNames.activeTransfers);

  static void goToSettings() => go(RouteNames.settings);

  static void showConnectionRequest(EndpointEntity endpoint) {
    push(RouteNames.connectionRequest, extra: endpoint);
  }

  static void showFileSelector({
    List<FileType>? allowedTypes,
    bool multiSelect = false,
    String title = 'Select Files',
    int? maxSelection,
  }) {
    push(
      RouteNames.fileSelector,
      extra: {
        'allowedTypes': allowedTypes,
        'multiSelect': multiSelect,
        'title': title,
        'maxSelection': maxSelection,
      },
    );
  }

  static void showMediaGallery(FileType mediaType) {
    push(RouteNames.mediaGallery, extra: mediaType);
  }

  static void showFilePreview(FileEntity file) {
    push(RouteNames.filePreview, extra: file);
  }

  static void showStorageAnalytics() {
    push(RouteNames.storageAnalytics);
  }

  static void showQRScanner() {
    push(RouteNames.qrScanner);
  }

  static void showError(String error) {
    push(RouteNames.error, extra: error);
  }
}

// Helper widgets for placeholder pages that will be implemented
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dashboard - Main overview of app features'),
    );
  }
}

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: const Center(child: Text('QR Scanner Implementation')),
    );
  }
}

class DeviceDiscoveryPage extends StatelessWidget {
  const DeviceDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Discovery')),
      body: const Center(child: Text('Device Discovery Implementation')),
    );
  }
}

class FilePreviewPage extends StatelessWidget {
  final FileEntity file;

  const FilePreviewPage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(file.name)),
      body: Center(child: Text('File Preview for ${file.name}')),
    );
  }
}

class TransferHistoryPage extends StatelessWidget {
  const TransferHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer History')),
      body: const Center(child: Text('Transfer History Implementation')),
    );
  }
}

class TransferQueuePage extends StatelessWidget {
  const TransferQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Queue')),
      body: const Center(child: Text('Transfer Queue Implementation')),
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: const Center(child: Text('Help & Documentation')),
    );
  }
}

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: const Center(child: Text('Send Feedback')),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('404 - Page Not Found')),
    );
  }
}
