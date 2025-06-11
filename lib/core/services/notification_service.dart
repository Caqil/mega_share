import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/date_time_utils.dart';
import 'logger_service.dart';
import 'storage_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Notification management service with complete handlers and scheduling
class NotificationService {
  static NotificationService? _instance;
  final LoggerService _logger = LoggerService.instance;
  final StorageService _storageService = StorageService.instance;

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  // Global navigator key for navigation from notification handlers
  static GlobalKey<NavigatorState>? _navigatorKey;

  // Callback functions for different notification actions
  Function(String deviceName, String? actionId)? _onConnectionRequestCallback;
  Function(String deviceName)? _onDeviceFoundCallback;
  Function()? _onTransferCompleteCallback;
  Function()? _onTransferFailedCallback;

  // Notification channels
  static const String _transferChannelId = 'transfer_channel';
  static const String _transferChannelName = 'File Transfers';
  static const String _transferChannelDescription =
      'Notifications for file transfer progress and completion';

  static const String _deviceChannelId = 'device_channel';
  static const String _deviceChannelName = 'Device Discovery';
  static const String _deviceChannelDescription =
      'Notifications for device discovery and connections';

  static const String _generalChannelId = 'general_channel';
  static const String _generalChannelName = 'General';
  static const String _generalChannelDescription = 'General app notifications';

  static const String _reminderChannelId = 'reminder_channel';
  static const String _reminderChannelName = 'Reminders';
  static const String _reminderChannelDescription =
      'Scheduled reminders and alerts';

  // Notification IDs
  static const int _transferProgressId = 1000;
  static const int _transferCompleteId = 1001;
  static const int _transferFailedId = 1002;
  static const int _deviceFoundId = 2000;
  static const int _connectionRequestId = 2001;
  static const int _generalNotificationId = 3000;
  static const int _reminderNotificationId = 4000;

  NotificationService._();

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      _notificationsPlugin = FlutterLocalNotificationsPlugin();

      // Initialize timezone data for scheduling
      tz.initializeTimeZones();

      // Android initialization
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS initialization
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize with callback for notification taps
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channels for Android
      await _createNotificationChannels();

