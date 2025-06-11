import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/permission_utils.dart';
import '../../../../shared/widgets/animations/fade_in_animation.dart';
import '../../../../shared/widgets/animations/slide_animation.dart';
import '../../../../shared/widgets/common/custom_button.dart';
import 'main_navigation_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final StorageService _storageService = StorageService.instance;
  final PermissionService _permissionService = PermissionService.instance;

  int _currentPage = 0;
  bool _isProcessing = false;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Welcome to ShareIt',
      description:
          'Transfer files between devices instantly without internet connection',
      icon: Icons.share_outlined,
      animation: 'welcome',
    ),
    OnboardingStep(
      title: 'Lightning Fast Transfers',
      description:
          'Share photos, videos, documents and apps at incredible speeds',
      icon: Icons.flash_on_outlined,
      animation: 'speed',
    ),
    OnboardingStep(
      title: 'Multiple Connection Methods',
      description:
          'Connect via WiFi Direct, Bluetooth, or QR codes for maximum compatibility',
      icon: Icons.devices_outlined,
      animation: 'devices',
    ),
    OnboardingStep(
      title: 'Secure & Private',
      description:
          'Your files stay private with direct device-to-device transfers',
      icon: Icons.security_outlined,
      animation: 'security',
    ),
    OnboardingStep(
      title: 'Grant Permissions',
      description:
          'We need some permissions to enable file sharing between devices',
      icon: Icons.admin_panel_settings_outlined,
      animation: 'permissions',
      requiresAction: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _updateSystemUIOverlay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: context.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _steps.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _handleSkip,
                    child: Text(
                      'Skip',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _steps.length,
                itemBuilder: (context, index) =>
                    _buildPage(_steps[index], index),
              ),
            ),

            // Page indicators and navigation
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingStep step, int index) {
    return Padding(
      padding: context.responsivePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Animation
          FadeInAnimation(
            delay: Duration(milliseconds: 200 + (index * 100)),
            child: _buildStepIcon(step),
          ),

          const SizedBox(height: 48),

          // Title
          SlideAnimation(
            direction: SlideDirection.up,
            delay: Duration(milliseconds: 400 + (index * 100)),
            child: Text(
              step.title,
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          SlideAnimation(
            direction: SlideDirection.up,
            delay: Duration(milliseconds: 600 + (index * 100)),
            child: Text(
              step.description,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onPrimary.withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Action button for permission step
          if (step.requiresAction)
            SlideAnimation(
              direction: SlideDirection.up,
              delay: Duration(milliseconds: 800 + (index * 100)),
              child: _buildPermissionSection(),
            ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(OnboardingStep step) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: context.colorScheme.onPrimary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colorScheme.onPrimary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Icon(step.icon, size: 64, color: context.colorScheme.onPrimary),
    );
  }

  Widget _buildPermissionSection() {
    return Column(
      children: [
        CustomButton(
          text: _isProcessing ? 'Requesting...' : 'Grant Permissions',
          onPressed: _isProcessing ? null : _handlePermissionRequest,
          isLoading: _isProcessing,
          backgroundColor: context.colorScheme.onPrimary,
          textColor: context.colorScheme.primary,
          isExpanded: true,
          icon: Icons.security,
        ),

        const SizedBox(height: 16),

        Text(
          'Permissions needed:',
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.onPrimary.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        ..._buildPermissionList(),
      ],
    );
  }

  List<Widget> _buildPermissionList() {
    final permissions = [
      PermissionItem(
        icon: Icons.folder,
        title: 'Storage Access',
        description: 'To access and share your files',
      ),
      PermissionItem(
        icon: Icons.location_on,
        title: 'Location',
        description: 'To discover nearby devices',
      ),
      PermissionItem(
        icon: Icons.camera_alt,
        title: 'Camera',
        description: 'To scan QR codes for connection',
      ),
      PermissionItem(
        icon: Icons.notifications,
        title: 'Notifications',
        description: 'To show transfer progress',
      ),
    ];

    return permissions
        .map(
          (permission) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  permission.icon,
                  size: 20,
                  color: context.colorScheme.onPrimary.withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        permission.title,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onPrimary.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        permission.description,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onPrimary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _steps.length,
              (index) => _buildPageIndicator(index),
            ),
          ),

          const SizedBox(height: 32),

          // Navigation buttons
          Row(
            children: [
              // Previous button
              if (_currentPage > 0)
                Expanded(
                  child: CustomButton(
                    text: 'Previous',
                    onPressed: _handlePrevious,
                    variant: ButtonVariant.outline,
                    backgroundColor: Colors.transparent,
                    textColor: context.colorScheme.onPrimary,
                  ),
                ),

              if (_currentPage > 0) const SizedBox(width: 16),

              // Next/Get Started button
              Expanded(
                flex: _currentPage == 0 ? 1 : 1,
                child: CustomButton(
                  text: _getNextButtonText(),
                  onPressed: _handleNext,
                  backgroundColor: context.colorScheme.onPrimary,
                  textColor: context.colorScheme.primary,
                  isLoading: _isProcessing,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? context.colorScheme.onPrimary
            : context.colorScheme.onPrimary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  String _getNextButtonText() {
    if (_currentPage == _steps.length - 1) {
      return 'Get Started';
    } else if (_steps[_currentPage].requiresAction) {
      return 'Continue';
    } else {
      return 'Next';
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    HapticFeedback.lightImpact();
  }

  void _handleSkip() {
    _completeOnboarding();
  }

  void _handlePrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNext() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _handlePermissionRequest() async {
    setState(() => _isProcessing = true);

    try {
      final granted = await _permissionService.requestAllPermissions();

      if (granted == PermissionStatus.allGranted) {
        context.showSuccessSnackBar('All permissions granted successfully!');
        await Future.delayed(const Duration(seconds: 1));
        _handleNext();
      } else if (granted == PermissionStatus.partiallyGranted) {
        context.showInfoSnackBar(
          'Some permissions granted. You can grant others later in settings.',
        );
        await Future.delayed(const Duration(seconds: 1));
        _handleNext();
      } else {
        _showPermissionDialog();
      }
    } catch (e) {
      context.showErrorSnackBar(
        'Failed to request permissions. Please try again.',
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'ShareIt needs these permissions to function properly. '
          'You can grant them later in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleNext();
            },
            child: const Text('Continue Anyway'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PermissionUtils.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    try {
      // Mark onboarding as completed
      await _storageService.setFirstTimeUser(false);

      // Navigate to main app
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavigationPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: AppConstants.mediumAnimation,
          ),
        );
      }
    } catch (e) {
      context.showErrorSnackBar(
        'Failed to complete onboarding. Please try again.',
      );
    }
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final String animation;
  final bool requiresAction;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.animation,
    this.requiresAction = false,
  });
}

class PermissionItem {
  final IconData icon;
  final String title;
  final String description;

  const PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
