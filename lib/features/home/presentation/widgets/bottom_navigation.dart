import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../pages/main_navigation_page.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  final List<NavigationItem> items;
  final Function(int) onItemTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onItemTap,
  });

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: AppConstants.shortAnimation,
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    _slideAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: -4.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    // Start animation for current index
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(BottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _updateAnimations(oldWidget.currentIndex, widget.currentIndex);
    }
  }

  void _updateAnimations(int oldIndex, int newIndex) {
    if (oldIndex < _animationControllers.length) {
      _animationControllers[oldIndex].reverse();
    }
    if (newIndex < _animationControllers.length) {
      _animationControllers[newIndex].forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              widget.items.length,
              (index) => _buildNavigationItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(int index) {
    final item = widget.items[index];
    final isSelected = index == widget.currentIndex;
    final isCenterItem = index == 2; // FAB area

    if (isCenterItem) {
      // Return spacer for FAB area
      return const SizedBox(width: 56);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleItemTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimations[index],
            _slideAnimations[index],
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? _scaleAnimations[index].value : 1.0,
              child: Transform.translate(
                offset: Offset(
                  0,
                  isSelected ? _slideAnimations[index].value : 0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.colorScheme.primaryContainer
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? context.colorScheme.primary
                                  : context.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ),
                          // Badge for notifications (if needed)
                          if (_shouldShowBadge(index))
                            Positioned(right: 4, top: 4, child: _buildBadge()),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Label
                      Text(
                        item.label,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? context.colorScheme.primary
                              : context.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Selection indicator
                      AnimatedContainer(
                        duration: AppConstants.shortAnimation,
                        margin: const EdgeInsets.only(top: 2),
                        width: isSelected ? 20 : 0,
                        height: 2,
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: context.colorScheme.error,
        shape: BoxShape.circle,
        border: Border.all(color: context.colorScheme.surface, width: 1),
      ),
    );
  }

  bool _shouldShowBadge(int index) {
    // Show badge based on tab type
    switch (index) {
      case 1: // Files - could show badge for new files
        return false;
      case 2: // Devices - could show badge for connection requests
        return false;
      case 3: // History - could show badge for completed transfers
        return false;
      case 4: // Settings - could show badge for updates
        return false;
      default:
        return false;
    }
  }

  void _handleItemTap(int index) {
    if (index != widget.currentIndex) {
      // Provide haptic feedback
      HapticFeedback.lightImpact();

      // Call the callback
      widget.onItemTap(index);
    } else {
      // Same tab tapped - provide selection feedback
      HapticFeedback.selectionClick();
      widget.onItemTap(index);
    }
  }
}

/// Bottom navigation bar with custom styling and animations
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withOpacity(0.1),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: selectedItemColor ?? context.colorScheme.primary,
        unselectedItemColor:
            unselectedItemColor ?? context.colorScheme.onSurfaceVariant,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: items,
      ),
    );
  }
}

/// Navigation item data for configuration
class NavigationConfig {
  static List<NavigationItem> getDefaultItems() {
    return [
      NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        page: const Placeholder(), // Will be replaced with actual pages
      ),
      NavigationItem(
        icon: Icons.folder_outlined,
        activeIcon: Icons.folder,
        label: 'Files',
        page: const Placeholder(),
      ),
      NavigationItem(
        icon: Icons.devices_outlined,
        activeIcon: Icons.devices,
        label: 'Devices',
        page: const Placeholder(),
      ),
      NavigationItem(
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        label: 'History',
        page: const Placeholder(),
      ),
      NavigationItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
        page: const Placeholder(),
      ),
    ];
  }

  static List<BottomNavigationBarItem> getBottomNavigationItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.folder_outlined),
        activeIcon: Icon(Icons.folder),
        label: 'Files',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.devices_outlined),
        activeIcon: Icon(Icons.devices),
        label: 'Devices',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.history_outlined),
        activeIcon: Icon(Icons.history),
        label: 'History',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];
  }
}