      _isInitialized = true;
      _logger.info('NotificationService initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize NotificationService: $e');
      rethrow;
    }
  }

  /// Set global navigator key for navigation from notification handlers
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Set callback functions for notification actions
  void setNotificationCallbacks({
    Function(String deviceName, String? actionId)? onConnectionRequest,
    Function(String deviceName)? onDeviceFound,
    Function()? onTransferComplete,
    Function()? onTransferFailed,
  }) {
    _onConnectionRequestCallback = onConnectionRequest;
    _onDeviceFoundCallback = onDeviceFound;
    _onTransferCompleteCallback = onTransferComplete;
    _onTransferFailedCallback = onTransferFailed;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (!_isInitialized) return false;

      // Check app-level setting
      final appSetting = _storageService.getNotificationsEnabled();
      if (!appSetting) return false;

      // Check system-level permission
      if (Platform.isAndroid) {
        final permission = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled();
        return permission ?? false;
      } else if (Platform.isIOS) {
        final permission = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return permission ?? false;
      }

      return true;
    } catch (e) {
      _logger.error('Error checking notification permissions: $e');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return await androidImplementation?.requestNotificationsPermission() ??
            false;
      } else if (Platform.isIOS) {
        final iosImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        return await iosImplementation?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
      return true;
    } catch (e) {
      _logger.error('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Show transfer progress notification
  Future<void> showTransferProgress({
    required String fileName,
    required int progress,
    required String speedText,
    required String eta,
    bool isReceiving = false,
  }) async {
    try {
      if (!await areNotificationsEnabled()) return;

      final title = isReceiving ? 'Receiving File' : 'Sending File';
      final body = '$fileName\n$speedText • ETA: $eta';

      final androidDetails = AndroidNotificationDetails(
        _transferChannelId,
        _transferChannelName,
        channelDescription: _transferChannelDescription,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        showProgress: true,
        maxProgress: 100,
        progress: progress,
        indeterminate: false,
        autoCancel: false,
        playSound: false,
        enableVibration: false,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _transferProgressId,
        title,
        body,
        details,
        payload: 'transfer_progress',
      );
    } catch (e) {
      _logger.error('Error showing transfer progress notification: $e');
    }
  }

  /// Show transfer complete notification
  Future<void> showTransferComplete({
    required String fileName,
    required String transferTime,
    required String fileSize,
    bool isReceiving = false,
  }) async {
    try {
      if (!await areNotificationsEnabled()) return;

      // Cancel progress notification
      await _notificationsPlugin.cancel(_transferProgressId);

      final title = isReceiving
          ? 'File Received Successfully'
          : 'File Sent Successfully';
      final body = '$fileName ($fileSize)\nCompleted in $transferTime';

      const androidDetails = AndroidNotificationDetails(
        _transferChannelId,
        _transferChannelName,
        channelDescription: _transferChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        autoCancel: true,
        playSound: true,
        icon: '@drawable/ic_check',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _transferCompleteId,
        title,
        body,
        details,
        payload: 'transfer_complete',
      );
    } catch (e) {
      _logger.error('Error showing transfer complete notification: $e');
    }
  }

  /// Show transfer failed notification
  Future<void> showTransferFailed({
    required String fileName,
    required String errorMessage,
    bool isReceiving = false,
  }) async {
    try {
      if (!await areNotificationsEnabled()) return;

      // Cancel progress notification
      await _notificationsPlugin.cancel(_transferProgressId);

      final title = isReceiving
          ? 'File Reception Failed'
          : 'File Transfer Failed';
      final body = '$fileName\n$errorMessage';

      const androidDetails = AndroidNotificationDetails(
        _transferChannelId,
        _transferChannelName,
        channelDescription: _transferChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        autoCancel: true,
        playSound: true,
        icon: '@drawable/ic_error',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _transferFailedId,
        title,
        body,
        details,
        payload: 'transfer_failed',
      );
    } catch (e) {
      _logger.error('Error showing transfer failed notification: $e');
    }
  }

  /// Show device found notification
  Future<void> showDeviceFound({
    required String deviceName,
    required String deviceType,
  }) async {
    try {
      if (!await areNotificationsEnabled()) return;

      const title = 'Device Found';
      final body = '$deviceName ($deviceType) is available for file sharing';

      const androidDetails = AndroidNotificationDetails(
        _deviceChannelId,
        _deviceChannelName,
        channelDescription: _deviceChannelDescription,
        importance: Importance.low,
        priority: Priority.low,
        autoCancel: true,
        playSound: false,
        icon: '@drawable/ic_device',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _deviceFoundId,
        title,
        body,
        details,
        payload: 'device_found:$deviceName',
      );
    } catch (e) {
      _logger.error('Error showing device found notification: $e');
    }
  }

  /// Show connection request notification
  Future<void> showConnectionRequest({
    required String deviceName,
    required String deviceType,
  }) async {
    try {
      if (!await areNotificationsEnabled()) return;

      const title = 'Connection Request';
      final body = '$deviceName ($deviceType) wants to connect';

      const androidDetails = AndroidNotificationDetails(
        _deviceChannelId,
        _deviceChannelName,
        channelDescription: _deviceChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        autoCancel: false,
        playSound: true,
        icon: '@drawable/ic_connection',
        actions: [
          AndroidNotificationAction(
            'accept',
            'Accept',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'reject',
            'Reject',
            showsUserInterface: false,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _connectionRequestId,
        title,
        body,
        details,
        payload: 'connection_request:$deviceName',
      );
    } catch (e) {
      _logger.error('Error showing connection request notification: $e');
    }
  }

  /// Show general notification
  Future<void> showGeneralNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      if (!await areNotificationsEnabled()) return;

      const androidDetails = AndroidNotificationDetails(
        _generalChannelId,
        _generalChannelName,
        channelDescription: _generalChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        autoCancel: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _generalNotificationId,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      _logger.error('Error showing general notification: $e');
    }
  }

  /// Schedule notification for a future time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String? channelId,
    AndroidNotificationDetails? androidDetails,
    DarwinNotificationDetails? iosDetails,
  }) async {
    try {
      if (!await areNotificationsEnabled()) return;

      // Validate scheduled date
      if (scheduledDate.isBefore(DateTime.now())) {
        _logger.warning('Cannot schedule notification in the past');
        return;
      }

      // Use provided details or defaults
      final finalAndroidDetails =
          androidDetails ??
          AndroidNotificationDetails(
            channelId ?? _reminderChannelId,
            channelId == _transferChannelId
                ? _transferChannelName
                : channelId == _deviceChannelId
                ? _deviceChannelName
                : _reminderChannelName,
            channelDescription: channelId == _transferChannelId
                ? _transferChannelDescription
                : channelId == _deviceChannelId
                ? _deviceChannelDescription
                : _reminderChannelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            autoCancel: true,
            playSound: true,
            enableVibration: true,
            icon: '@drawable/ic_notification',
          );

      final finalIosDetails =
          iosDetails ??
          const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      final details = NotificationDetails(
        android: finalAndroidDetails,
        iOS: finalIosDetails,
      );

      // Convert DateTime to TZDateTime for proper timezone handling
      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      _logger.info(
        'Notification scheduled for ${DateTimeUtils.formatDateTime(scheduledDate)} with ID: $id',
      );

      // Store scheduled notification info for management
      await _storeScheduledNotification(
        id,
        title,
        body,
        scheduledDate,
        payload,
      );
    } catch (e) {
      _logger.error('Error scheduling notification: $e');
      throw Exception('Failed to schedule notification: $e');
    }
  }

  /// Schedule recurring notification (daily, weekly, etc.)
  Future<void> scheduleRecurringNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required RecurrenceType recurrence,
    String? payload,
    int? maxOccurrences,
  }) async {
    try {
      if (!await areNotificationsEnabled()) return;

      DateTime currentDate = scheduledDate;
      int occurrenceCount = 0;

      while (maxOccurrences == null || occurrenceCount < maxOccurrences) {
        if (currentDate.isAfter(DateTime.now())) {
          await scheduleNotification(
            id: id + occurrenceCount,
            title: title,
            body: body,
            scheduledDate: currentDate,
            payload: payload,
            channelId: _reminderChannelId,
          );
        }

        // Calculate next occurrence
        switch (recurrence) {
          case RecurrenceType.daily:
            currentDate = currentDate.add(const Duration(days: 1));
            break;
          case RecurrenceType.weekly:
            currentDate = currentDate.add(const Duration(days: 7));
            break;
          case RecurrenceType.monthly:
            currentDate = DateTime(
              currentDate.year,
              currentDate.month + 1,
              currentDate.day,
              currentDate.hour,
              currentDate.minute,
            );
            break;
          case RecurrenceType.yearly:
            currentDate = DateTime(
              currentDate.year + 1,
              currentDate.month,
              currentDate.day,
              currentDate.hour,
              currentDate.minute,
            );
            break;
        }

        occurrenceCount++;

        // Safety break to prevent infinite loop
        if (occurrenceCount > 100) break;
      }

      _logger.info(
        'Scheduled $occurrenceCount recurring notifications starting from ${DateTimeUtils.formatDateTime(scheduledDate)}',
      );
    } catch (e) {
      _logger.error('Error scheduling recurring notification: $e');
      throw Exception('Failed to schedule recurring notification: $e');
    }
  }

  /// Schedule transfer reminder notification
  Future<void> scheduleTransferReminder({
    required String fileName,
    required DateTime reminderTime,
    required String deviceName,
  }) async {
    try {
      final id = _generateUniqueId();
      await scheduleNotification(
        id: id,
        title: 'Transfer Reminder',
        body: 'Don\'t forget to send "$fileName" to $deviceName',
        scheduledDate: reminderTime,
        payload: 'transfer_reminder:$fileName:$deviceName',
        channelId: _reminderChannelId,
      );
    } catch (e) {
      _logger.error('Error scheduling transfer reminder: $e');
    }
  }

  /// Schedule device connection reminder
  Future<void> scheduleDeviceConnectionReminder({
    required String deviceName,
    required DateTime reminderTime,
  }) async {
    try {
      final id = _generateUniqueId();
      await scheduleNotification(
        id: id,
        title: 'Connection Reminder',
        body: 'Connect to $deviceName for file sharing',
        scheduledDate: reminderTime,
        payload: 'connection_reminder:$deviceName',
        channelId: _reminderChannelId,
      );
    } catch (e) {
      _logger.error('Error scheduling device connection reminder: $e');
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      await _removeScheduledNotification(id);
      _logger.info('Cancelled notification with ID: $id');
    } catch (e) {
      _logger.error('Error cancelling notification $id: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllScheduledNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      await _clearAllScheduledNotifications();
      _logger.info('Cancelled all scheduled notifications');
    } catch (e) {
      _logger.error('Error cancelling all notifications: $e');
    }
  }

  /// Cancel transfer notifications
  Future<void> cancelTransferNotifications() async {
    try {
      await _notificationsPlugin.cancel(_transferProgressId);
      await _notificationsPlugin.cancel(_transferCompleteId);
      await _notificationsPlugin.cancel(_transferFailedId);
    } catch (e) {
      _logger.error('Error cancelling transfer notifications: $e');
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      _logger.error('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Get scheduled notifications from storage
  Future<List<Map<String, dynamic>>> getScheduledNotifications() async {
    try {
      final stored =
          _storageService.getString('scheduled_notifications') ?? '[]';
      // In a real app, you'd parse JSON properly
      return []; // Simplified for example
    } catch (e) {
      _logger.error('Error getting scheduled notifications: $e');
      return [];
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    try {
      if (!Platform.isAndroid) return;

      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation == null) return;

      // Transfer channel
      const transferChannel = AndroidNotificationChannel(
        _transferChannelId,
        _transferChannelName,
        description: _transferChannelDescription,
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
      );

      // Device channel
      const deviceChannel = AndroidNotificationChannel(
        _deviceChannelId,
        _deviceChannelName,
        description: _deviceChannelDescription,
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
      );

      // General channel
      const generalChannel = AndroidNotificationChannel(
        _generalChannelId,
        _generalChannelName,
        description: _generalChannelDescription,
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
      );

      // Reminder channel
      const reminderChannel = AndroidNotificationChannel(
        _reminderChannelId,
        _reminderChannelName,
        description: _reminderChannelDescription,
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
      );

      await androidImplementation.createNotificationChannel(transferChannel);
      await androidImplementation.createNotificationChannel(deviceChannel);
      await androidImplementation.createNotificationChannel(generalChannel);
      await androidImplementation.createNotificationChannel(reminderChannel);

      _logger.info('Notification channels created successfully');
    } catch (e) {
      _logger.error('Error creating notification channels: $e');
    }
  }

  /// Handle notification tap - main entry point
  void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      final actionId = response.actionId;

      _logger.info(
        'Notification tapped - Payload: $payload, Action: $actionId',
      );

      if (payload == null) return;

      // Handle different notification types
      if (payload.startsWith('connection_request:')) {
        final deviceName = payload.substring('connection_request:'.length);
        _handleConnectionRequest(deviceName, actionId);
      } else if (payload.startsWith('device_found:')) {
        final deviceName = payload.substring('device_found:'.length);
        _handleDeviceFound(deviceName);
      } else if (payload == 'transfer_complete') {
        _handleTransferComplete();
      } else if (payload == 'transfer_failed') {
        _handleTransferFailed();
      } else if (payload.startsWith('transfer_reminder:')) {
        _handleTransferReminder(payload);
      } else if (payload.startsWith('connection_reminder:')) {
        _handleConnectionReminder(payload);
      }
    } catch (e) {
      _logger.error('Error handling notification tap: $e');
    }
  }

  /// Handle connection request notification action
  void _handleConnectionRequest(String deviceName, String? actionId) {
    try {
      _logger.info('Connection request from $deviceName - Action: $actionId');

      // Cancel the connection request notification
      cancelNotification(_connectionRequestId);

      if (actionId == null) {
        // Notification was tapped, not action button
        _navigateToConnectionPage(deviceName);
        return;
      }

      switch (actionId) {
        case 'accept':
          _handleConnectionAccept(deviceName);
          break;
        case 'reject':
          _handleConnectionReject(deviceName);
          break;
        default:
          _navigateToConnectionPage(deviceName);
      }

      // Call external callback if set
      _onConnectionRequestCallback?.call(deviceName, actionId);
    } catch (e) {
      _logger.error('Error handling connection request: $e');
      _showErrorDialog(
        'Connection Error',
        'Failed to handle connection request',
      );
    }
  }

  /// Handle device found notification tap
  void _handleDeviceFound(String deviceName) {
    try {
      _logger.info('Device found notification tapped: $deviceName');

      // Cancel the device found notification
      cancelNotification(_deviceFoundId);

      // Navigate to device discovery page
      _navigateToDiscoveryPage(highlightDevice: deviceName);

      // Call external callback if set
      _onDeviceFoundCallback?.call(deviceName);
    } catch (e) {
      _logger.error('Error handling device found: $e');
      _showErrorDialog('Navigation Error', 'Failed to open device discovery');
    }
  }

  /// Handle transfer complete notification tap
  void _handleTransferComplete() {
    try {
      _logger.info('Transfer complete notification tapped');

      // Cancel the completion notification
      cancelNotification(_transferCompleteId);

      // Navigate to transfer history page
      _navigateToTransferHistory();

      // Call external callback if set
      _onTransferCompleteCallback?.call();
    } catch (e) {
      _logger.error('Error handling transfer complete: $e');
      _showErrorDialog('Navigation Error', 'Failed to open transfer history');
    }
  }

  /// Handle transfer failed notification tap
  void _handleTransferFailed() {
    try {
      _logger.info('Transfer failed notification tapped');

      // Cancel the failed notification
      cancelNotification(_transferFailedId);

      // Navigate to transfer details or retry page
      _navigateToTransferDetails();

      // Call external callback if set
      _onTransferFailedCallback?.call();
    } catch (e) {
      _logger.error('Error handling transfer failed: $e');
      _showErrorDialog('Navigation Error', 'Failed to open transfer details');
    }
  }

  /// Handle transfer reminder notification
  void _handleTransferReminder(String payload) {
    try {
      final parts = payload.split(':');
      if (parts.length >= 3) {
        final fileName = parts[1];
        final deviceName = parts[2];
        _logger.info('Transfer reminder: $fileName to $deviceName');
        _navigateToFileSelection(fileName, deviceName);
      }
    } catch (e) {
      _logger.error('Error handling transfer reminder: $e');
    }
  }

  /// Handle connection reminder notification
  void _handleConnectionReminder(String payload) {
    try {
      final deviceName = payload.substring('connection_reminder:'.length);
      _logger.info('Connection reminder: $deviceName');
      _navigateToDiscoveryPage(highlightDevice: deviceName);
    } catch (e) {
      _logger.error('Error handling connection reminder: $e');
    }
  }

  /// Navigation and helper methods
  void _handleConnectionAccept(String deviceName) {
    try {
      _logger.info('Accepting connection from $deviceName');
      showGeneralNotification(
        title: 'Connection Accepted',
        body: 'Connecting to $deviceName...',
        payload: 'connection_accepting:$deviceName',
      );
      _navigateToDiscoveryPage();
      _storeConnectionDecision(deviceName, true);
    } catch (e) {
      _logger.error('Error accepting connection: $e');
      _showErrorDialog('Connection Error', 'Failed to accept connection');
    }
  }

  void _handleConnectionReject(String deviceName) {
    try {
      _logger.info('Rejecting connection from $deviceName');
      showGeneralNotification(
        title: 'Connection Rejected',
        body: 'Connection from $deviceName was declined',
        payload: 'connection_rejected:$deviceName',
      );
      _storeConnectionDecision(deviceName, false);
      Timer(const Duration(seconds: 2), () {
        cancelNotification(_generalNotificationId);
      });
    } catch (e) {
      _logger.error('Error rejecting connection: $e');
    }
  }

  void _navigateToConnectionPage(String deviceName) {
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      _logger.warning('Cannot navigate - no context available');
      return;
    }

    try {
      Navigator.of(
        context,
      ).pushNamed('/discovery', arguments: {'highlightDevice': deviceName});
    } catch (e) {
      _logger.error('Error navigating to connection page: $e');
      _showConnectionDialog(context, deviceName);
    }
  }

  void _navigateToDiscoveryPage({String? highlightDevice}) {
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      _logger.warning(
        'Cannot navigate to discovery page - no context available',
      );
      return;
    }

    try {
      final arguments = highlightDevice != null
          ? {'highlightDevice': highlightDevice}
          : null;
      Navigator.of(context).pushNamed('/discovery', arguments: arguments);
    } catch (e) {
      _logger.error('Error navigating to discovery page: $e');
    }
  }

  void _navigateToTransferHistory() {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    try {
      Navigator.of(context).pushNamed('/transfer-history');
    } catch (e) {
      _logger.error('Error navigating to transfer history: $e');
      _showTransferHistoryDialog(context);
    }
  }

  void _navigateToTransferDetails() {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    try {
      Navigator.of(context).pushNamed('/transfer-details');
    } catch (e) {
      _logger.error('Error navigating to transfer details: $e');
      _showTransferRetryDialog(context);
    }
  }

  void _navigateToFileSelection(String fileName, String deviceName) {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    try {
      Navigator.of(context).pushNamed(
        '/file-selection',
        arguments: {
          'fileName': fileName,
          'deviceName': deviceName,
          'preselected': true,
        },
      );
    } catch (e) {
      _logger.error('Error navigating to file selection: $e');
    }
  }

  /// Utility methods
  int _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch % 100000;
  }

  Future<void> _storeScheduledNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
    String? payload,
  ) async {
    try {
      final notification = {
        'id': id,
        'title': title,
        'body': body,
        'scheduledDate': scheduledDate.millisecondsSinceEpoch,
        'payload': payload,
      };

      // In a real app, you'd store this in SharedPreferences or a database
      _logger.debug('Stored scheduled notification: $notification');
    } catch (e) {
      _logger.error('Error storing scheduled notification: $e');
    }
  }

  Future<void> _removeScheduledNotification(int id) async {
    try {
      // In a real app, you'd remove this from SharedPreferences or database
      _logger.debug('Removed scheduled notification with ID: $id');
    } catch (e) {
      _logger.error('Error removing scheduled notification: $e');
    }
  }

  Future<void> _clearAllScheduledNotifications() async {
    try {
      // In a real app, you'd clear all from SharedPreferences or database
      _logger.debug('Cleared all scheduled notifications');
    } catch (e) {
      _logger.error('Error clearing scheduled notifications: $e');
    }
  }

  void _storeConnectionDecision(String deviceName, bool accepted) {
    try {
      _logger.debug('Stored connection decision for $deviceName: $accepted');
    } catch (e) {
      _logger.error('Error storing connection decision: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showConnectionDialog(BuildContext context, String deviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connection Request'),
          content: Text(
            '$deviceName wants to connect. What would you like to do?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleConnectionReject(deviceName);
              },
              child: const Text('Reject'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleConnectionAccept(deviceName);
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  void _showTransferHistoryDialog(BuildContext context) {
    final history = _storageService.getTransferHistory();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recent Transfers'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: history.isEmpty
                ? const Center(child: Text('No transfer history'))
                : ListView.builder(
                    itemCount: history.length > 5 ? 5 : history.length,
                    itemBuilder: (context, index) {
                      final transfer = history[index];
                      return ListTile(
                        title: Text(transfer['fileName'] ?? 'Unknown'),
                        subtitle: Text(transfer['status'] ?? 'Unknown'),
                        trailing: Text(transfer['size'] ?? ''),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showTransferRetryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Transfer Failed'),
          content: const Text(
            'The file transfer was unsuccessful. Would you like to retry?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logger.info('Transfer retry requested');
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }
}

/// Recurrence types for scheduled notifications
enum RecurrenceType { daily, weekly, monthly, yearly }
