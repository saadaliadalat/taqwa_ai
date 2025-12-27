import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Notification Service for Firebase Cloud Messaging
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  String? _fcmToken;
  
  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> init() async {
    // Request permission
    final settings = await _requestPermission();
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Get FCM token
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
      
      // Listen for token refresh
      _messaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        debugPrint('FCM Token refreshed: $_fcmToken');
        // TODO: Update token in backend
      });
      
      // Configure message handlers
      _configureMessageHandlers();
    }
  }

  /// Request notification permission
  Future<NotificationSettings> _requestPermission() async {
    // For Android 13+, we need to request POST_NOTIFICATIONS permission
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      debugPrint('Notification permission status: $status');
    }

    // Request Firebase Messaging permission
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('Notification authorization status: ${settings.authorizationStatus}');
    return settings;
  }

  /// Configure message handlers
  void _configureMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Check if app was opened from a notification
    _checkInitialMessage();
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // Show local notification or handle as needed
    _showLocalNotification(message);
  }

  /// Handle when user taps notification to open app
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
    debugPrint('Data: ${message.data}');

    // Navigate based on notification data
    _handleNotificationNavigation(message.data);
  }

  /// Check if app was opened from a notification
  Future<void> _checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    
    if (message != null) {
      debugPrint('App opened from notification: ${message.messageId}');
      _handleNotificationNavigation(message.data);
    }
  }

  /// Show local notification (placeholder - implement with flutter_local_notifications)
  void _showLocalNotification(RemoteMessage message) {
    // TODO: Implement with flutter_local_notifications package
    // For now, this is a placeholder
    debugPrint('Would show local notification: ${message.notification?.title}');
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    
    switch (type) {
      case 'daily_ayah':
        // Navigate to home screen with daily ayah
        debugPrint('Navigate to daily ayah');
        break;
      case 'conversation':
        final conversationId = data['conversationId'] as String?;
        if (conversationId != null) {
          debugPrint('Navigate to conversation: $conversationId');
        }
        break;
      case 'reminder':
        debugPrint('Navigate to reminders');
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Enable daily ayah notifications
  Future<void> enableDailyAyahNotifications() async {
    await subscribeToTopic('daily_ayah');
  }

  /// Disable daily ayah notifications
  Future<void> disableDailyAyahNotifications() async {
    await unsubscribeFromTopic('daily_ayah');
  }

  /// Get notification settings
  Future<NotificationSettings> getSettings() async {
    return await _messaging.getNotificationSettings();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await getSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Delete FCM token (for logout)
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    _fcmToken = null;
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  
  // Handle background message
  // Note: Cannot access providers or navigation here
}
