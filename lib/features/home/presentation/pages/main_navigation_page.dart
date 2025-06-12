import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import 'package:mega_share/features/connection/presentation/pages/connection_page.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../widgets/bottom_navigation.dart';
import 'home_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  bool _showFab = true;

  // Navigation items configuration
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      page: const HomePage(),
    ),
    NavigationItem(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder,
      label: 'Files',
      page: const ConnectionPage(), // Will be replaced with actual FilesPage
    ),
    NavigationItem(
      icon: Icons.devices_outlined,
      activeIcon: Icons.devices,
      label: 'Devices',
      page: const ConnectionPage(), // Will be replaced with actual DevicesPage
    ),
    NavigationItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      label: 'History',
      page: const ConnectionPage(), // Will be replaced with actual HistoryPage
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
      page: ConnectionPage(), // Will be replaced with actual SettingsPage
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _fabAnimationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );
    _fabAnimationController.forward();

    // Set system UI overlay style
    _updateSystemUIOverlay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _updateSystemUIOverlay() {
    final brightness = context.brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: brightness,
        systemNavigationBarColor: context.colorScheme.surface,
        systemNavigationBarIconBrightness: brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: Stack(
          children: [
            // Main content
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _navigationItems.map((item) => item.page).toList(),
            ),

            // Bottom navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavigation(
                currentIndex: _currentIndex,
                items: _navigationItems,
                onItemTap: _onNavigationTap,
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (!_showFab) return null;

    return ScaleTransition(
      scale: _fabAnimationController,
      child: FloatingActionButton(
        onPressed: _handleFabPress,
        backgroundColor: context.colorScheme.primary,
        foregroundColor: context.colorScheme.onPrimary,
        elevation: 8,
        child: const Icon(Icons.swap_horiz, size: 28),
      ),
    );
  }

  void _onNavigationTap(int index) {
    if (index == _currentIndex) {
      // If tapping the same tab, scroll to top
      _scrollToTop();
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: AppConstants.mediumAnimation,
      curve: Curves.easeInOut,
    );

    // Update FAB visibility based on selected tab
    _updateFabVisibility(index);

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Update system UI overlay if needed
    _updateSystemUIOverlay();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _updateFabVisibility(index);
  }

  void _updateFabVisibility(int index) {
    final shouldShowFab =
        index == 0 || index == 1; // Show on Home and Files tabs

    if (shouldShowFab != _showFab) {
      setState(() {
        _showFab = shouldShowFab;
      });

      if (_showFab) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }
  }

  void _scrollToTop() {
    // Try to scroll to top for the current page
    // This would need to be implemented differently for each page
    // For now, just provide haptic feedback
    HapticFeedback.selectionClick();
  }

  void _handleFabPress() {
    HapticFeedback.mediumImpact();

    switch (_currentIndex) {
      case 0: // Home - Quick transfer
        _showQuickTransferDialog();
        break;
      case 1: // Files - Quick send
        _navigateToQuickSend();
        break;
      default:
        _showQuickTransferDialog();
    }
  }

  void _showQuickTransferDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickTransferSheet(),
    );
  }

  Widget _buildQuickTransferSheet() {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Quick Transfer',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      'Send Files',
                      Icons.upload,
                      () {
                        Navigator.pop(context);
                        _navigateToQuickSend();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      'Receive Files',
                      Icons.download,
                      () {
                        Navigator.pop(context);
                        _navigateToQuickReceive();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: context.colorScheme.primary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQuickSend() {
    context.read<HomeBloc>().add(
      const NavigateToFeatureEvent('/file-selection'),
    );
  }

  void _navigateToQuickReceive() {
    context.read<HomeBloc>().add(const NavigateToFeatureEvent('/receive'));
  }

  Future<bool> _handleBackPress() async {
    if (_currentIndex != 0) {
      // If not on home tab, go to home
      _onNavigationTap(0);
      return false;
    }

    // Show exit confirmation dialog
    final shouldExit = await _showExitDialog();
    return shouldExit;
  }

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit ShareIt?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/// Navigation item model
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });
}
