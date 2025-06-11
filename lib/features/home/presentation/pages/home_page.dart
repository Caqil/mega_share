import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/size_utils.dart' as size;
import '../../../../shared/widgets/animations/fade_in_animation.dart';
import '../../../../shared/widgets/animations/slide_animation.dart';
import '../../../../shared/widgets/common/custom_app_bar.dart';
import '../../../../shared/widgets/common/error_widget.dart';
import '../../../../shared/widgets/common/loading_widget.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/device_status_card.dart';
import '../widgets/quick_action_grid.dart';
import '../widgets/recent_transfers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _refreshController;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    // Load initial data
    context.read<HomeBloc>().add(const LoadHomeDataEvent());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: const HomeAppBar(),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: context.colorScheme.primary,
            child: _buildBody(context, state),
          );
        },
      ),
    );
  }

  void _handleStateChanges(BuildContext context, HomeState state) {
    if (state is HomeNavigationState) {
      _handleNavigation(context, state);
    } else if (state is HomeErrorState) {
      _showError(context, state.errorMessage ?? 'An error occurred');
    } else if (state is HomeDataUpdatedState && state.updateMessage != null) {
      context.showSuccessSnackBar(state.updateMessage!);
    }
  }

  void _handleNavigation(BuildContext context, HomeNavigationState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(
        context,
        state.destination,
        arguments: state.arguments,
      );
    });
  }

  void _showError(BuildContext context, String message) {
    context.showErrorSnackBar(message);
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    _refreshController.repeat();
    context.read<HomeBloc>().add(const RefreshHomeDataEvent());

    // Wait for state change or timeout
    await Future.delayed(const Duration(seconds: 2));

    _refreshController.stop();
    _refreshController.reset();

    setState(() => _isRefreshing = false);
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    switch (state) {
      case HomeInitialState():
      case HomeLoadingState():
        return const LoadingWidget(
          variant: LoadingVariant.adaptive,
          message: 'Loading home data...',
        );

      case HomeErrorState():
        return CustomErrorWidget(
          failure: state.failure,
          onRetry: () => context.read<HomeBloc>().add(
            const LoadHomeDataEvent(forceRefresh: true),
          ),
        );

      case HomeLoadedState():
      case HomeDataUpdatedState():
        final data = state is HomeLoadedState
            ? state.data
            : (state as HomeDataUpdatedState).data;
        return _buildHomeContent(context, data);

      case HomeNavigationState():
        // Keep showing previous content during navigation
        final currentData = _getCurrentData(context);
        if (currentData != null) {
          return _buildHomeContent(context, currentData);
        }
        return const LoadingWidget();
    }
  }

  Widget _buildHomeContent(BuildContext context, HomeData data) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        bottom: 100,
      ), // Space for bottom navigation
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          FadeInAnimation(
            delay: const Duration(milliseconds: 100),
            child: _buildWelcomeSection(context, data),
          ),

          const SizedBox(height: 20),

          // Device status card
          SlideAnimation(
            direction: SlideDirection.left,
            delay: const Duration(milliseconds: 200),
            child: DeviceStatusCard(deviceStatus: data.deviceStatus),
          ),

          const SizedBox(height: 20),

          // Quick actions grid
          SlideAnimation(
            direction: SlideDirection.right,
            delay: const Duration(milliseconds: 300),
            child: QuickActionGrid(
              permissionStatus: data.permissionStatus,
              onActionTap: _handleQuickAction,
            ),
          ),

          const SizedBox(height: 20),

          // Storage info card
          SlideAnimation(
            direction: SlideDirection.left,
            delay: const Duration(milliseconds: 400),
            child: _buildStorageCard(context, data.storageStatus),
          ),

          const SizedBox(height: 20),

          // Recent transfers
          if (data.recentTransfers.isNotEmpty)
            SlideAnimation(
              direction: SlideDirection.up,
              delay: const Duration(milliseconds: 500),
              child: RecentTransfers(
                transfers: data.recentTransfers,
                onTransferTap: _handleTransferTap,
                onClearHistory: _handleClearHistory,
              ),
            ),

          // Transfer status (if active)
          if (data.transferStatus.hasActiveTransfers)
            SlideAnimation(
              direction: SlideDirection.up,
              delay: const Duration(milliseconds: 600),
              child: _buildTransferStatusCard(context, data.transferStatus),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, HomeData data) {
    return Container(
      width: double.infinity,
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.deviceStatus.deviceName,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatusChips(context, data),
        ],
      ),
    );
  }

  Widget _buildStatusChips(BuildContext context, HomeData data) {
    final chips = <Widget>[];

    // Permission status chip
    if (!data.permissionStatus.hasAllPermissions) {
      chips.add(
        _buildStatusChip(
          context,
          'Permissions Required',
          Icons.security,
          context.colorScheme.error,
          onTap: () => _handleQuickAction(QuickActionType.requestPermissions),
        ),
      );
    }

    // Storage status chip
    if (data.storageStatus.level == StorageLevel.critical) {
      chips.add(
        _buildStatusChip(
          context,
          'Storage Critical',
          Icons.storage,
          context.colorScheme.error,
        ),
      );
    }

    // Connection status chip
    if (data.deviceStatus.connectionState == DeviceConnectionState.connected) {
      chips.add(
        _buildStatusChip(
          context,
          '${data.deviceStatus.connectedDevicesCount} Connected',
          Icons.devices,
          context.colorScheme.primary,
        ),
      );
    }

    if (chips.isEmpty) {
      chips.add(
        _buildStatusChip(
          context,
          'All systems ready',
          Icons.check_circle,
          Colors.green,
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  Widget _buildStatusChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard(BuildContext context, StorageStatus storage) {
    return Container(
      margin: context.responsiveHorizontalPadding,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: context.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: context.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${size.SizeUtils.formatBytes(storage.usedSpace)} of ${size.SizeUtils.formatBytes(storage.totalSpace)} used',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${storage.usagePercentage.toStringAsFixed(1)}%',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getStorageColor(context, storage.level),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: storage.usagePercentage / 100,
            backgroundColor: context.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStorageColor(context, storage.level),
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildTransferStatusCard(BuildContext context, TransferStatus status) {
    return Container(
      margin: context.responsiveHorizontalPadding,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: context.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.swap_horiz,
                color: context.colorScheme.onPrimaryContainer,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Transfers',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '${status.activeTransfers} in progress',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onPrimaryContainer
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(status.overallProgress * 100).toStringAsFixed(0)}%',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: status.overallProgress,
            backgroundColor: context.colorScheme.onPrimaryContainer.withOpacity(
              0.2,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(
              context.colorScheme.onPrimaryContainer,
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Color _getStorageColor(BuildContext context, StorageLevel level) {
    switch (level) {
      case StorageLevel.low:
        return Colors.green;
      case StorageLevel.medium:
        return Colors.orange;
      case StorageLevel.high:
        return Colors.deepOrange;
      case StorageLevel.critical:
        return context.colorScheme.error;
    }
  }

  void _handleQuickAction(QuickActionType actionType) {
    if (actionType == QuickActionType.requestPermissions) {
      context.read<HomeBloc>().add(const RequestPermissionsEvent());
    } else {
      context.read<HomeBloc>().add(QuickActionEvent(actionType));
    }
  }

  void _handleTransferTap(RecentTransfer transfer) {
    context.read<HomeBloc>().add(
      NavigateToFeatureEvent(
        '/transfer-details',
        arguments: {'transferId': transfer.id},
      ),
    );
  }

  void _handleClearHistory() {
    context.read<HomeBloc>().add(const ClearTransferHistoryEvent());
  }

  HomeData? _getCurrentData(BuildContext context) {
    final state = context.read<HomeBloc>().state;
    if (state is HomeLoadedState) {
      return state.data;
    } else if (state is HomeDataUpdatedState) {
      return state.data;
    }
    return null;
  }
}
