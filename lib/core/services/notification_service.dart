import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_constants.dart';
import '../utils/size_utils.dart';
import '../utils/date_time_utils.dart';
import 'logger_service.dart';
import 'storage_service.dart';

/// Notification management service
class NotificationService {
  static NotificationService? _instance;
  final LoggerService _logger = LoggerService();
  final StorageService _storageService = StorageService.instance;

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

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

  // Notification IDs
  static const int _transferProgressId = 1000;
  static const int _transferCompleteId = 1001;
  static const int _transferFailedId = 1002;
  static const int _deviceFoundId = 2000;
  static const int _connectionRequestId = 2001;
  static const int _generalNotificationId = 3000;

  NotificationService._();

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      _notificationsPlugin = FlutterLocalNotificationsPlugin();

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

      const details = NotificationDetails(
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

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      _logger.error('Error cancelling notification $id: $e');
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

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      _logger.error('Error cancelling all notifications: $e');
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

      await androidImplementation.createNotificationChannel(transferChannel);
      await androidImplementation.createNotificationChannel(deviceChannel);
      await androidImplementation.createNotificationChannel(generalChannel);

      _logger.info('Notification channels created successfully');
    } catch (e) {
      _logger.error('Error creating notification channels: $e');
    }
  }

  /// Handle notification tap
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
      }
    } catch (e) {
      _logger.error('Error handling notification tap: $e');
    }
  }

  /// Handle connection request notification action
  void _handleConnectionRequest(String deviceName, String? actionId) {
    // This would typically trigger a callback or navigate to connection handling
    _logger.info('Connection request from $deviceName - Action: $actionId');
    // TODO: Implement connection request handling
  }

  /// Handle device found notification tap
  void _handleDeviceFound(String deviceName) {
    _logger.info('Device found notification tapped: $deviceName');
    // TODO: Navigate to device discovery page
  }

  /// Handle transfer complete notification tap
  void _handleTransferComplete() {
    _logger.info('Transfer complete notification tapped');
    // TODO: Navigate to transfer history or show completion details
  }

  /// Handle transfer failed notification tap
  void _handleTransferFailed() {
    _logger.info('Transfer failed notification tapped');
    // TODO: Navigate to transfer details or retry options
  }

  /// Schedule notification for later
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _generalChannelId,
        _generalChannelName,
        channelDescription: _generalChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      _logger.info(
        'Notification scheduled for ${DateTimeUtils.formatDateTime(scheduledDate)}',
      );
    } catch (e) {
      _logger.error('Error scheduling notification: $e');
    }
  }
}
